
# DEPENDENCIES
case node[:platform]
when 'ubuntu','debian'
  default[:gitlab][:packages] = %w{
    ruby1.9.1 ruby1.9.1-dev ri1.9.1 libruby1.9.1
    curl wget checkinstall libxslt-dev libsqlite3-dev
    libcurl4-openssl-dev libssl-dev libmysql++-dev
    libicu-dev libc6-dev libyaml-dev nginx python python-dev
  }
when 'redhat','centos','amazon','scientific'
  case node[:platform_version].to_i
  when 5
    default[:gitlab][:packages] = %w{
      curl wget libxslt-devel sqlite-devel openssl-devel
      mysql++-devel libicu-devel glibc-devel libyaml-devel
      nginx python26 python26-devel
    }
  when 6
    default[:gitlab][:packages] = %w{
      curl wget libxslt-devel sqlite-devel openssl-devel
      mysql++-devel libicu-devel glibc-devel
      libyaml-devel nginx python python-devel
    }
  end
else
  default[:gitlab][:packages] = %w{
    ruby1.9.1 ruby1.9.1-dev ri1.9.1 libruby1.9.1
    curl wget checkinstall libxslt-dev libsqlite3-dev
    libcurl4-openssl-dev libssl-dev libmysql++-dev
    libicu-dev libc6-dev libyaml-dev nginx python
    python-dev
  }
end

default[:gitlab][:install_ruby] = '1.9.3-p392'
default[:gitlab][:ruby_dir]     = "/usr/local/ruby/#{node[:gitlab][:install_ruby]}/bin"
