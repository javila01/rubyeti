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
