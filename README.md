## Overview 

This module install [M/Monit](https://mmonit.com/) and manages it as a service.

> NOTE: Current implementation is naive -- assumes you purchased M/Monit  and overwrites the trial license key in *conf/server.xml*.

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