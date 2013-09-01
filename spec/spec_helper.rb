require 'coveralls'
Coveralls.wear!

require 'chefspec'

CHEF_RUN_OPTIONS = {
  :platform  => 'ubuntu',
  :version   => '12.04',
  :log_level => :error,
}

MYSQL_OPTIONS = {
  :server_root_password   => 'rootpass',
  :server_debian_password => 'debpass',
  :server_repl_password   => 'replpass',
}

POSTGRES_OPTIONS = {
  :password => {
    :postgres => 'rootpass'
  }
}

RSpec.configure do |config|
  config.filter_run :focus => true
  config.run_all_when_everything_filtered = true
end
