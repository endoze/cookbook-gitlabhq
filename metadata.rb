name             'gitlabhq'
maintainer       'Wide Eye Labs'
maintainer_email 'chris@wideeyelabs.com'
license          'MIT License'
description      'Installs/Configures Gitlab'
long_description IO.read(File.join(File.dirname(__FILE__), 'README.md'))
version          '0.5.1'

depends 'backup'
depends 'build-essential'
depends 'database'
depends 'hosts_file'
depends 'mysql'
depends 'nginx'
depends 'postgresql'
depends 'python'
depends 'readline'
depends 'redisio'
depends 'rvm'
depends 'sudo'
depends 'xml'
depends 'zlib'

%w{ debian ubuntu }.each do |os|
    supports os
end

