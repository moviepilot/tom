module Tom
  module Routes

    # Registers a opts[:adapter] or opts[:merger] for the 
    # given opts[:route].
    #
    # This method should not be called directly, use register_route
    # in Tom::Adapter or Tom::Merger instead.
    #
    # @param opts [Hash] Needs to have at least `:route` and 
    #   either `:adapter` or `:merger` set, depending on what you
    #   are registering. But you don't need to use this method 
    #   directly, Adapter and Merger provide convenience methods
    #   for you.
    def register(opts)
      return register_adapter(opts) if opts[:adapter]
      return register_merger(opts)  if opts[:merger]
      raise "You need to supply opts[:adapter] or opts[:merger]"
    end

    #
    #  Registers an adapter for a given route and request method
    #
    def register_adapter(opts)
      validate_type(opts[:adapter], Adapter)
      methods = get_methods(opts)
      @adapters ||= default_methods_hash
      methods.each do |method|
        @adapters[method][opts[:route]] ||= []
        @adapters[method][opts[:route]] << opts[:adapter]
      end
    end

    #
    #  Registers merger for a given route and request method
    #
    def register_merger(opts)
      validate_type(opts[:merger], Merger)
      methods = get_methods(opts)
      @mergers ||= default_methods_hash
      methods.each do |method|
        @mergers[method][opts[:route]] ||= []
        @mergers[method][opts[:route]] << opts[:merger]
      end
    end

    #
    #  Fetches the methods from the options hash, defaults
    #  to all methods.
    #
    def get_methods(opts)
      return opts[:methods] unless opts[:methods].empty?
      [:head, :get, :put, :post, :delete]
    end

    #
    #  Just some defaults to initialize thing
    #
    def default_methods_hash
      { head:   {},
        get:    {},
        put:    {},
        post:   {},
        delete: {}
      }
    end

    #
    #  Find the right adapter for a route
    #
    def adapters_for_route(route, method)
      @adapters ||= default_methods_hash
      matches = []
      @adapters[method].map do |reg_route, adapters|
        next unless reg_route.match(route)
        matches += adapters
      end
      matches.uniq
    end

    #
    #  Find the right merger for a route
    #
    def merger_for_route(route, method)
      @mergers ||= default_methods_hash
      @mergers[method].each do |reg_route, mergers|
        next unless reg_route.match(route)
        return mergers.first
      end
      raise "Found no merger for route #{route}"
    end

    #
    #  Make sure one class is a subclass of another class
    #
    def validate_type(c, expected)
      return if c < expected
      raise "Invalid type. Expected #{expected} got #{c}"
    end
  end
end
