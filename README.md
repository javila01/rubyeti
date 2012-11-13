RubyETI
=======

Ruby interface to ETI

Installation
============

```
sudo gem install rubyeti
```

Dependencies
============

typhoeus
* libcurl

nokogiri 
* libxml2
* libxslt


Usage
=====

In your ruby file, you must
```ruby
require 'rubyeti'
```

To create a RubyETI object:
```ruby
eti = RubyETI.new
```

To login:
```ruby
eti.login "username", "password"
```

Topic list object:
```ruby
class TopicList
    attr_accessor :topics

    def initialize topics = []
    end
end

class TopicListRow
    attr_accessor :topic_name, :topic_id, :tags, :tc, :msgs, :last_post

    def initialize topic_name = "", topic_id = 0, tags = [], tc = "", msgs = 0, last_post = ""
    end
end
```

Topic object:
```ruby
class Topic
    attr_accessor :topic_id, :topic_title, :tc, :posts, :tags, :num_msgs, :last_post, :archived

    def initialize topic_id = 0, topic_title = "", tc = "", posts = [], tags = [], num_msgs = 0, last_post = 0, archived = true
    end

    # returns a Topic object containing the same metadata as the original, but with only the
    # specified username's posts
    def filter_by_username username = ""
    end

    # returns a Topic object containing the same metadata as the original, but with only the
    # specified userid's posts
    def filter_by_userid userid = 0
    end
end
```

Post object:
```ruby
class Post
    attr_accessor :username, :userid, :timestamp, :message_id, :post_number, :content

    def initialize username = "", userid = "", timestamp = "", message_id = 1, post_number = 1, content = ""
    end
end
```

Full documentation ( also available at the top of lib/rubyeti/rubyeti.rb )
```ruby
# RubyETI
# A Ruby interface to ETI
# Designed by Christopher Lenart
# Contact: clenart1@gmail.com
# Open Source. 
# https://github.com/clenart/rubyeti
# Linking to my github in your documentation would be greatly appreciated :)

# I assume no responsibility if you get banned for using this.

# Uses Ruby style exceptions
# All exceptions specific to this program are subclasses of ETIError
# All functions throw LoginError when the user is not logged into ETI
class RubyETI
    # logs a user into the site with their credentials
    # with the session ("desktop" or "iphone") they specify
    # returns true on success
    # throws SessionError if an invalid session is passed
    def login username, password, session = "iphone"
    end

    # posts a topic with the specified name and content
    # to all the tags listed in the array tag_list
    # sig is NOT automatically appended yet
    def post_topic topic_name, topic_content, tag_list = ["LUE"]
    end

    # retrieves a topic list object, which is the first page of topics matching the tag combo entered
    # tags should be passed as one string, as if you were putting it in the text box on the
    # + page on ETI
    # DOES NOT WORK WITH ANONYMOUS TOPICS
    # throws TopicError
    def get_topic_list tag_list = "LUE"
    end

    # retrieves a topic by id
    # returns a topic object on success
    # DOES NOT WORK WITH ANONYMOUS TOPICS
    # throws TopicError
    def get_topic_by_id id
    end

    # returns an array of topic objects, based on the topic ids passed in the ids array
    # throws TopicError
    def get_topics_by_id ids
    end

    # returns an array of topic objects, based on the range of topics between first_id
    # and last_id, inclusive
    # throws TopicError
    def get_topic_range first_id, last_id
    end

    # stars the topic id
    # throws TopicError
    def star_topic_by_id id
    end

    # unstars the topic id
    # throws TopicError
    def unstar_topic_by_id id
    end

    # returns the userid of the specified username
    # returns false and error message if not found
    # throws UserError
    def get_user_id username
    end

    ###############################################################################
    # these four functions send tokens by either integer userid or string username
    # to send anonymously, set the anon argument to true
    # throws ETIError on failure

    def send_good_token_by_id       userid,   reason, anon = false
    end

    def send_good_token_by_username username, reason, anon = false
    end

    def send_bad_token_by_id        userid,   reason, anon = false
    end

    def send_bad_token_by_username  username, reason, anon = false
    end

    ###############################################################################

    # uploads an image to eti and returns the <img> code as a string
    # only has been tested with absolute paths from the root directory
    def upload_image path_to_image
    end

    # returns true if online
    # false if not
    # throws UserError
    def is_user_online username
    end

    # returns true if online
    # false if not
    # throws UserError
    def is_user_online_by_id userid
    end

    # creates a new private message thread with the user specified by the userid user
    # does NOT send your sig automatically
    # both subject AND message must be >= 5 characters, or will fail
    # does not work with *special* characters
    # throws UserError
    def create_private_message username, subject, message
    end

    def create_private_message_by_id userid, subject, message
    end
end
```
