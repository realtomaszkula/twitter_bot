require 'jumpstart_auth'
require 'klout'
require 'bitly'

class MicroBlogger
  attr_reader :client

  def initialize
    puts "Initializing..."
    @client = JumpstartAuth.twitter
    Bitly.use_api_version_3
    @bitly = Bitly.new('hungryacademy', 'R_430e9f62250186d2612cca76eee2dbc6')
    Klout.api_key = 'xu9ztgnacmjx3bu82warbr3h'

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
    friends.sort_by! { |friend| friend.screen_name.downcase }

    friends.each do |friend|
      timestamp = friend.status.created_at.strftime("%A, %b %d")

      puts "#{friend.screen_name} at #{timestamp} posted:"
      puts friend.status.text
      puts ""
    end
  end

  def shorten(original_url)
    puts "Shortening this URL: #{original_url}"
    url = @bitly.shorten(original_url).short_url
    puts "Result: #{url}"
    url
  end


  def klout_score
    friends = @client.friends.collect { |f| @client.user(f).screen_name }
    friends.each do |friend|

      begin
        identity = Klout::Identity.find_by_screen_name(friend)
        user = Klout::User.new(identity.id)
        puts "#{friend} score: #{user.score.score}"
      rescue
        puts "Oops!  That was no kloudId found with the name #{friend}"
      end

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
        when 'lt' then everyones_last_tweet
        when 's' then shorten(parts[1])
        when 'turl' then tweet("#{parts[1..-2].join(" ")} #{shorten(parts[-1])}")
        when 'k' then klout_score
        else
          puts "Sorry, I don't know how to #{command}"
      end
    end
  end


end

blogger = MicroBlogger.new
blogger.run

