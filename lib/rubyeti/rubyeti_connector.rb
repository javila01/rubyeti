class RubyETI_connector
    def initialize
        @hydra = Typhoeus::Hydra.new(:max_concurrency => 20)
    end

    def connect username, password, session = "iphone"
        if session == "desktop"
            request = Typhoeus::Request.new("https://endoftheinter.net/index.php",
                            :method => :post,
                            :body   => "b=" + username + "&p=" + password)
        elsif session == "iphone"
            request = Typhoeus::Request.new("http://iphone.endoftheinter.net/",
                            :method => :post,
                            :body   => "username=" + username + "&password=" + password)
        else
            raise LoginError, "Invalid session argument"
        end

        @hydra.queue(request)
        @hydra.run

        response = request.response
	# checks for suspension
	body = response.body
	if body.partition("You are suspended.")[0] != ""
		raise LoginError, "You are suspended."
	end

	# gets the cookie
        @cookie = ""
        nextEntryIsCookie = false
        for header in response.headers
            for entry in header
                for piece in entry
                    if nextEntryIsCookie
                            cookie_value = piece.to_s.partition(';')[0]
                            @cookie += cookie_value + "; "
                    end
                end
                nextEntryIsCookie = false
                if entry == "Set-Cookie"
                    nextEntryIsCookie = true
                end
            end
        end
        true
    end

    def get_html url
        test_connection
        request = Typhoeus::Request.new(url,
                                        :method => :get,
                                        :headers => {'Cookie' => @cookie})
        @hydra.queue(request)
        @hydra.run
        if request.response.code != 200
            raise ETIError, "Failed to GET. URL = " + url.to_s + "\nCode = " + request.response.code.to_s
        end
        request.response.body
    end

    def post_html url, body
        test_connection
        request = Typhoeus::Request.new(url,
                                        :method => :post,
                                        :body   => body,
                                        :headers => {'Cookie' => @cookie})
        @hydra.queue(request)
        @hydra.run
        if request.response.code == 302
            request.response
        else
            raise TopicError, "Failed to POST. URL = " + url.to_s + "\nCode = " + request.response.code.to_s
        end

    end

    def upload_image image_path
        request = Typhoeus::Request.new("http://u.endoftheinter.net/u.php",
                                        :method => :post,
                                        :body => {:name => "file", :file => File.open(image_path, "r")},
                                        :headers => {'Cookie' => @cookie} )
        @hydra.queue(request)
        @hydra.run
        request.response
    end

    def queue url
        request = Typhoeus::Request.new(url,
                                        :method => :get,
                                        :headers => {'Cookie' => @cookie})
        @hydra.queue(request)
        request
    end

    def run
        start = Time.now
        @hydra.run
        puts Time.now - start
    end

    def test_connection
        request = Typhoeus::Request.new("http://archives.endoftheinter.net/showmessages.php?topic=1",
                        :method => :get,
                        :headers => {'Cookie' => @cookie})
        @hydra.queue(request)
        @hydra.run
        code = request.response.code
        if code != 200
            raise LoginError, "Not logged in to ETI"
        else 
            return true
        end
    end
end
