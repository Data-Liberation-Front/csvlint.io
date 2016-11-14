require 'pusher'

# This is handled automatically in Heroku
if Rails.env.development?
  Pusher.app_id = ENV['PUSHER_APP_ID']
  Pusher.key = ENV['PUSHER_KEY']
  Pusher.secret = ENV['PUSHER_SECRET']
  Pusher.cluster = ENV['PUSHER_CLUSTER']
end
