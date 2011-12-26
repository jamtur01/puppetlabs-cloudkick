require 'rubygems'
require 'json'
require 'oauth'

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
      when :delete
        node_id = get_node_id
        "/2.0/node/#{node_id}/disable"
      when :update
        node_id = get_node_id
        "/2.0/node/#{node_id}"
      end
    end

    def create_node(resources)
        url = build_url(resource, :create)
        body = {:name       => resource[:name],
                :ip_address => resource[:ipaddress],
                :color      => resource[:color],
                :tags       => resource[:tags]
        }

        Puppet.info("Creating node #{resource[:name]}")
        response, data = access_token.post(url, body)
        if response.code == '409'
          Puppet.info("A disabled node with this name already exists. Re-enabling.")
        elsif response.code !~ /^2/
          error_output(response)
          raise Puppet::Error, "Unable to create node #{resource[:name]}."
        end
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

    def set_node_tags(value)
      node_tags = get_node_tags
      new_tags = value
      new_tags.each do |t|
        unless node_tags.include?(t)
          add_node_tag(node_tags,t)
        end
      end
      old_tags = node_tags - new_tags
      old_tags.each do |t|
        remove_node_tag(t)
      end
    end

    def set_node_color(value)
      color = get_node_color
      unless color == value
        add_node_color(value)
      end
    end

    def get_node
      response, data = access_token.request(:get, "/2.0/nodes?query=node:#{resource[:name]}")
      if not response.code =~ /^2/
        error_output(response)
        raise Puppet::Error, "Unable to get node id for #{resource[:name]}."
      end
      return JSON::parse(data)
    end

    def get_node_id
      node = get_node
      if node['items'].first['name'] == resource[:name]
        return node['items'].first['id']
      else
        return nil
      end
    end

    def get_node_tags
      node_tags = []
      node = get_node
      tags = node['items'].first['tags']
      tags.each do |t|
        node_tags << t['name']
      end
      return node_tags.sort
    end

    def get_node_color
      node = get_node
      color = node['items'].first['color']
      return color
    end

    def add_node_color(color)
      url = build_url(resource, :update)
      body = { :color => color }
      response, data = access_token.request(:post, url, body)
      if not response.code =~ /^2/
        error_output(response)
        raise Puppet::Error, "Unable to update color #{color}."
      end
    end

    def add_node_tag(node_tags,tag)
      url = build_url(resource, :addtag)

      if node_tags.include?(tag)
        body = { :name => tag }
      else
        body = { :name => tag, :do_create => true }
      end

      response, data = access_token.request(:post, url, body)
      if not response.code =~ /^2/
        error_output(response)
        raise Puppet::Error, "Unable to add node tag #{tag}."
      end
    end

    def remove_node_tag(tag)
      url = build_url(resource, :removetag)

      body = { :name => tag }
      response, data = access_token.request(:post, url, body)
      if not response.code =~ /^2/
        error_output(response)
        raise Puppet::Error, "Unable to remove node tag #{tag}."
      end
    end

    def error_output(response)
      Puppet.debug("Code: #{response.code}")
      Puppet.debug("Body: #{response.body}")
    end
  end
end
