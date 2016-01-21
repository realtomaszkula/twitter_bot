require 'jumpstart_auth'

class MicroBlogger
  attr_reader :client

  def initialize
    puts "Initializing..."
    @client = JumpstartAuth.twitter
  end

  def tweet(message)
    @client.update(message) if message.size <= 140
  end

  def follower_list
    screen_names = @client.followers.collect { |follower| @client.user(follower).screen_name }
  end


  def spam_my_followers(message)
    followers = follower_list
    followers.each { |follower| dm(follower, message) }
  end

  def dm(target, message)
    screen_names = @client.followers.collect { |follower| @client.user(follower).screen_name }

    puts "Trying to send #{target} this direct message:"
    puts message
    message = "d @#{target} #{message}"

    if screen_names.include? target
      tweet(message)
    else
      puts "Can only DM people who follow you!"
    end
  end

  def everyones_last_tweet
    friends = @client.friends.collect { |friend| @client.user(friend) }
    friends.each do |friend|

      puts friend.screen_name
      puts friend.status.text
      puts ""
    end
  end


  def run
    puts "Welcome to the JSL Twitter Client!"
    command = ""
    while command != "q"
      printf "Enter command: "
      input = gets.chomp
      parts = input.split(" ")
      command = parts[0]
      case command
        when 'q' then puts "Goodbye!"
        when 't' then tweet(parts[1..-1].join(" "))
        when 'dm' then dm(parts[1], parts[2..-1].join(" "))
        when 'spam' then spam_my_followers(parts[1..-1].join(" "))
        when 'elt' then everyones_last_tweet
        else
          puts "Sorry, I don't know how to #{command}"
      end
    end
  end


end

blogger = MicroBlogger.new

blogger.run

