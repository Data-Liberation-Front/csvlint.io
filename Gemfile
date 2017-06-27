source 'https://rubygems.org'
ruby '2.4.1'

gem 'rake', '~> 11.0'
gem 'rails', '~> 4.2.9'
gem 'dotenv-rails'

# Use SCSS for stylesheets
gem 'sass-rails', '~> 5.0'

# Use Uglifier as compressor for JavaScript assets
gem 'uglifier', '>= 1.3.0'

# Use CoffeeScript for .js.coffee assets and views
gem 'coffee-rails', '~> 4.2.2'

# See https://github.com/sstephenson/execjs#readme for more supported runtimes
gem 'therubyracer', platforms: :ruby

# Use jquery as the JavaScript library
gem 'jquery-rails'

# Turbolinks makes following links in your web application faster. Read more: https://github.com/rails/turbolinks
gem 'turbolinks'

# Build JSON APIs with ease. Read more: https://github.com/rails/jbuilder
gem 'jbuilder', '~> 2.7'

gem 'sdoc', '~> 0.4.2', group: :doc

gem 'foreman'

group :production do
  gem 'thin'
  gem 'rails_12factor'
  gem 'puma'
end

group :development, :test do
  gem 'rspec-rails'
  gem 'cucumber-rails', require: false
  gem 'database_cleaner'
  gem 'coveralls', require: false
  gem 'simplecov', '~> 0.14.1'
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
  gem 'cucumber-api-steps', require: false, github: 'theodi/cucumber-api-steps', branch: 'feature-test-content-type'
  # Use sqlite3 as the database for Active Record
  gem 'sqlite3'
end

group :development do
  gem 'travis'
  gem 'web-console', '~> 3.3'
  gem 'spring'
end

# Use ActiveModel has_secure_password
# gem 'bcrypt-ruby', '~> 3.1.2'

# Use unicorn as the app server
# gem 'unicorn'

# Use Capistrano for deployment
# gem 'capistrano', group: :development

gem 'bootstrap-sass', '~> 3.1.1'
gem 'rack-google-analytics'
gem 'mongoid', '~> 5.1'
gem 'bson', '3.2.6'
gem 'mongoid-grid_fs', '~> 2.2'
gem 'bson_ext'
gem 'kaminari'
gem 'bootstrap-kaminari-views'
gem 'data_kitten', github: 'theodi/data_kitten', ref: "e343510bd15e3329c1f2fab35035e248195348be", require: false
gem 'rubyzip'

gem 'csvlint'
gem 'rest-client'

gem 'nokogiri', '~> 1.8'

gem 'airbrake'
gem 'font-awesome-rails'
gem 'sidekiq', '= 4.2.4'
gem 'data_uri'
gem 'jquery-dotdotdot-rails'
gem 'alternate_rails', github: 'theodi/alternate-rails', ref: 'v4.2.0'
gem 'rack-cors'

gem 'resumable_upload', github: "theodi/resumable-upload"
gem 'pusher'
gem 'cloudflare'
