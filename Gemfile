source 'https://rubygems.org'

gem 'rails', '~> 4.0.12'
gem 'dotenv-rails'

# Sprockets pinned to avoid a problem in 2.12.3 with our stylesheets
gem "sprockets", "~> 2.11.3"

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

gem 'bootstrap-sass', '~> 3.1.1'

group :doc do
  # bundle exec rake doc:rails generates the API under doc/api.
  gem 'sdoc', require: false
end


gem 'foreman', "< 0.65.0"

group :production do
  gem 'thin'
  gem 'mysql2'
end

group :development, :test do
  gem 'rspec-rails'
  gem 'cucumber-rails', require: false
  gem 'database_cleaner'
  gem 'coveralls', require: false
  gem 'simplecov', '~> 0.7.1'
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
  gem 'resumable_upload', '0.0.1', github: "theodi/resumable-upload"
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
gem 'mongoid'
gem 'bson', '3.1.1'
gem 'mongoid-grid_fs', github: 'ahoward/mongoid-grid_fs'
gem 'bson_ext'
gem 'kaminari'
gem 'bootstrap-kaminari-views'
gem 'data_kitten', github: 'theodi/data_kitten', ref: "e343510bd15e3329c1f2fab35035e248195348be"
gem 'rubyzip'

gem 'csvlint'
gem 'rest-client'

gem 'nokogiri', '~> 1.5'

gem 'airbrake'
gem 'font-awesome-rails'
gem 'delayed_job_mongoid', github: 'collectiveidea/delayed_job_mongoid'
gem 'data_uri'
gem 'jquery-dotdotdot-rails'
gem 'alternate_rails', github: 'theodi/alternate-rails'
gem 'rack-cors'
gem 'byebug'
