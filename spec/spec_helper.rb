require 'coveralls'
Coveralls.wear_merged!('rails')

# This file is copied to spec/ when you run 'rails generate rspec:install'
ENV["RAILS_ENV"] ||= 'test'
require File.expand_path("../../config/environment", __FILE__)
require 'rspec/rails'
require 'rspec/autorun'

require 'webmock/rspec'
require 'database_cleaner'
require 'vcr'
require 'timecop'

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
end

RSpec.configure do |config|
  include ActionDispatch::TestProcess
  
  config.treat_symbols_as_metadata_keys_with_true_values = true
  
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
end

def load_fixture(filename)
  File.read(File.join(Rails.root, 'fixtures', filename))
end

def mock_file(url, file, content_type = "text/csv")
  stub_request(:get, "http://example.org/api/2/rest/dataset/#{url.split("/").last}").to_return(:status => 404, :body => "", :headers => {})
  stub_request(:get, "http://example.com/api/3/action/package_show?id=#{url.split("/").last}").to_return(:status => 404, :body => "", :headers => {})
  stub_request(:get, url).to_return(body: load_fixture(file), headers: {"Content-Type" => "#{content_type}; charset=utf-8; header=present"})
  stub_request(:head, url).to_return(:status => 200)
end

def mock_upload(file, content_type = "text/csv")
  upload_file = fixture_file_upload(File.join(Rails.root, 'fixtures', file), content_type)
  class << upload_file
    # The reader method is present in a real invocation,
    # but missing from the fixture object for some reason (Rails 3.1.1)
    attr_reader :tempfile
  end
  upload_file
end
  
