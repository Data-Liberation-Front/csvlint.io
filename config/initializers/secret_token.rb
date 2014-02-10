# Be sure to restart your server when you modify this file.

# Your secret key is used for verifying the integrity of signed cookies.
# If you change this key, all old signed cookies will become invalid!

# Make sure the secret is at least 30 characters and all random,
# no regular words or you'll be exposed to dictionary attacks.
# You can use `rake secret` to generate a secure secret key.

# Make sure your secret_key_base is kept private
# if you're sharing your code publicly.
if Rails.env.production?
  raise "Session secret not set!" unless ENV['SESSION_SECRET_CSVLINT']
  Csvlint::Application.config.secret_key_base = ENV['SESSION_SECRET_CSVLINT']
else
  Csvlint::Application.config.secret_key_base = '85404c3f18e9b76d17eb1d38d01946aad4b7a9094e934c20a8ab1641d390de40ff5307b26c0af43696f88b2f44f5f5f9d006b65f217f8172d845d461ff0ba786'
end