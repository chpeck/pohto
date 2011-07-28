source 'http://rubygems.org'

gem 'rails', '3.0.5'
gem 'couchrest_model'
gem 'exifr'
gem 'paperclip'
gem 'guard'

group :development, :test do
  gem 'ruby-debug19', :require => 'ruby-debug'
end

# https://github.com/guard/guard/blob/master/Gemfile
require 'rbconfig'

if RbConfig::CONFIG['target_os'] =~ /darwin/i
  gem 'rb-fsevent', '>= 0.4.0', :require => false
end
if RbConfig::CONFIG['target_os'] =~ /linux/i
  gem 'rb-inotify', '>= 0.8.5', :require => false
end
