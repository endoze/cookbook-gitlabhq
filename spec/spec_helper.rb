require 'chefspec'

CHEF_RUN_OPTIONS = {
  :platform  => 'ubuntu',
  :version   => '12.04',
  :log_level => :error,
}

RSpec.configure do |config|
  config.filter_run :focus => true
  config.run_all_when_everything_filtered = true
end
