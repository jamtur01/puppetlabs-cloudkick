Cloudkick module
===

This is the Cloudkick module.

To use it:

    include cloudkick

You need need to specify your API secret and key in the
cloudkick::params class (manifests/params.pp).

To remove a node change your include to:

    include cloudkick::delete

To configure a Cloudkick node you can use the built-in 
`cloudkick_node` type like so:

    cloudkick_node { 'node_name':
      key       => 'key,
      secret    => 'secret',
      ipaddress => '192.168.1.1',
      ensure    => present,
      color     => '#000000',
      tags      => [ 'foo', 'bar' ],
    }

Author
---

James Turnbull <james@puppetlabs.com>

Copyright
---

Puppet Labs 2011

License
---

Apache 2.0
