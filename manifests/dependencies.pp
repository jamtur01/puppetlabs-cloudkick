# Class: cloudkick::dependencies
#
# This module manages the Cloudkick dependencies
#
# Parameters:
#
# Actions:
#
# Requires:
#
# Sample Usage:
#
# [Remember: No empty lines between comments and class definition]
class cloudkick::dependencies {

  package { [ 'oauth', 'json' ]:
    ensure   => latest,
    provider => gem,
  }

  case $operatingsystem {
    'redhat', 'centos', 'fedora': {

      yumrepo { 'cloudkick':
        enabled  => 1,
        baseurl  => 'http://packages.cloudkick.com/redhat/$basearch',
      }
    }

    'debian', 'ubuntu': {

      exec { 'add-key':
        command     => '/usr/bin/curl http://packages.cloudkick.com/cloudkick.packages.key | apt-key add - && apt-get update',
        unless      => "apt-key list | grep -qF '8EE6154E'",
        refreshonly => true,
      }

      file { '/etc/apt/sources.list.d/cloudkick.list':
        ensure  => present,
        content => template('cloudkick/apt_source.erb'),
        owner   => 'root',
        group   => 'root',
        mode    => '0644',
        notify  => Exec['apt-update'],
      }

      exec { 'apt-update':
        command     => '/usr/bin/apt-get update',
        refreshonly => true;
      }
    }

    default: {
      fail('Platform not supported by cloudkick module. Patches welcomed.')
    }
  }
}
