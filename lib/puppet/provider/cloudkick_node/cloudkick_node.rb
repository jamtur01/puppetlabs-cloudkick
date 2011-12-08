#
# Author:: Jomes Turnbull <james@puppetlabs.com>
# Type Name:: cloudkick_node
# Provider:: cloudkick_node
#
# Copyright 2011, Puppet Labs
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#

Puppet::Type.type(:cloudkick_node).provide(:cloudkick_node) do

  include Cloudkick::API

  desc "Manage Cloudkick nodes."

  defaultfor :kernel => 'Linux'

  def create
    create_node(resource)
  end

  def exists?
    node_exists?(resource)
  end

  def destroy
    delete_node(resource)
  end
end
