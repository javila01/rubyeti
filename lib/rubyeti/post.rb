class Post
    attr_accessor :username, :userid, :timestamp, :message_id, :post_number, :content

    def initialize(username = "", timestamp = "", message_id = 1, post_number = 1, content = "")
        @username = username 
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
