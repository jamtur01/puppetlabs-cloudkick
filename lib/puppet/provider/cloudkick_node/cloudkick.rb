require 'rubygems'
require 'json'
require 'oauth'
require 'pp'

module Cloudkick
  module API

    def access_token
      @@access_token ||= OAuth::AccessToken.new(consumer)
    end

    def consumer
      @@consumer ||= OAuth::Consumer.new(@key, @secret,
                                        :site => "https://api.cloudkick.com/oauth/token",
                                        :http_method => :get)
    end

    def build_url(resource, action)
      case action
      when :create
        "/2.0/nodes"
      when :search
        "/2.0/nodes?query='node:#{resource[:name]}'"
      when :addtag
        node_id = get_node_id
        "/2.0/node/#{node_id}/add_tag"
      when :removetag
        node_id = get_node_id
        "/2.0/node/#{node_id}/remove_tag"
      when :searchtags
        "/2.0/tags"
      when :delete
        node_id = get_node_id
        "/2.0/node/#{node_id}/disable"
      end
    end

    def create_node(resource)
        url = build_url(resource, :create)
        body = {:name => resource[:name], :ip_address => resource[:ipaddress]}

        Puppet.info("Creating node #{resource[:name]}")
        response, data = access_token.post(url, body)
        if response.code == '409'
          Puppet.info("A disabled node with this name already exists. Re-enabling.")
        elsif response.code !~ /^2/
          error_output(response)
          raise Puppet::Error, "Unable to create node #{resource[:name]}."
        end

        # Tagging is disabled until I can fix some issues with the API
        #
        #if resource[:tags]
        #  apply_node_tags(resource)
        #end
    end

    def delete_node(resource)
        url = build_url(resource, :delete)

        Puppet.info("Disabling node #{resource[:name]}")
        response, data = access_token.post(url)
        if not response.code =~ /^2/
          error_output(response)
          raise Puppet::Error, "Unable to disable node #{resource[:name]}."
        end
    end

    def node_exists?(resource)
      @key = resource[:key]
      @secret = resource[:secret]
      url = build_url(resource, :search)

        response, data = access_token.request(:get, url)

        if response
          body = JSON.parse(response.body)

          if body == []
            false
          else
            true
          end
        else
          raise Puppet::Error, "Could not determine if node exists (nil response)!"
          nil
        end
    end

    def get_node_id
      response, data = access_token.request(:get, "/2.0/nodes?query=node:#{resource[:name]}")
      if not response.code =~ /^2/
        error_output(response)
        raise Puppet::Error, "Unable to get node id for #{resource[:name]}."
      end
      parsed = JSON::parse(data)
      if parsed['items'].first['name'] == resource[:name]
        return parsed['items'].first['id']
      end
      return nil
    end

    def apply_node_tags(resource)
      tags = resource[:tags]

      current_tags = get_current_tags

      url = build_url(resource, :addtag)

      Puppet.info("Applying node tags #{tags.inspect}")

      tags.each do |tag|
        if current_tags.include?(tag)
          body = { :name => tag }
        else
          body = { :name => tag, :do_create => true }
        end
        pp url, body
        response, data = access_token.request(:post, url, body)
        if not response.code =~ /^2/
          error_output(response)
          raise Puppet::Error, "Unable to add node tag #{tag}."
        end
      end
    end

    def get_current_tags
      current_tags = []
      url = build_url(resource, :searchtags)

      response, data = access_token.request(:get, url)
      if not response.code =~ /^2/
        error_output(response)
        raise Puppet::Error, "Unable to get list of current tags."
      end
      parsed = JSON::parse(data)
      parsed.each do |t|
        current_tags << t['name']
      end
      return current_tags
    end

    def error_output(response)
      Puppet.debug("Code: #{response.code}")
      Puppet.debug("Body: #{response.body}")
    end
  end
end
