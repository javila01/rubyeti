class RubyETI_connector
    def initialize
        @hydra = Typhoeus::Hydra.new(:max_concurrency => 20)
        @cookie = ""
    end

    def connect username, password, session = "iphone"
        if session == "desktop"
            request = Typhoeus::Request.new("https://endoftheinter.net/index.php",
                            :method => :post,
                            :body   => "b=" + username + "&p=" + password,
                            :headers => {'User-Agent' => 'rubyeti'})
        elsif session == "iphone"
            request = Typhoeus::Request.new("http://iphone.endoftheinter.net/",
                            :method => :post,
                            :body   => "username=" + username + "&password=" + password,
                            :headers => {'User-Agent' => 'rubyeti'})
        else
            raise SessionError, "Invalid session argument"
        end

        @hydra.queue(request)
        
        request.on_complete do
            response = request.response
            # checks for suspension
            body = response.body
            if body.to_s.partition("You are suspended.")[1] != ""
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
                    if entry == "set-cookie" || entry == "Set-Cookie"
                        nextEntryIsCookie = true
                    end
                end
            end
            return true
        end

        @hydra.run
    end

    def get_html url
        #test_connection
        request = Typhoeus::Request.new(url,
                                        :method => :get,
                                        :headers => {'Cookie' => @cookie, 'User-Agent' => 'rubyeti'})
        @hydra.queue(request)
        done = false
        request.on_complete do
            if request.response.code != 200
                raise ETIError, "Failed to GET. URL = " + url.to_s + "\nCode = " + request.response.code.to_s
            end
            done = true
        end
        @hydra.run
        while !done
        end
        request.response.body
    end

    def post_html url, body = ""
        #test_connection
        request = Typhoeus::Request.new(url,
                                        :method => :post,
                                        :body   => body,
                                        :headers => {'Cookie' => @cookie, 'User-Agent' => 'rubyeti'})
        @hydra.queue(request)
       
        request.on_complete do |response|
            return request.response
        end

        @hydra.run
    end

    def upload_image image_path
        request = Typhoeus::Request.new("http://u.endoftheinter.net/u.php",
                                        :method => :post,
                                        :body => {:name => "file", :file => File.open(image_path, "r")},
                                        :headers => {'Cookie' => @cookie, 'User-Agent' => 'rubyeti'} )
        @hydra.queue(request)

        request.on_complete do |response|
            return request.response
        end

        @hydra.run
    end

    def queue url
        request = Typhoeus::Request.new(url,
                                        :method => :get,
                                        :headers => {'Cookie' => @cookie, 'User-Agent' => 'rubyeti'})
        @hydra.queue(request)
        request
    end

    def run
        @hydra.run
    end

    def test_connection
        request = Typhoeus::Request.new("http://endoftheinter.net/stats.php",
                                        :method => :get,
                                        :headers => {'Cookie' => @cookie, 'User-Agent' => 'rubyeti'})
        @hydra.queue(request)
        
        request.on_complete do |response|
            code = request.response.code
            if code != 200
                raise LoginError, "Not logged in to ETI"
            else 
                return true
            end
        end
        @hydra.run
    end
end
