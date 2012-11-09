class TopicList
    attr_accessor :topics

    def initialize(topics = [])
        @topics = topics
    end

    def to_s
        output = "\n"
        for topic in @topics
            output += topic.to_s + "\n"
        end 
        output
    end

end

class TopicListRow
    attr_accessor :topic_name, :topic_id, :tags, :tc, :msgs, :last_post

    def initialize topic_name = "", topic_id = 0, tags = [], tc = "", msgs = 0, last_post = ""
        @topic_name = topic_name
        @topic_id = topic_id
        @tags = tags
        @tc = tc
        @msgs = msgs
        @last_post = last_post
    end

    def to_s
        output = "Topic: " + topic_name + " Topic ID: " + topic_id.to_s + " Tags: " + tags.to_s + "TC: " + tc + " Msgs: " + msgs.to_s + "Last Post: " + last_post
    end
end