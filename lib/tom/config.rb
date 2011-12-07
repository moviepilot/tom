module Tom

  # Don't use this module directly - access these methods
  # through {Tom} who does a `extend Tom::Config`
  module Config

    # @return [Hash] configuration
    def config
      @config || default_config
    end


    # @param config [Hash] The configuration you want 
    #   to set. Currently, only the `:timeout` key is 
    #   read, and in it the `:connect_timeout` and the
    #   `:inactivity_timeout` keys can be set to an int
    #   value (seconds)
    # @return [Hash] configuration
    def config=(config)
      @config = config
    end


    private

    def default_config
      { timeouts:
        { connect_timeout: 5,
          inactivity_timeout: 10 } }
    end
  end
end
