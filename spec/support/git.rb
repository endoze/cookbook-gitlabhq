require 'chefspec/matchers/shared'

module ChefSpec
  module Matchers
    define_resource_matchers([:sync, :checkout, :export], [:git], :path)
    RSpec::Matchers.define :git do |path|
      match do |link|
        link.nil? ? false : link.to == path
      end
    end
  end
end
