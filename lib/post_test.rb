require 'rubyeti'

post = Post.new("Chris","11/1/2012 12:00 PM",1,1,"hello world")
expected_output = "From: Chris Posted: 11/1/2012 12:00 PM #1 Message ID: 1 Content: hello world"
output = "From: " + post.posted_by.to_s + " Posted: " + post.timestamp.to_s + " #" + post.post_number.to_s + " Message ID: " + post.message_id.to_s + " Content: " + post.content.to_s
if(expected_output == output) 
	puts "Test passed\n"
else
	puts "Test not passed\n"
end 
