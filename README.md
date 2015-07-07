## Overview 

This module installs [M/Monit](https://mmonit.com/) and manages it as a service.

> NOTE: The current implementation assumes that you purchased M/Monit and overwrites the trial license key in *conf/server.xml*.
> In other words, this module will not auto-install a **working** trial copy of M/Monit.

## Usage

Assign the *mmonit* class to a node in the traditional fashion, making sure to provide *license_key*:

<pre>
# manifests/nodes.pp

node 'my-monit-server.com' {
  class { 'mmonit': 
    license_owner => 'John Smith',
    license_key   => "My really long license key"
  }
}
</pre>

Or assign and configure via [Hiera](http://docs.puppetlabs.com/hiera/1/):

<pre>
# hieradata/nodes/my-monit-server.com.yaml
classes:
  - mmonit

mmonit::license_owner: "John Smith"
mmonit::license_key: |
  REALLY LONG LICENSE 
  KEY GOES HERE
</pre>

> The pipe "|" above after *license_key* allows a multi-line yaml string *with newlines*.

## Configuration

Module provides default values for many configurations in the M/Monit server.xml file. Most of these can be overridden. See the *mmonit* class for details.

## Upgrades and automated builds

The core Monit team does NOT maintain links to older versions of its
software in perpetuity. If you have automated build processes that rely
an older version of M/Monit remain available, you can use 
the *$alt_source_url* variable to point to a saved copy of an older version (e.g. stashed in a personal S3 bucket).

The *$version* variable must also match the *$alt_source_url* variable, e.g.:

<pre>
# hieradata/nodes/my-monit-server.com.yaml
classes:
  - mmonit

mmonit::version: "3.5"
mmonit::alt_source_url: "http://some-s3-url/mmonit-3.5-linux-x64.tar.gz"
mmonit::license_owner: "John Smith"
mmonit::license_key: |
  REALLY LONG LICENSE 
  KEY GOES HERE
</pre>

In order to upgrade your production M/Monit instance, simply perform the manual steps detailed in the [offiical docs](https://mmonit.com/documentation/). 
Then, for automated build processes, point the M/Monit class or Hiera configs to a saved copy of the upgraded version. 

> NOTE: This process will only work on clean builds of M/Monit; this
> module does not provide a fully automated upgrade path!!!
