require 'rubygems'
require 'typhoeus'
require 'nokogiri'
require 'rubyeti'
require 'rubyeti_connector'
require 'topic'
require 'topic_list'
require 'post'


eti = RubyETI.new

# logs in
login = false

while !login
    begin
        puts "Enter your username: "
        username = gets
        puts "Enter your password: "
        system 'stty -echo'
        password = gets
        system 'stty echo'
        eti.login(username, password)
    rescue LoginError => e
        puts e.message + "\n\n"
    else
        login = true
    end
end

begin
    puts eti.upload_image "/Users/clenart/Desktop/fourmore.jpg"
rescue ETIError => e
    puts "upload_image test failed: "
    puts e.message
else
    puts "upload_image test passed"
end

=begin
# get_topic_range test
begin
    topics = eti.get_topic_range 1, 3
    for topic in topics
        puts topic
    end
end

# post_topic test
begin
    puts eti.post_topic "testtt", "sorry about this ignore me", ["Anonymous", "LUE"]
rescue TopicError => e
    puts "post_topic test failed: "
    puts e.message
else
    puts "post_topic test passed"
end



# get_topic_by_id test
begin
    t = eti.get_topic_by_id 8189111
    puts t
rescue ETIError => e
    puts "get_topic_by_id test failed: "
    puts e.message
else
    puts "get_topic_by_id passed"
end

# get_topic_list test
begin
    start = Time.now
    topic_list=eti.get_topic_list("Apple") 
    puts topic_list
    #topic_list = eti.get_topic_list("LUE")
    puts Time.now - start
rescue TopicError => e
    puts "get_topic_list test failed: "
    puts e.message
else
    puts "get_topic_list test passed"
end



# get_user_id test
begin
    puts eti.get_user_id "Chris"
rescue ETIError => e
    puts "get_user_id test failed: "
    puts e.message
else
    puts "get_user_id test passed"
end
=end


