if node[:gitlab][:backup][:backups_enabled]
  include_recipe 'backup'

  aws_credentials = data_bag_item('credentials', 'aws_credentials')

  # Make Backup gem configuration file owned by backup user
  template "/opt/backup/config.rb" do
    cookbook "backup"
    source "config.rb.erb"
  end

  # Create a Backup gem configuration file
  backup_generate_config node.name

  # Install packages that backup gem depends on
  [ 'libxml2-dev', 'libxslt1-dev' ].each do |pkg|
    package pkg
  end

  # Install the Backup gem
  gem_package 'backup'

  # Install Backup gem dependencies
  # Must be done in this order.
  %w{
    net-ssh
    net-scp
    excon
    fog
  }.each do |gem|
    gem_package gem do
      action     :install
      gem_binary "#{node[:gitlab][:ruby_dir]}/gem"
    end
  end

  # Create a Backup Gem Model for repositories
  backup_generate_model 'gitlab_repos' do
    description 'backup of gitlab repositories'
    backup_type 'archive'
    split_into_chunks_of 250
    store_with({
      'engine' => 'S3',
      'settings' => {
        's3.region'            => node[:gitlab][:backup][:s3_region],
        's3.bucket'            => node[:gitlab][:backup][:s3_bucket],
        's3.path'              => node[:gitlab][:backup][:s3_path] + node.name,
        's3.keep'              => node[:gitlab][:backup][:s3_keep],
        's3.access_key_id'     => aws_credentials[:backup][:access_key_id],
        's3.secret_access_key' => aws_credentials[:backup][:secret_access_key]}
    })
    options({
      'add' => [node[:gitlab][:repos_path]]
    })
    action :backup
  end

  database_options = {
    "db.name"     => node[:gitlab][:database][:database],
    "db.username" => node[:gitlab][:database][:username],
    "db.password" => node[:gitlab][:database][:password],
    "db.host"     => node[:gitlab][:database][:host],
    "db.port"     => node[:gitlab][:database][:port],
  }

  database_options = database_options.each { |k,v| database_options.delete(k) if v.nil? || v.empty? }

  # Create a Backup Gem Model for database
  backup_generate_model 'gitlab_database' do
    description 'backup of gitlab database'
    backup_type 'database'
    database_type node[:gitlab][:database][:type] == 'mysql' ? 'MySQL' : 'PostgreSQL'
    split_into_chunks_of 250
    store_with({
      'engine' => 'S3',
      'settings' => {
        's3.region'            => node[:gitlab][:backup][:s3_region],
        's3.bucket'            => node[:gitlab][:backup][:s3_bucket],
        's3.path'              => "#{node[:gitlab][:backup][:s3_path]}/node.name",
        's3.keep'              => node[:gitlab][:backup][:s3_keep],
        's3.access_key_id'     => aws_credentials[:backup][:access_key_id],
        's3.secret_access_key' => aws_credentials[:backup][:secret_access_key]}
    })
    options database_options
    action :backup
  end
end
