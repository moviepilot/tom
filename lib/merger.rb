module Tom
  class Merger

    #
    #  Registers a route with the request dispatcher
    #  so that this classes subclass gets called when
    #  a request is made. One that matches the route.
    #
    #  The route can be a string, but it becomes a 
    #  regular expression in here. When matching in
    #  order to find a merger for a request, the first
    #  one matching wins.
    #
    def self.register_route(*args)
      route = args[0]
      methods = args[1..-1]
      Dispatcher.register(route: /#{route}/, merger: self, methods: methods)
    end

    #
    #  When the request dispatcher made all the requests,
    #  it will call the merge method of the subclass with
    #  the responses as a hash in the form
    #
    #  {MyAdapter: rack_env, MyOtherAdapter: other_env}
    #
    #  Has to return a rack response (for example, something
    #  like [200, {}, "body"])
    #
    def merge(env, responses)
      raise "Subclass, implement #merge(env, responses)!"
    end
  end
end
