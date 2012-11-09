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
