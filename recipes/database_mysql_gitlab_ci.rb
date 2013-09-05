node.set_unless[:gitlab][:ci][:database][:password] = secure_password
ruby_block 'save node data' do
  block do
    node.save
  end
  not_if { Chef::Config[:solo] }
end

database = node[:gitlab][:ci][:database][:database]
database_user = node[:gitlab][:ci][:database][:username]
database_password = node[:gitlab][:ci][:database][:password]
database_host = node[:gitlab][:ci][:database][:host]
database_connection = {
  :host     => database_host,
  :username => 'root',
  :password => node[:mysql][:server_root_password]
}

mysql_database database do
  connection   database_connection
  action       :create
end

mysql_database_user database_user do
  connection    database_connection
  password      database_password
  database_name database
end

mysql_database_user database_user do
  connection    database_connection
  database_name database
  action        :grant
end
