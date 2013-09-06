node[:gitlab][:backup][:handler].each do |bckhandler|
  include_recipe "gitlabhq::backup_#{bckhandler}"
end
