# Class: cloudkick::delete
#
# This manifest deletes Cloudkick agents
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
class cloudkick::delete {

  include cloudkick::params

  $key    = $cloudkick::params::key
  $secret = $cloudkick::params::secret

  file { '/usr/lib/cloudkick-agent':
    ensure => absent;
  }

  file { 'cloudkick-plugins':
    ensure => absent,
  }

  file { '/etc/cloudkick.conf':
    ensure => absent,
  }

  package { 'cloudkick-agent':
    ensure  => absent,
  }

  service { 'cloudkick-agent':
    ensure  => stopped,
    enable  => false,
  }

  cloudkick_node { $fqdn:
    ensure    => absent,
    key       => $key,
    secret    => $secret,
  }
}
