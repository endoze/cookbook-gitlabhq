#
# Cookbook Name:: gitlabhq
# Recipe:: default
#
# Copyright 2013, Wide Eye Labs
#
# MIT License
#

module Gitlabhq
  module Helper
    def gitlab_database_config
      DatabaseConfig.new(data_bag_item('gitlab', 'database'), node)
    end

    def gitlab_ci_database_config
      DatabaseConfig.new(data_bag_item('gitlab_ci', 'database'), node)
    end

    class DatabaseConfig
      attr_reader :config, :node

      def initialize(config, node)
        @config = config
        @node = node
      end

      def use_mysql?
        config['database_type'] ==  'mysql'
      end

      def without_group
        use_mysql? ? 'postgres' : 'mysql'
      end

      def node_root_password
        use_mysql? ? node[:mysql][:server_root_password] : node[:postgresql][:password][:postgres]
      end

      def database_provider
        use_mysql? ? Chef::Provider::Database::Mysql : Chef::Provider::Database::Postgresql
      end

      def database_user_provider
        use_mysql? ? Chef::Provider::Database::MysqlUser : Chef::Provider::Database::PostgresqlUser
      end

      def database_constant
        use_mysql? ? 'MySQL' : 'PostgreSQL'
      end

      def method_missing(method, *args, &block)
        if respond_to? method
          config[method.to_s]
        else
          super
        end
      end

      def respond_to?(method, include_private = false)
        if config.has_key? method.to_s
          true
        else
          super
        end
      end
    end
  end
end
