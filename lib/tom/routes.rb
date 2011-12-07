module Tom

  # Takes care of registering adapters and mergers for routes,
  # and then matching routes and methods to adapters and mergers.
  module Routes

    # Registers a opts[:adapter] or opts[:merger] for the
    # given opts[:route].
    #
    # This method should not be called directly in your app, you
    # would use {Tom::Adapter.register_route} or
    # {Tom::Merger.register_route} in your subclass of {Tom::Adapter}
    # or {Tom::Merger}
    #
    # @param opts [Hash] Needs to have at least :route and
    #   either :adapter or :merger set, depending on what you
    #   are registering. But you don't need to use this method
    #   directly, Adapter and Merger provide convenience methods
    #   for you.
    #
    # @return [Hash] See {Tom::Routes.register_adapter} or
    #   {Tom::Routes.register_merger}
    def self.register(opts)
      return register_adapter(opts) if opts[:adapter]
      return register_merger(opts)  if opts[:merger]
      raise "You need to supply opts[:adapter] or opts[:merger]"
    end

    # Registers an {Adapter} for a given route and request method
    #
    # @param opts [Hash] Needs to have the :route and :adapter
    #   keys set with a regular expression and a subclass of
    #   {Tom::Adapter}
    #
    # @return [Hash] First level are the HTTP methods, second
    #   level are the regular expressions for routes, and the
    #   values are arrays of Adapters for the combination of
    #   request method and route.
    def self.register_adapter(opts)
      validate_type(opts[:adapter], Adapter)
      methods = get_methods(opts)
      @adapters ||= default_methods_hash
      methods.each do |method|
        @adapters[method][opts[:route]] ||= []
        @adapters[method][opts[:route]] << opts[:adapter]
      end
      @adapters
    end

    # Registers a {Merger} for a given route and request method
    #
    # @return [Hash] First level are the HTTP methods, second
    #   level are the regular expressions for routes, and the
    #   values are arrays of Mergers for the combination of
    #   request method and route.
    def self.register_merger(opts)
      validate_type(opts[:merger], Merger)
      methods = get_methods(opts)
      @mergers ||= default_methods_hash
      methods.each do |method|
        @mergers[method][opts[:route]] ||= []
        @mergers[method][opts[:route]] << opts[:merger]
      end
      @mergers
    end

    # @return [Hash] See what {Tom::Routes.register_adapter} returns
    def self.adapters
      @adapters
    end

    # @return [Hash] See what {Tom::Routes.register_merger} returns
    def self.mergers
      @mergers
    end

    private

    # Fetches the methods from the options hash, defaults
    # to all methods.
    #
    # @param opts [Hash] We're looking for :methods in this hash
    #
    # @return [Hash] Returns what's in :methods, and defaults to
    #   [:head, :get, :put, :post, :delete]
    def self.get_methods(opts)
      return opts[:methods] unless opts[:methods].empty?
      [:head, :get, :put, :post, :delete]
    end

    #
    #  Just some defaults to initialize thing
    #
    def self.default_methods_hash
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
    def self.adapters_for_route(route, method)
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
    def self.merger_for_route(route, method)
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
    def self.validate_type(c, expected)
      return if c < expected
      raise "Invalid type. Expected #{expected} got #{c}"
    end
  end
end
