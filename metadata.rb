name             'gitlabhq'
maintainer       'Wide Eye Labs'
maintainer_email 'chris@wideeyelabs.com'
license          'MIT License'
description      'Installs/Configures Gitlab'
long_description IO.read(File.join(File.dirname(__FILE__), 'README.md'))
version          '0.1.0'

%w{ yumrepo ruby_build git redisio build-essential python readline sudo openssh perl xml zlib database mysql postgresql }.each do |dep|
    depends dep
end

%w{ debian ubuntu }.each do |os|
    supports os
end

