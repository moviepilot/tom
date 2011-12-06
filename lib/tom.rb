require_relative 'init'

# Init Goliath env unless it was done already
Goliath.env rescue Goliath.env = (ENV['RACK_ENV'] || 'development').to_sym

# In dev mode, we do some logging (defaults to Logger::ERROR in other
# envs)
if Goliath.env == :development || ENV['BOBS']
  Tom::LOG.level = Logger::INFO
end
Tom::LOG.info "Started goliath in #{Goliath.env} environment (change with ruby your_app.rb -e development or by setting $RACK_ENV)"

module Tom

  def self.config
    @config || default_config
  end

  def self.config=(config)
    @config = config
  end

  #
  #  WE HAZ ALL TEH GOLIATH REQUESTS AND FORWARDETH
  #  THEM TO DEH DISPATCHERETH.
  #
  #  We have to see if this is the right way to do
  #  it when it comes to parallel stuff and so on...
  #
  class GoliathAPI < Goliath::API
    use Goliath::Rack::Render

    def response(env)
      begin
        Tom::Dispatcher.dispatch(env)
      rescue => e
        handle_exception e, env
      end
    end

    def handle_exception(e, env)
      trace = e.backtrace.join "\n"
      Tom::LOG.info e
      Tom::LOG.info trace
      [500, {}, {error: e,
        stacktrace: trace,
        url:        env["REQUEST_URI"]
      }.to_json]
    end
  end

  private

  def self.default_config
    { timeouts:
        { connect_timeout: 5,
          inactivity_timeout: 10 } }
  end
end
