# Include Remote Backup Handler
node[:gitlab][:backup][:remote][:handler].each do |bckhandler|
  include_recipe "gitlabhq::backup_#{bckhandler}"
end
