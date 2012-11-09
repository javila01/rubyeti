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

    # returns a Topic object containing the same metadata as the original, but with only the
    # specified username's posts
    def filter_by_username username = ""
        t = Topic.new @topic_id, @topic_title, @tc, [], @tags, @num_msgs, @last_post, @archived
        for post in @posts
            if post.username.to_s == username.to_s
                t.posts << post
            end
        end 
        return t
    end

    # returns a Topic object containing the same metadata as the original, but with only the
    # specified userid's posts
    def filter_by_userid userid = 0
        t = Topic.new @topic_id, @topic_title, @tc, [], @tags, @num_msgs, @last_post, @archived
        for post in @posts
            if post.userid.to_s == userid.to_s
                t.posts << post
            end
        end
        return t
    end

    def to_s
        output = "\n" + @topic_title + "\n\n"
        for tag in tags
            output += "[" + tag + "] "
        end
        output += "\n\n"
        for post in posts
            output += post.to_s
        end
        return output
    end
end

