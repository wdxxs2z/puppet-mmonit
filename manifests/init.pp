class mmonit(
  $version        = "3.2.2",

  $src_path       = "/usr/local/src/mmonit/",
  $bin_path       = "/opt/mmonit/",

  $connector_address  = "*",
  $connector_port     = "8080",
  $connector_procs    = "10",
  $connector_secure   = "false",

  $engine_defaulthost  = "localhost",
  $engine_filecache    = "10MB",

  $realm_url           = "sqlite:///db/mmonit.db?synchronous=normal&heap_limit=8000&foreign_keys=on&journal_mode=wal",
  $realm_min_cnx       = "5",
  $realm_max_cnx       = "25",
  $realm_reap_cnx      = "300",

  $error_dir           = "logs",
  $error_filename      = "error.log",
  $error_log_rotate    = "month",

  $host_name           = "localhost",
  $host_address        = "localhost",
  $host_cert_path      = "/opt/mmonit/conf/mmonit.pem",

  $access_log_on       = "false",
  $access_log_dir      = "logs",
  $access_log_name     = "localhost_access.log",
  $access_log_rotate   = "month",

  $license_owner  = "",
  $license_key    = "",
  $alt_source_url = "",
) {

  if $::architecture == "amd64" or $::architecture == "x86_64" {
      $platid = "x64"
  } else {
      $platid = "x86"
  }

  file { $bin_path : ensure => directory }
  file { $src_path : ensure => directory }

  if $alt_source_url {
    $download_url = $alt_source_url
    $url_bits = split($download_url, '/')
    $filename = $url_bits[-1]

    if !($version in $alt_source_url) {
      fail("There appears to be a mismatch between M/Monit version specified (${version}) and file name of alternate download source (${alt_source_url})!")
    }

  } else {
    $filename = "mmonit-${version}-linux-${platid}.tar.gz"
    $download_url = "http://mmonit.com/dist/${filename}"
  }

  exec { "download-mmonit-${filename}" :
    command => "wget ${download_url} -O ${filename}",
    cwd => $src_path,
    creates => "${src_path}${filename}",
    require => File[$src_path,$bin_path]
  }

  exec { "extract-mmonit-${filename}" :
    command   => "tar --strip-components 1 -xzvf ${filename} -C ${bin_path}",
    cwd       => $src_path,
    unless    => "test -f ${bin_path}bin/mmonit && ${bin_path}bin/mmonit -v | grep ${version}",
    require   => Exec["download-mmonit-${filename}"]
  }

  file { init_mmonit:
    path    => "/etc/init.d/mmonit",
    content => template("mmonit/mmonit_init"),
    replace => true,
    mode    => 755,
    ensure  => present
  }

  file { "${bin_path}conf/server.xml" :
    content => template("mmonit/server.xml"),
    replace => true,
    mode    => 755,
    ensure  => present,
    notify  => Service["mmonit"]
  }

  service { "mmonit" :
    hasstatus => false,
    ensure    => running,
  }

}
