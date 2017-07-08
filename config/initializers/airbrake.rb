if ENV['AIRBRAKE_API_KEY']
  Airbrake.configure do |config|
    config.project_id = ENV['AIRBRAKE_PROJECT_ID']
    config.project_key = ENV['AIRBRAKE_API_KEY']
  end
end