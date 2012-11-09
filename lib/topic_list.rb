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

