# Class: cloudkick
#
# This module manages cloudkick
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
class cloudkick {

  require cloudkick::dependencies

  include cloudkick::params

  $key    = $cloudkick::params::key
  $secret = $cloudkick::params::secret

  file { '/usr/lib/cloudkick-agent':
    ensure => directory;
  }

  file { 'cloudkick-plugins':
    path    => '/usr/lib/cloudkick-agent/plugins/',
    recurse => true,
    require => File['/usr/lib/cloudkick-agent'],
    source  => 'puppet:///cloudkick/plugins/';
  }

  file { '/etc/cloudkick.conf':
    content => template('cloudkick/cloudkick.conf.erb');
  }

  package { 'cloudkick-agent':
    ensure  => latest,
    require => File['/etc/cloudkick.conf'];
  }

  service { 'cloudkick-agent':
    ensure  => running,
    enable  => true,
    require => File['/etc/cloudkick.conf'];
  }

  cloudkick_node { $fqdn:
    ensure    => present,
    key       => $key,
    secret    => $secret,
    ipaddress => $ipaddress,
    require   => Service['cloudkick-agent'],
  }
}
