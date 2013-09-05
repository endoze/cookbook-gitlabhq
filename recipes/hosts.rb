local_aliases = [node[:fqdn], node[:gitlab][:server_name]]
local_aliases << node[:gitlab][:ci][:server_name] if node[:gitlab][:ci][:ci_enabled]

hosts_file_entry '127.0.0.1' do
  hostname 'localhost'
  aliases  local_aliases
  comment  "Set aliases for localhost"
end

