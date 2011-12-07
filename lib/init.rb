require 'bundler'
Bundler.require :default

# Init Goliath env unless it was done already
Goliath.env rescue Goliath.env = (ENV['RACK_ENV'] || 'development').to_sym

# In dev mode, we do some logging (defaults to Logger::ERROR in other
# envs)
if Goliath.env == :development || ENV['BOBS']
  Tom::LOG.level = Logger::INFO
end
Tom::LOG.info "Started goliath in #{Goliath.env} environment (change with ruby your_app.rb -e development or by setting $RACK_ENV)"

# Fetch the codes
require_relative 'goliath_api'
require_relative 'dispatcher'
require_relative 'adapter'
require_relative 'merger'
