require 'rubyeti'

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
	rescue LoginError
		puts "Invalid username / password combo, try again\n\n"
	else
		login = true
	end
end

# get_topic_list test
begin
	start = Time.now
	puts eti.get_topic_list(["LUE", "Programming"])
	puts Time.now - start
rescue TopicError => e
	puts "get_topic_list test failed: "
	puts e.message
else
	puts "get_topic_list test passed"
end

=begin
# post_topic test
begin
	eti.post_topic "tnwefg", "im gay"
rescue TopicError => e
	puts "post_topic test failed: "
	puts e.message
else
	puts "post_topic test passed"
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

# get_topic_by_id test
begin
	eti.get_topic_by_id 8176561
rescue ETIError => e
	puts "get_topic_by_id test failed: "
	puts e.message
else
	puts "get_topic_by_id passed"
end
=end
