module Tom
  class Merger

    # Registers a route with the request dispatcher
    # so that this classes subclass gets called when
    # a request is made. One that matches the route.
    #
    # The route can be a string, but it becomes a 
    # regular expression in here. When matching in
    # order to find a merger for a request, the first
    # one matching wins.
    #
    # @param route [String] The route this Merger should 
    #   respond to.
    # @param methods [Array<Symbol>] Optional array of methods
    #   that this Merger is listening to. It defaults to
    #   all (`:head`, `:get`, `:put`, `:post`, `:delete`)
    def self.register_route(*args)
      route = args[0]
      methods = args[1..-1]
      Tom.register(route: /#{route}/, merger: self, methods: methods)
    end

    # When the request dispatcher made all the requests,
    # it will call the merge method of the subclass with
    # the responses as a hash in the form
    #
    # @param env [Array] The incoming (original request) 
    #   rack env object
    # @param responses [Hash] Replies from all Adapters that
    #   got triggered by route and method, e.g.
    #   `{MyAdapter: rack_env, MyOtherAdapter: other_env}`
    # @return [Array] A rack response (for example, something
    #   like [200, {}, "body"])
    def merge(env, responses)
      raise "Subclass, implement #merge(env, responses)!"
    end
  end
end
