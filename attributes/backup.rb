
# BACKUP
default[:gitlab][:backup][:s3_region] = 'us-east-1'
default[:gitlab][:backup][:s3_bucket] = 'gitlab-repo-backups'
default[:gitlab][:backup][:s3_path]   = '/backups'
default[:gitlab][:backup][:s3_keep]   = 10
