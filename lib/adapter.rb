require 'em-synchrony/em-http'
require_relative 'http'

module Tom

  # Please see the {https://github.com/moviepilot/tom#readme README} for
  # examples on how to use this.
  #
  # @attribute host [String] The hostname this adapter is connecting to (the
  #   "other" API endpoint).
  class Adapter
    class << self
      attr_accessor :host
    end

    # Registers a route with the request dispatcher
    # so that this classes subclass gets called when
    # a request is made. One that matches the route.
    #
    # The route can be a string, but it becomes a 
    # regular expression in here, followed by methods.
    #
    # @param route [String] The route this Adapter should 
    #   respond to.
    #
    # @param methods [Array<Symbol>] Optional array of methods
    #   that this Adapter is listening to. It defaults to
    #   all (:head, :get, :put, :post, :delete)
    #
    # @return [Hash] See {Tom::Routes.register}
    def self.register_route(*args)
      route = args[0]
      methods = args[1..-1]
      Tom::Routes.register(route: /#{route}/, adapter: self, methods: methods)
    end

    def initialize
      @request = {}
    end

    # Takes a request from rack and issues the same
    # request again, just to a different host. This
    # method is to be used by subclasses.
    #
    # @param env [Array] The incoming (original request) 
    #   rack env object
    #
    # @return [Array] Your beloved triple of [status_code, headers,
    #   response_body]
    def forward_request(env)
      rewrite_request(env)
      options = http_request_options(env)
      url = @request[:host] + @request[:uri]

      result = Tom::Http.make_request(@request[:method], url, options)

      headers = {"Downstream-Url" => url}.merge result.response_header
      [result.response_header.status, headers, result.response]
    end

    # Takes a request and generates the options for calling
    # HttpRequest.put (or whatever the the requested
    # REQUEST_METHOD is).
    #
    # It's content depends on the request method, for PUTs
    # and POSTs this will add the request body
    #
    # @param env [Array] A rack env object
    #
    # @return [Hash] Has the value of @request[:body] inside its
    #   :body key, but only when the request method in the given
    #   env matches :put or :post
    def http_request_options(env)
      opts = {}
      if [:put, :post].include? @request[:method]
        opts[:body] = @request[:body] || extract_request_body(env)
      end
      opts
    end

    # Extracts the given POT/PUST (hehe) body. Overwrite this
    # if you want to do your own thing (e.g. if the params middleware
    # made the params an object, you should return a string here as
    # this is what we feed into the EM::HttpRequest
    #
    # @param env [Array] A rack env object
    #
    # @return [Hash] Returns whatever the client POSTed/PUT and defaults
    #   to an empty hash (while debugging, consider your middlewares,
    #   they might touch this depending on the Content-Type)
    def extract_request_body(env)
      Rack::Request.new(env).POST rescue {}
    end

    # Takes a request from rack and extracts the request
    # method, uri and returns the host this adapter talks
    # to. Can be overwritten if you want to change stuff
    # before forwarding it.
    #
    # @param env [Array] A rack env object
    #
    # @return [Hash] The @request variable
    def rewrite_request(env)
      rewritten = rewrite_host(env)
      @request = rewritten.merge(@request)
    end

    # Subclasses must implement this method to handle incoming
    # requests
    #
    # @param env [Array] The incoming (original request) 
    #   rack env object
    #
    # @return [void] This mofo raises and never returns anything.
    def handle(env)
      raise "Subclass, implement #handle(env)!"
    end

    private

    # Returns a hash that can be used as the @request variable,
    # which is exactly like the given env except for a changed
    # hostname.
    #
    # @param env [Array] A rack env object
    #
    # @return [Hash] With :host, :uri and :method
    def rewrite_host(env)
      { host:   self.class.host,
        uri:    env["REQUEST_URI"],
        method: env["REQUEST_METHOD"].downcase.to_sym
      }
    end
  end
end
