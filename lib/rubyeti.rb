# RubyETI
# A Ruby interface to ETI
# Designed by Christopher Lenart
# Contact: clenart1@gmail.com
# Open Source. 
# https://github.com/clenart/rubyeti
# Linking to my github in your documentation would be greatly appreciated :)

# I assume no responsibility if you get banned for using this.

require 'rubygems'
require 'curb'
require 'typhoeus'
require 'rubyeti_connector'
require 'nokogiri'

# Uses Ruby style exceptions
# All exceptions specific to this program are subclasses of ETIError
# All functions throw LoginError when the user is not logged into ETI
class RubyETI
    # logs a user into the site with their credentials
    # with the session ("desktop" or "iphone") they specify
    # returns true on success
    def login(username, password, session)
    end

    # posts a topic with the specified name and content. sig is NOT automatically appended yet
    # posts to the LUE tag only at the moment
    def post_topic(topic_name, topic_content)
    end

    # retrieves a topic list object, which is the first page of topics matching the tag combo entered
    # currently &'s together all tags in the tag_list array
    # DOES NOT WORK WITH ANONYMOUS TOPICS
    # throws TopicError
    def get_topic_list(tag_list)
    end

    # retrieves a topic by id
    # returns a topic object on success, and should (doesn't yet) return failure indicator on fail
    # DOES NOT WORK WITH ANONYMOUS TOPICS
    # throws TopicError
    def get_topic_by_id(id)
    end

    # returns the userid of the specified username
    # returns false and error message if not found
    # throws UserError
    def get_user_id(username)
    end

    # returns true if online
    # false if not
    # throws UserError
    def is_user_online(username)
    end

    # returns true if online
    # false if not
    # throws UserError
    def is_user_online_by_id(userid)
    end

    # creates a new private message thread with the user specified by the userid user
    # does NOT send your sig automatically
    # both subject AND message must be >= 5 characters, or will fail
    # does not work with *special* characters
    # throws UserError
    def create_private_message(username, subject, message)
    end

    def create_private_message_by_id(userid, subject, message)
    end
end

class ETIError < StandardError
end

class LoginError < ETIError
end

class TopicError < ETIError
end

class UserError < ETIError
end

class TyphoeusError < ETIError
end

class RubyETI

    def initialize
        @connection = RubyETI_connector.new
    end

    def login(username, password, session="iphone")
        username = username.chomp
        password = password.chomp
        # connects the eti connector using the login info
        @connection.connect username, password, session
        # tests the connection
        @connection.test_connection
    end

    def post_topic(topic_name, topic_content)
        # gets the html from the post msg page, to get the hash value
        html_source     = @connection.get_html "http://boards.endoftheinter.net/postmsg.php?tag=LUE"
        # creates nokogiri object to parse
        html_doc        = Nokogiri::HTML(html_source)
        # finds the hash tag
        hash_field      = html_doc.xpath('//input[@name = "h"]')
        # extracts the hash from the html tag
        hash            = hash_field[0]["value"]
        # posts the topic using POST
        @connection.post_html "http://boards.endoftheinter.net/postmsg.php", "title=" + topic_name + "&tag=LUE&message=" + topic_content + "&h=" + hash + "&submit=Post Message"
    end

    def get_topic_list(tag_list)
        append = ""
        for tag in tag_list
            if tag != tag_list[0]
                append += "&"
            end
            append += tag.to_s
        end
        url         = "http://boards.endoftheinter.net/topics/" + append

        html_source = @connection.get_html url

        html_doc    = Nokogiri::HTML(html_source)
        # gets the <a> html tags that contain links to the topics on the topic list
        topic_ids   = html_doc.xpath('//td[@class = "oh"]/div[@class = "fl"]/a')

        topic_list_return = TopicList.new

        # extracts the topic id from the <a> html tags, and retrieves the topic from eti
        for topic in topic_ids
            topic_id = topic["href"]
            topic_id = topic_id.partition("?topic=")[2]
            t = get_topic_by_id(topic_id)
            topic_list_return.topics << t
        end

        return topic_list_return
    end

    def get_topic_by_id(id)
        html_source = @connection.get_html "http://boards.endoftheinter.net/showmessages.php?topic=" + id.to_s
        t = parse_topic_html(html_source)
        return t
    end

    def get_user_id(username) 
        user_search_source = @connection.get_html "http://endoftheinter.net/async-user-query.php?q=" + username
        user_search_source = user_search_source.partition(",\"")[2]
        user_search_source = user_search_source.partition("\"")[0]
        if(user_search_source.size==0)
            raise UserError, "User does not exist"
        else
            return user_search_source
        end

    end

    def is_user_online(username)
        user_id = get_user_id username

        html_source = @connection.get_html "http://endoftheinter.net/profile.php?user=" + user_id.to_s
        html_parse = Nokogiri::HTML(html_source)
        online_now = html_parse.xpath('//td[contains(text(), "online now")]');
        if online_now.size == 0
            return false
        else
            return true
        end
    end

    def is_user_online_by_id(userid)
        html_source = @connection.get_html "http://endoftheinter.net/profile.php?user=" + userid.to_s
        html_parse = Nokogiri::HTML(html_source)
        online_now = html_parse.xpath('//td[contains(text(), "online now")]');
        if online_now.size == 0
            return false
        else
            return true
        end
    end

    def create_private_message(username, subject, message)
        userid = get_user_id(username)
        create_private_message_by_id(userid, subject, message)
    end

    def create_private_message_by_id(userid, subject, message)
        

        # this block is to get the "h" value from the post message page
        # this seems to be unique to each user, not sure exactly how
        # so for now im just loading up the new PM thread page and grabbing it
        # from the html source
        html_source     = @connection.get_html "http://endoftheinter.net/postmsg.php?puser=" + userid.to_s
        html_doc        = Nokogiri::HTML(html_source)
        hash_field      = html_doc.xpath('//input[@name = "h"]')
        hash            = hash_field[0]["value"]

        # posts the pm information to the connection
        # DOES NOT send your sig automatically
        @connection.url = "http://endoftheinter.net/postmsg.php"
        post_field      = "puser=" + userid.to_s + "&title=" + subject.to_s + "&message=" + message.to_s + "&h=" + hash.to_s + "&submit=Send Message"
        @connection.post_html post_field
    end

private

    def parse_topic_html(html_source)
        # creates a new topic to store the data in
        t = Topic.new

        # creates a nokogiri object for parsing the topic
        html_doc            = Nokogiri::HTML(html_source)

        if html_doc.xpath('//div/em')[0].text == "Invalid topic."
            raise TopicError, 'Invalid topic'
        end

        # gets the topic id
        suggest_tag_link    = html_doc.xpath('//a[contains(@href, "edittags.php")]')
        link                = suggest_tag_link[0]["href"]
        link                = link.partition("=")[2]
        t.topic_id          = link.to_i

        # gets the topic title
        t.topic_title       = html_doc.xpath('//h1').text

        # sets the archived flag
        h2 = html_doc.xpath('//h2')
        if(h2.size > 1)
            t.archived = true
        else
            t.archived = false
        end

        # gets a list of the posters
        posters             = html_doc.xpath('//div[@class = "message-container"]/div[@class = "message-top"]/a[contains(@href, "profile.php")]')
        
        # gets a list of the timestamps. these are still embedded in other text, the for loop
        # takes care of extracting them
        timestamps          = html_doc.xpath('//div[@class = "message-container"]')

        # gets a list of the link nodes with message_id
        # its embedded in the href, the for loop extracts it
        messages            = html_doc.xpath('//div[@class = "message-container"]/div[@class="message-top"]/a[contains(@href, "message.php")]')

        # gets the content of the posts
        contents            = html_doc.xpath('//td[@class = "message"]')

        # gets the first page of posts
        i = 0
        for p in posters
            poster      = p.text
            # gets the TC
            if(i==0) 
                t.tc = poster
            end

            timestamp   = timestamps[i].text
            timestamp   = timestamp.partition("Posted:")[2]
            timestamp   = timestamp.partition("|")[0]

            message_id  = messages[i]["href"]
            message_id  = message_id.partition("=")[2]
            message_id  = message_id.partition("&")[0]

            content     = contents[i].text

            t.posts[i]  =  Post.new(poster, timestamp, message_id, i+1, content)
            i           += 1
        end

        # retrieve a list of links to the next pages of the topic
        next_page_links = html_doc.xpath('//div[@id = "u0_2"]/span')
        number_of_pages = next_page_links[0].text.to_i
        # if no links exist, return
        if number_of_pages == 1
            return t
        else
            if t.archived
                suburl = "archives"
            else
                suburl = "boards"
            end
            requests = []
            for i in 2..number_of_pages
                requests << @connection.queue("http://" + suburl + ".endoftheinter.net/showmessages.php?topic=" + t.topic_id.to_s + "&page=" + i.to_s)
            end
            start = Time.now
            @connection.run
            puts Time.now - start
            for i in 2..number_of_pages
                t = parse_topic_page(t,i, requests[i-2].response.body)
            end
        end
        return t
    end

    def parse_topic_page(t, page, html_source)
        html_doc = Nokogiri::HTML(html_source)

        # gets a list of the posters
        posters             = html_doc.xpath('//div[@class = "message-container"]/div[@class = "message-top"]/a[contains(@href, "profile.php")]')
        
        # gets a list of the timestamps. these are still embedded in other text, the for loop
        # takes care of extracting them
        timestamps          = html_doc.xpath('//div[@class = "message-container"]')

        # gets a list of the link nodes with message_id
        # its embedded in the href, the for loop extracts it
        messages            = html_doc.xpath('//div[@class = "message-container"]/div[@class="message-top"]/a[contains(@href, "message.php")]')

        # gets the content of the posts
        contents            = html_doc.xpath('//td[@class = "message"]')

        # gets the first page of posts
        i = 0
        for p in posters
            poster      = p.text

            timestamp   = timestamps[i].text
            timestamp   = timestamp.partition("Posted:")[2]
            timestamp   = timestamp.partition("|")[0]

            message_id  = messages[i]["href"]
            message_id  = message_id.partition("=")[2]
            message_id  = message_id.partition("&")[0]

            content     = contents[i].text

            post_number = (page - 1) * 50 + i
            t.posts[post_number]    =  Post.new(poster, timestamp, message_id, post_number+1, content)
            i           += 1
        end

        return t
    end

end

class TopicList
    attr_accessor :topics

    def initialize(topics = [])
        @topics = topics
    end

    def to_s
        output = "\n"
        for topic in @topics
            output += topic.topic_title + "\t\t| " + topic.tc + "\n"
        end 
        output
    end

end

class Topic
    attr_accessor :topic_id, :topic_title, :tc, :posts, :tags, :num_msgs, :last_post, :archived

    def initialize(topic_id = 0, topic_title = "", tc = "", posts = [], tags = [], num_msgs = 0, last_post = 0, archived = true)
        @topic_id = topic_id
        @topic_title = topic_title
        @tc = tc
        @posts = posts
        @tags = tags
        @num_msgs = num_msgs
        @last_post = last_post
        @archived = archived
    end

    def to_s
        output = "\n" + @topic_title + "\n\n"
        for post in posts
            output += post.to_s
        end
        return output
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
        output = "===========================\nFrom: " + @posted_by.to_s + " Posted: " + @timestamp.to_s + " #" + @post_number.to_s + "\n\n" + content.to_s + "\n===========================\n\n"
        return output
    end
end
