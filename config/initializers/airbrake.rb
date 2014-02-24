if ENV['CSVLINT_AIRBRAKE_KEY']
  Airbrake.configure do |config|
    config.api_key = ENV['CSVLINT_AIRBRAKE_KEY']
  end
end