require 'em-synchrony/em-http'
require_relative 'http'

module Tom
  class Adapter
    class << self
      attr_accessor :host
    end

    #
    #  Registers a route with the request dispatcher
    #  so that this classes subclass gets called when
    #  a request is made. One that matches the route.
    #
    #  The route can be a string, but it becomes a 
    #  regular expression in here, followed by methods.
    #
    def self.register_route(*args)
      route = args[0]
      methods = args[1..-1]
      Dispatcher.register(route: /#{route}/, adapter: self, methods: methods)
    end

    def initialize
      @request = {}
    end

    #
    #  Takes a request from rack and issues the same
    #  request again, just to a different host. This
    #  method is to be used by subclasses.
    #
    def forward_request(env)
      rewrite_request(env)
      options = http_request_options(env)
      url = @request[:host] + @request[:uri]

      result = Tom::Http.make_request(@request[:method], url, options)

      headers = {"Downstream-Url" => url}.merge result.response_header
      [result.response_header.status, headers, result.response]
    end

    #
    #  Takes a request and generates the options for calling
    #  HttpRequest.put (or whatever the the requested
    #  REQUEST_METHOD is).
    #
    #  It's content depends on the request method, for PUTs
    #  and POSTs this will add the request body
    #
    def http_request_options(env)
      opts = {}
      if [:put, :post].include? @request[:method]
        opts[:body] = @request[:body] || extract_request_body(env)
      end
      opts
    end

    #
    #  Extracts the given POT/PUST (hehe) body
    #
    def extract_request_body(env)
      Rack::Request.new(env).POST.keys.first rescue "{}"
    end

    #
    #  Takes a request from rack and extracts the request
    #  method, uri and returns the host this adapter talks
    #  to. Can be overwritten if you want to change stuff
    #  before forwarding it.
    #
    def rewrite_request(env)
      rewritten = rewrite_host(env)
      @request = rewritten.merge(@request)
    end

    def handle(env)
      raise "Subclass, implement #handle(env)!"
    end

    private

    #
    #  Returns a hash that can be used as the @request variable,
    #  which is exactly like the given env except for a changed
    #  hostname.
    #
    def rewrite_host(env)
      { host:   self.class.host,
        uri:    env["REQUEST_URI"],
        method: env["REQUEST_METHOD"].downcase.to_sym
      }
    end
  end
end
