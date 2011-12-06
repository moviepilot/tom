![Tom Smykowski](http://dl.dropbox.com/u/1953503/tom%20smykowsky.jpg)
# Tom Smykowski - I have people skills!

Tom Smykowski, Tom for short, is a gem that takes the specifications from the customers and brings them down to the engineers. He has people skills. He is good at dealing with people. If this does not make sense to you, please refer to [this introductory video](http://www.youtube.com/watch?v=mGS2tKQhdhY) and, of course, [the movie](http://www.imdb.com/video/screenplay/vi3215851801/).

To go into technical detail: Tom uses [Goliath](http://goliath.io) to dispatch HTTP requests to multiple other APIs (via `Adapter`s) in parallel. In a next step, a `Merger` merges the result and responds to the clients request.

All you have to do is define some `Adapter`s that get activated for certain routes and some `Merger`s for certain routes.

As you have seen in the video above, Tom Smykowski talks extra much when
consultants are present who might fire him. So this gem will log to
STDOUT when you're in development mode or the BOBS environment variable
is set. Useful for debugging, but nothing you really want in
production/testing.

# TL;DR

The general flow goes like this:

     TIME            Request
      |                 |
      |             Dispatcher
      |      .__________|___________.
      |      |          |           |
      |    Adapter1  Adapter3   AdapterN   (in parallel)
      |      |________. | ._________|
      |               | | |
      |               Merger
      |                 |
      V             Response

So per request there can be many `Adapter`s that talk to different APIs, and one `Merger` that combines the responses of all APIs to one response.

# How to use
## Tom::Dispatcher

This class basically does what is pictured in the flow above:

1. Take the request
2. Find all `Adapter`s that registered for a matching route
3. Dispatch the requests to them
4. Collect results
5. Merge results into one and respond

To add APIs or change the behavior of Tom, you don't have to touch this class, though. `Adapter` and `Merger` is what you're looking for.

## Tom::Adapter

The `Adapter` class comes with the class methods:

- `host=` (set the api to talk to)
- `rewrite_request` (overwrite if you don't want to pass on URIs 1:1)
- `forward_request` (takes env, calls the `rewrite_request` method and returns the result)

To hook Tom up to an API, you would first create an `Adapter` that inherits from the `Tom::Adapter` class, register some routes (they become regular expressions) and finally implement the logic by overwriting the `handle` method:

    class Sheldon < Tom::Adapter
      register_route "/nodes/*"

      def self.handle(env)
        # Insert biz logic here
        forward_request(env)
      end
    end

The handle method takes a rack env, does some stuff like removing things that are not needed in Sheldon and then forwards the request on to the API.

In your initializer you can configure `Adapter`s like this:

    Sheldon.host = 'http://localhost:9292'

This causes the aforementioned `rewrite_request` method to use that host name. The `forward_request` method uses an instance variable called `@request` to know what to do. `rewrite_request`, for example, takes a rack env and initializes `@request` with `:host`, `:method` and `:uri`.

If the method is `POST` or `PUT`, then you should also set the appropriate `@request[:body]` if you want to use the automatic `forward_request` method.

## Tom::Merger

`Mergers` work very similar to `Adapter`s. But all you have to do here is subclass it and implement the `merge` method. For example we could create a `Merger` that always ignores everything and just returns the response from Sheldon:

    class OnlySheldon < Tom::Merger

      register_route "^/nodes/[0-9]+$"

      def self.merge(env, responses)
        responses[Sheldon]
      end
    end

You can use the rack `env` to decide what to do, and you get a hash of `responses` that has the Adapter class as keys and their respective rack `responses``:

    { MyAdapter      => [[200,{},"first response" ],
                         [200,{},"second response"]],
      MyOtherAdapter => […]
    }

## On registering routes

If you call

    class Foo < Tom::Adapter
      register_route "^/nodes/[0-9]+$"
      …
    end

the adapter will be registered for all methods (namely `head`, `get`, `put`, `post`, `delete`). If you just want to register for some methods, you can do that with

    register_route "^/nodes/[0-9]_$", :get, :put

Same goes for mergers.

# Todo

- handle adapter errors/states in mergers
- register routes with concurrency on and off
- use Goliath::Rack::Params
- use Goliath::Rack::Heartbeat
- think about consensus protocols
- ...
