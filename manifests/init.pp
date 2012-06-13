class mmonit($version = "2.4",
$address    = "127.0.0.1",
$hostname   = "localhost",
$db_user    = "mmonit",
$db_pass    = "mmonit",
$db_host    = "localhost",
$db_name    = "mmonit",
$cert_path  = "/opt/mmonit/conf/mmonit.pem",
$license_owner  = "",
$license_key    = "" ) {
    
    if $::architecture == "amd64" or $::architecture == "x86_64" {
        $platid = "x64"
    } else {
        $platid = "x86"
    }
    
    $filename = "mmonit-${version}-linux-${platid}.tar.gz"
    $src_path = "/usr/local/src/mmonit/"
    $bin_path = "/opt/mmonit/"

    file { $src_path : ensure => directory }
    file { $bin_path : ensure => directory }

    exec { "download-mmonit-${filename}" : 
        command => "wget http://mmonit.com/dist/${filename} -O ${filename}",
        cwd => $src_path,
        creates => "${src_path}${filename}",
        require => File[$src_path,$bin_path]
    }
    
    exec { "extract-mmonit-${filename}" : 
        command => "tar --strip-components 1 -xzvf ${filename} -C ${bin_path}",
        cwd => $src_path,
        unless => "test -f ${bin_path}bin/mmonit && ${bin_path}bin/mmonit -v | grep ${version}",
        require => Exec["download-mmonit-${filename}"]
    }
    
    file { init_mmonit:
        path    => "/etc/init.d/mmonit",
        content => template("mmonit/mmonit_init"),
        replace => true,
        mode    => 755, 
        ensure  => present
    }
    
    file { server_config:
        path    => "/opt/mmonit/conf/server.xml",
        content => template("mmonit/server.xml"),
        replace => true,
        mode    => 755, 
        ensure  => present,
        notify  => Service["mmonit"]
    }
    
    service { "mmonit" : 
        hasstatus   => false,
        ensure      => running
    }
     
}