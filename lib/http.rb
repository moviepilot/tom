module Tom
  module Http

    # Makes a http request of the given method to the given url.
    # Passes the options on to EM::HttpRequest.put (or whatever
    # method has to be called) and does some error handling and
    # works around some EM:HttpRequest oddities (see handle_errors).
    #
    # @param method [Symbol] Request method, lowercase, you know
    #   the deal
    # @param url [String] Full url (e.g. host + path)
    # @param options [Hash] Options to pass to EM::HttpRequest's 
    #   get/put/post/delete method
    def self.make_request(method, url, options = {})
      Tom::Log.logger.info "     curl -X#{method.upcase} -d '#{options[:body]}' #{url}"

      conn = EM::HttpRequest.new(url, connection_options)
      result  = conn.send(method, options)
      handle_errors(method, url, result)

      result
    end

    private

    def self.connection_options
      { connect_timeout: Tom.config[:timeouts][:connect_timeout],
        inactivity_timeout: Tom.config[:timeouts][:inactivity_timeout]}
    end

    def self.handle_errors(method, url, result)
      result.errback do
        raise "Tom::Adapter.forward_request error '#{result.error}' for #{method} #{url}"
      end
      return unless result.response_header.status == 0
      raise "EM::HttpRequest returned response code 0 for #{url} - timeout?"
    end
  end
end
