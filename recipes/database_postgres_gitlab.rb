node.set_unless[:gitlab][:database][:password] = secure_password
ruby_block 'save node data' do
  block do
    node.save
  end
  not_if { Chef::Config[:solo] }
end

database = node[:gitlab][:database][:database]
database_user = node[:gitlab][:database][:username]
database_password = node[:gitlab][:database][:password]
database_host = node[:gitlab][:database][:host]
database_connection = {
  :host     => database_host,
  :port     => '5432',
  :username => 'postgres',
  :password => node[:postgresql][:password][:postgres]
}

# Create the database
postgresql_database database do
  connection      database_connection
  action          :create
end

# Create the database user
postgresql_database_user database_user do
  connection      database_connection
  password        database_password
  database_name   database
  action          :create
end

# Grant all privileges to user on database
postgresql_database_user database_user do
  connection      database_connection
  database_name   database
  action          :grant
end
