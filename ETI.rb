require 'rubygems'
require 'curb'
require 'nokogiri'

class ETI
	def initialize

	end

	def login(username, password)
		# creates new curl object with the login page as its target
		@connection = Curl::Easy.new("https://endoftheinter.net/index.php")
		# allows cookies, so we can stay logged into eti
		@connection.enable_cookies = true
		# posts to the login page my username and password
		post_field = "b=" + username + "&p=" + password
		@connection.http_post(post_field)
	end

	def get_topic_by_id(id)
		# sets the curl object url to a page on eti i want to get
		url = "http://archives.endoftheinter.net/showmessages.php?topic=" + id.to_s
		@connection.url = url
		# gets the post
		@connection.http_get
		#puts @connection.body_str

		t = Topic.new

		html_source = @connection.body_str
		
		html_doc = Nokogiri::HTML(html_source)
		suggest_tag_link = html_doc.xpath('//a[contains(@href, "edittags.php")]').text
		t.topic_id = 0

		# gets the topic title
		t.topic_title = html_doc.xpath('//h1').text

		# gets a list of the posters
		posters = html_doc.xpath('//div[@class = "message-container"]/div/a[contains(@href, "/profile.php?user=")]')
		
		timestamps = html_doc.xpath('//div[@class = "message-container"]/div')
		# gets the first post
		for i in 0..49
			poster = posters[i].text

			timestamp = timestamps[i].text
			timestamp = timestamp.partition("Posted:")[2]
			timestamp = timestamp.partition("|")[0]

			message_id = html_doc.xpath('//div[@class = "message-container"]/div/a[contains(@href, "message.php?id=")]')[i].text
			content = html_doc.xpath('//td[@class = "message"]')[i].text

			t.posts[i] =  Post.new(poster, timestamp, message_id, i+1, content)
		end
		puts t.to_s

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
password = gets
password = password.partition("\n")[0]
site.login(username, password)
puts username
puts password
site.get_topic_by_id(1)

=begin
t = Topic.new(1, "Programming Topic x, where x = imgay", "Chris")
p1 = Post.new("Chris", "10/31/2012 11:12 PM", "9", "1", "im gay")
t.posts << p1
p2 = Post.new("citizenray", "10/31/2012 11:13 PM", "9", "2", "haha same yolo")
t.posts << p2
puts t.to_s
=end