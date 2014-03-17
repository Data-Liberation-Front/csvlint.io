source 'https://rubygems.org'

ruby "2.1.0"
#ruby-gemset=csvlint

gem 'rails', '~> 4.0.2'
gem 'dotenv-rails'

# Use sqlite3 as the database for Active Record
gem 'sqlite3'

# Use SCSS for stylesheets
gem 'sass-rails', '~> 4.0.0'

# Use Uglifier as compressor for JavaScript assets
gem 'uglifier', '>= 1.3.0'

# Use CoffeeScript for .js.coffee assets and views
gem 'coffee-rails', '~> 4.0.0'

# See https://github.com/sstephenson/execjs#readme for more supported runtimes
gem 'therubyracer', platforms: :ruby

# Use jquery as the JavaScript library
gem 'jquery-rails'

# Turbolinks makes following links in your web application faster. Read more: https://github.com/rails/turbolinks
gem 'turbolinks'

# Build JSON APIs with ease. Read more: https://github.com/rails/jbuilder
gem 'jbuilder' #, '~> 1.2'

gem 'bootstrap-sass'

group :doc do
  # bundle exec rake doc:rails generates the API under doc/api.
  gem 'sdoc', require: false
end

gem 'foreman'

group :production do
  gem 'thin'
  gem 'mysql2'
end

group :development, :test do
  gem 'rspec-rails'
  gem 'cucumber-rails', require: false
  gem 'database_cleaner'
  gem 'coveralls', require: false
  gem 'guard-rspec'
  gem 'guard-cucumber'
  gem 'guard-bundler'
  gem 'webmock', require: false
  gem 'pry'
  gem 'timecop'
  gem 'factory_girl_rails'
  gem 'faker'
  gem 'poltergeist'
  gem 'vcr'
end

group :development do
  gem 'travis'
end

# Use ActiveModel has_secure_password
# gem 'bcrypt-ruby', '~> 3.1.2'

# Use unicorn as the app server
# gem 'unicorn'

# Use Capistrano for deployment
# gem 'capistrano', group: :development

# Use debugger
# gem 'debugger', group: [:development, :test]

gem 'rack-google-analytics'
gem 'mongoid', github: 'mongoid/mongoid'
gem 'mongoid-grid_fs', github: 'ahoward/mongoid-grid_fs'
gem 'bson_ext'
gem 'kaminari'
gem 'bootstrap-kaminari-views'
gem 'data_kitten', github: 'theodi/data_kitten'

gem 'csvlint', github: 'theodi/csvlint.rb'
gem 'rest-client'

gem 'nokogiri', '~> 1.5'

gem 'airbrake'
gem 'font-awesome-rails'