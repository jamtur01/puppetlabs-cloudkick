Puppet::Type.newtype(:cloudkick_node) do

  @doc = "Manage creation/deletion of Cloudkick nodes."

  ensurable

  newparam(:node, :namevar => true) do
    desc "The Cloudkick node name."
  end

  newparam(:secret) do
    desc "The Cloudkick secret."
  end

  newparam(:key) do
    desc "The Cloudkick key."
  end

  newparam(:ipaddress) do
    desc "The IP address of the node."
  end

  newproperty(:color) do
    desc "The color to specify. Should be a Hex color code, ie. `#000000`."

    validate do |value|
      unless value =~ /^\#[A-Za-z0-9]+$/
        raise ArgumentError , "%s is not a valid Hex color." % value
      end
    end
  end

  newproperty(:tags, :array_matching => :all) do
    desc "Tags to be added to the Cloudkick node. Specify a tag or an array of tags."

    def insync?(is)
      is.sort == @should.sort
    end
  end
end
