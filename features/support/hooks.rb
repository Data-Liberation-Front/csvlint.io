require 'csvlint'

Before ('@data_expiry') do
  # Mongoid only supports a truncation strategy, which means that any indices created will persist - the following code
  # flushes the indices on the Validation model
  Validation.remove_indexes
  Validation.create_indexes
end

After('@rackmock') do
  RackMock.reset
end

Before('@revalidate') do
  @connection = double(CloudFlare::Connection)

  allow(CloudFlare::Connection).to receive(:new) {
    allow(@connection).to receive(:zone_file_purge)
    @connection
  }
end

After do
  Sidekiq::Extensions::DelayedClass.jobs.clear
end

Before('@javascript') do
  Sidekiq::Testing.inline!
end

After('@javascript') do
  Sidekiq::Testing.fake!
end
