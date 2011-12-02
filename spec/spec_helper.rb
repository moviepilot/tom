require 'bundler'

Bundler.setup
Bundler.require :default, :test

require 'goliath/test_helper'
require 'ruby-debug'
require 'webmock/rspec'

Goliath.env = :test
RSpec.configure do |c| 
  c.include Goliath::TestHelper, :example_group => {
    :file_path => /spec/
  }
end

RSpec.configure do |config|
  # Until we figured out the Webmock/em-synchrony/em-http-request woes
  config.before(:suite) do
    WebMock.allow_net_connect!
  end

  config.before(:each) do
    # I don't always make http requests. But when I do, 
    # they are successful.
    stub_request(:any, /.*webmocked-host.*/)
  end

  config.after(:each) do
    EM.stop rescue nil
  end

end

require_relative '../lib/tom'

class Merger < Tom::Merger
  register_route ".*"
  def merge(a,b);[200, {}, ""]; end
end
