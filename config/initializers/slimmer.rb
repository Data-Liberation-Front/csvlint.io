Csvlint::Application.configure do
  unless ENV['GOVUK_APP_DOMAIN']
    config.slimmer.asset_host = 'http://static.theodi.org'
  end
end