#!/usr/bin/env ruby
require 'rubygems'
require 'curb'
require 'nokogiri'

class ETI
	# logs a user into the site with their credentials
	# with the session they specify
	# should return true or false based on login success
	def login(username, password, session)
	end

	# posts a topic with the specified name and content. sig is NOT automatically appended yet
	# posts to the LUE tag only at the moment
	def post_topic(topic_name, topic_content)
	end

	# retrieves a topic by id
	# should return a topic object on success, or a failure indicator on fail. does not yet, just returns 
	# topic object on success
	def get_topic_by_id(id)
	end

	# returns true if the user with userid specified is online
	# and false if not
	def is_user_online(userid)
	end

	# creates a new private message thread with the user specified by the userid user
	# does NOT send your sig automatically
	# only works with userids currently
	def create_private_message(user, subject, message)
	end
end

class ETI

	def initialize
		@login = false
	end

	def login(username, password, session="iphone")

		# sets up the target connection url and post fields based on whether
		# the user wants a desktop or mobile eti session
		if session=="desktop"
			@connection = Curl::Easy.new("https://endoftheinter.net/index.php")
			post_field = "b=" + username + "&p=" + password
		elsif session=="iphone"
			@connection = Curl::Easy.new("http://iphone.endoftheinter.net/")
			post_field = "username=" + username + "&password=" + password
		else return false, "invalid session"
		end

		# allows cookies, so we can stay logged into eti
		@connection.enable_cookies = true

		# posts to the login page my username and password
		@connection.http_post(post_field)
		
		# tests to see if the login succeeded
		@connection.url = "http://archives.endoftheinter.net/showmessages.php?topic=1"
		@connection.http_get
		html_source = @connection.body_str
		if html_source.size==0 
			@login = false
			return false, "bad login"
		else 
			@login = true
			return true
		end
		
	end

	def post_topic(topic_name, topic_content)
		# checks to see if the user is logged in
		if(!@login)
			return false, "not logged in"
		end
		@connection.url = "http://boards.endoftheinter.net/postmsg.php?tag=LUE"
		post_field = "title=" + topic_name + "&tag=LUE&message=" + topic_content + "&h=9adb9&submit=Post Message"
		@connection.http_post(post_field)
	end

	def get_topic_by_id(id)
		if(!@login) 
			return false, "not logged in"
		end
		# sets the curl object url to a page on eti i want to get
		url = "http://archives.endoftheinter.net/showmessages.php?topic=" + id.to_s
		@connection.url = url
		# gets the post
		@connection.http_get

		# creates a new topic to store the data in
		t = Topic.new

		html_source = @connection.body_str
		# creates a nokogiri object for parsing the topic
		html_doc = Nokogiri::HTML(html_source)


		# checks to see if the topic is getting a redirect,
		# redirects from invalid archive topics simply give a blank
		# html_source
		if(html_source.size==0) 
			url = "http://boards.endoftheinter.net/showmessages.php?topic=" + id.to_s
			@connection.url = url
			@connection.http_get
			html_source = @connection.body_str
			if(html_source.size==0)
				return false, "invalid topic id"
			end
			html_doc = Nokogiri::HTML(html_source)
		end

		# gets the topic id
		suggest_tag_link = html_doc.xpath('//a[contains(@href, "edittags.php")]')
		link = suggest_tag_link[0]["href"]
		link = link.partition("=")[2]
		t.topic_id = link.to_i

		# gets the topic title
		t.topic_title = html_doc.xpath('//h1').text

		# gets a list of the posters
		posters = html_doc.xpath('//div[@class = "message-container"]/div/a[contains(@href, "/profile.php?user=")]')
		
		# gets a list of the timestamps. these are still embedded in other text, the for loop
		# takes care of extracting them
		timestamps = html_doc.xpath('//div[@class = "message-container"]/div')

		# gets a list of the link nodes with message_id
		# its embedded in the href, the for loop extracts it
		messages = html_doc.xpath('//div[@class = "message-container"]/div/a[contains(@href, "message.php?id=")]')

		# gets the content of the posts
		contents = html_doc.xpath('//td[@class = "message"]')

		# gets the first page of posts
		i = 0
		for p in posters
			poster = p.text

			timestamp = timestamps[i].text
			timestamp = timestamp.partition("Posted:")[2]
			timestamp = timestamp.partition("|")[0]

			message_id = messages[i]["href"]
			message_id = message_id.partition("=")[2]
			message_id = message_id.partition("&")[0]

			content = contents[i].text

			t.posts[i] =  Post.new(poster, timestamp, message_id, i+1, content)
			i += 1
		end
		puts t.to_s
		return t

	end

	def is_user_online(userid)
		@connection.url = "http://endoftheinter.net/profile.php?user=" + userid.to_s
		@connection.http_get
		html_source = @connection.body_str
		html_parse = Nokogiri::HTML(html_source)
		online_now = html_parse.xpath('//td[contains(text(), "online now")]');
		if online_now.size == 0
			return false
		else
			return true
		end
	end

	def create_private_message(user, subject, message)
		if(!@login)
			return false, "not logged in"
		end
		# this block is to get the "h" value from the post message page
		# this seems to be unique to each user, not sure exactly how
		# so for now im just loading up the new PM thread page and grabbing it
		# from the html source
		@connection.url = "http://endoftheinter.net/postmsg.php?puser=" + user.to_s
		@connection.http_get
		html_source = @connection.body_str
		html_doc = Nokogiri::HTML(html_source)
		hash_field = html_doc.xpath('//input[@name = "h"]')
		hash = hash_field[0]["value"]

		# posts the pm information to the connection
		# DOES NOT send your sig automatically
		@connection.url = "http://endoftheinter.net/postmsg.php"
		post_field = "puser=" + user.to_s + "&title=" + subject.to_s + "&message=" + message.to_s + "&h=" + hash.to_s + "&submit=Submit Message"
		@connection.http_post(post_field)
	end

end

class Topic
	attr_accessor :topic_id, :topic_title, :tc, :posts

	def initialize(topic_id = 0, topic_title = "", tc = "", posts = [])
		@topic_id = topic_id
		@topic_title = topic_title
		@tc = tc
		@posts = posts
	end

	def to_s
		output = "\n" + @topic_title + "\n\n"
		puts output
		puts posts.to_s
	end


end

class Post
	attr_accessor :posted_by, :timestamp, :message_id, :post_number, :content

	def initialize(posted_by = "", timestamp = "", message_id = 1, post_number = 1, content = "")
		@posted_by = posted_by
		@timestamp = timestamp
		@message_id = message_id
		@post_number = post_number
		@content = content
	end

	def to_s
		"===========================\nFrom: " + @posted_by + " Posted: " + @timestamp + " #" + @post_number.to_s + "\n\n" + content + "\n===========================\n\n"
	end
end

site = ETI.new
puts "Enter your username: "
username = gets
username = username.partition("\n")[0]
puts "Enter your password: "
system 'stty -echo'
password = gets
system 'stty echo'
password = password.partition("\n")[0]
site.login(username, password)
