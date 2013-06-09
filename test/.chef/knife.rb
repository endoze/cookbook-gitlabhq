current_dir = File.dirname(__FILE__)

cache_type    'BasicFile'
cache_options :path => "#{current_dir}/../../tmp/checksums"
cookbook_path ["#{current_dir}/../../cookbooks"]
