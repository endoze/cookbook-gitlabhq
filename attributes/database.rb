
# DATABASE
default[:gitlab][:database][:type]     = 'mysql'
default[:gitlab][:database][:adapter]  =  default[:gitlab][:database][:type] == 'mysql' ? 'mysql2' : 'postgresql'
default[:gitlab][:database][:encoding] = default[:gitlab][:database][:type] == 'mysql' ? 'utf8' : 'unicode'
default[:gitlab][:database][:host]     = 'localhost'
default[:gitlab][:database][:pool]     = 5
default[:gitlab][:database][:database] = 'gitlab'
default[:gitlab][:database][:username] = 'gitlab'
