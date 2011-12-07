module Tom
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
end
