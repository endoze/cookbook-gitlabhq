include_recipe 'backup'

aws_credentials = data_bag_item('credentials', 'aws_credentials')

# Create a Backup Gem Model for
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
