# Be sure to restart your server when you modify this file.

# Your secret key for verifying cookie session data integrity.
# If you change this key, all old sessions will become invalid!
# Make sure the secret is at least 30 characters and all random, 
# no regular words or you'll be exposed to dictionary attacks.
ActionController::Base.session = {
  :key         => '_playparty-video_session',
  :secret      => '0c74930e9d7af6adf12494b04d48b9b4fe8ff745fec1674c8c91f917db269d9c01e4e2cefca188c0c1d94cf36e1c068d2f2a06ad58b9af5e0704893a3a6362e2'
}

# Use the database for sessions instead of the cookie-based default,
# which shouldn't be used to store highly confidential information
# (create the session table with "rake db:sessions:create")
# ActionController::Base.session_store = :active_record_store
