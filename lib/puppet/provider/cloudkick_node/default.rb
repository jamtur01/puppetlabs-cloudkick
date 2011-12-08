Puppet::Type.type(:cloudkick_node).provide(:default) do

  desc "This is a default provider that does nothing."

  def create
    return false
  end

  def destroy
    return false
  end

  def exists?
    fail('This is just the default provider all it does is fail')
  end
end
