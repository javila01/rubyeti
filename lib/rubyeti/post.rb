class Post
    attr_accessor :username, :userid, :timestamp, :message_id, :post_number, :content

    def initialize(username = "", userid = "", timestamp = "", message_id = 1, post_number = 1, content = "")
        @username = username 
        @userid = userid
        @timestamp = timestamp
        @message_id = message_id
        @post_number = post_number
        @content = content
    end

    def to_s
        output = "===========================\nFrom: " + @username.to_s + " UserID: " + @userid.to_s + " Posted: " + @timestamp.to_s + " #" + @post_number.to_s + "\n\n" + content.to_s + "\n===========================\n\n"
        return output
    end
end
