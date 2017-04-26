require 'coveralls'
Coveralls.wear_merged!('rails')

# This file is copied to spec/ when you run 'rails generate rspec:install'
ENV["RAILS_ENV"] ||= 'test'
require File.expand_path("../../config/environment", __FILE__)
require 'rspec/rails'
#require 'rspec/autorun'

require 'webmock/rspec'
require 'database_cleaner'
require 'vcr'
require 'timecop'
# require 'csvlint'
require 'stored_csv'
require 'stored_chunk'
require 'fixture_helpers'
require 'sidekiq/testing'

ENV['AWS_ACCESS_KEY'] = 'fakeaccesskey'
ENV['AWS_SECRET_ACCESS_KEY'] = 'fakesecret'
ENV['AWS_BUCKET_NAME'] = 'buckethead'

DatabaseCleaner.strategy = :truncation

# Requires supporting ruby files with custom matchers and macros, etc,
# in spec/support/ and its subdirectories.
Dir[Rails.root.join("spec/support/**/*.rb")].each { |f| require f }

# Checks for pending migrations before tests are run.
# If you are not using ActiveRecord, you can remove this line.
ActiveRecord::Migration.check_pending! if defined?(ActiveRecord::Migration)

VCR.configure do |c|
  c.cassette_library_dir = 'spec/cassettes'
  c.default_cassette_options = { :record => :once }
  c.hook_into :webmock
  c.configure_rspec_metadata!
  c.ignore_request do |request|
    request.uri.match /(.+)?[example|gov]\..+/
  end
end

RSpec.configure do |config|
  include ActionDispatch::TestProcess


  #config.treat_symbols_as_metadata_keys_with_true_values = true

  config.before(:all) do
    Validation.create_indexes
    Fog.mock!
  end

  config.before(:each) do
    FogStorage.new.connection.directories.create(key: ENV['AWS_BUCKET_NAME'])
  end

  config.after(:each) do
    Fog::Mock.reset
  end

  WebMock.disable_net_connect!(:allow => [/static.(dev|theodi.org)/, /datapackage\.json/, /package_search/])
  # ## Mock Framework
  #
  # If you prefer to use mocha, flexmock or RR, uncomment the appropriate line:
  #
  # config.mock_with :mocha
  # config.mock_with :flexmock
  # config.mock_with :rr

  # If true, the base class of anonymous controllers will be inferred
  # automatically. This will be the default behavior in future versions of
  # rspec-rails.
  config.infer_base_class_for_anonymous_controllers = false

  # Run specs in random order to surface order dependencies. If you find an
  # order dependency and want to debug it, you can fix the order by providing
  # the seed, which is printed after each run.
  #     --seed 1234
  config.order = "random"

  config.after(:each) do
    DatabaseCleaner.clean
  end

  config.after(:all) do
    Validation.remove_indexes
  end


  # rspec-rails 3 will no longer automatically infer an example group's spec type
  # from the file location. You can explicitly opt-in to the feature using this
  # config option.
  # To explicitly tag specs without using automatic inference, set the `:type`
  # metadata manually:
  #
  #     describe ThingsController, :type => :controller do
  #       # Equivalent to being in spec/controllers
  #     end
  config.infer_spec_type_from_file_location!
end
