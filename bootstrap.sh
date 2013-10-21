if [ ! -e .bootstrapped ]
then
  touch .bootstrapped
  sudo apt-get update
  sudo apt-get install -y build-essential
  sudo apt-get install -y vim
  gem install chef --version '>= 11.6.0' --no-ri --no-rdoc --conservative
fi
