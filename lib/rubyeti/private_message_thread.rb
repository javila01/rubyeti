class PrivateMessageThread
    attr_accessor :thread_id, :tc, :posts, :num_msgs, :last_post

    def initialize(thread_id = 0, tc = "", posts = [], num_msgs = 0, last_post = 0)
        @thread_id = thread_id
        @tc = tc
        @posts = posts
        @num_msgs = num_msgs
        @last_post = last_post
    end
end