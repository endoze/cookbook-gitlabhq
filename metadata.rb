name             'gitlabhq'
maintainer       'Wide Eye Labs'
maintainer_email 'chris@wideeyelabs.com'
license          'MIT License'
description      'Installs/Configures Gitlab'
long_description IO.read(File.join(File.dirname(__FILE__), 'README.md'))
version          '6.0.1'

depends 'build-essential'
depends 'readline'
depends 'sudo'
depends 'openssh'
depends 'xml'
depends 'zlib'
depends 'python'
depends 'redisio'
depends 'ruby_build'
depends 'mysql'
depends 'postgresql'
depends 'database'
depends 'backup'
depends 'hostsfile'
depends 'nginx'
depends 'git'

%w{ debian ubuntu }.each do |os|
    supports os
end

