Cloudkick module
===

This is the Cloudkick module.

To use it:

    include cloudkick

You need need to specify your API secret and key in the
cloudkick::params class (manifests/params.pp).

To remove a node change your include to:

    include cloudkick::delete

Author
---

James Turnbull <james@puppetlabs.com>

Copyright
---

Puppet Labs 2011

License
---

Apache 2.0
