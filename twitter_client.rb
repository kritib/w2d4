require 'oauth'
require 'rest-client'
require 'addressable/uri'
require 'json'
require 'yaml'

require './secret_keys.rb'

class Twitter

  CONSUMER_KEY = Keys.new.get_oauth_consumer_key
  CONSUMER_SECRET = Keys.new.get_oauth_secret_key

  CONSUMER = OAuth::Consumer.new(
    CONSUMER_KEY,
    CONSUMER_SECRET,
    :site => "http://twitter.com")

  def initialize
    @access_token = retrieve_token
    nil
  end

  def post_tweet
    url = Addressable::URI.new(
        scheme: 'https',
        host: 'api.twitter.com',
        path: '1.1/statuses/update.json'
      ).to_s
    status = {status: get_tweet_from_user}
    response = JSON.parse(@access_token.post(url, status).body)
    puts "Successfully twat!" if response.length == 20
  end

  def user_timeline
    url = Addressable::URI.new(
      scheme: 'https',
      host: 'api.twitter.com',
      path: '1.1/statuses/user_timeline.json',
      query_values: {
          count: '10'
        }
      ).to_s
    response = JSON.parse(@access_token.get(url).body)
    print_timeline(response)
    nil
  end

  def user_statuses
  end

  def direct_message
    user_message = get_message_from_user
    user = user_message[0]
    message = user_message[1]

    url = Addressable::URI.new(
        scheme: 'https',
        host: 'api.twitter.com',
        path: '1.1/direct_messages/new.json'
      ).to_s
    post_data = {
      screen_name: user,
      text: message
    }
    response = JSON.parse(@access_token.post(url, post_data).body)
    puts "successfully DM'ed #{user}!"
  end

  private

  def request_access_token
    request_token = CONSUMER.get_request_token

    puts "Go to this URL: #{request_token.authorize_url}"

    puts "Type in your verification code:"
    oauth_verifier = gets.chomp

    request_token.get_access_token(:oauth_verifier => oauth_verifier)
  end

  def retrieve_token(token_file='twitter_access_token')
    if File.exist?(token_file)
      File.open(token_file) { |f| YAML.load(f) }
    else
      request_access_token
      File.open(token_file, "w") { |f| YAML.dump(access_token, f) }

      access_token
    end
  end

  def get_tweet_from_user
    puts "Update status: "
    gets.chomp
  end

  def print_timeline(response)
    response.each do |tweet|
      puts "#{tweet['user']['name']}: #{tweet['text']}"
      puts "#{tweet['created_at']}"
      puts "-*-" * 10
    end
  end

  def get_message_from_user
    while true
      puts "Who do you want to DM?"
      user = gets.chomp
      break if follower?(user)
      puts "THEY HATE CHOO"
    end
    puts "What you saying?"
    message = gets.chomp
    [user, message]
  end

  def follower?(follower)
    url = Addressable::URI.new(
        scheme: 'https',
        host: 'api.twitter.com',
        path: '1.1/followers/list.json',
        query_values: {
          skip_status: 'true',
          include_user_entities: 'false'
        }
      ).to_s
    response = JSON.parse(@access_token.get(url).body)
    response['users'].each do |user|
      return true if user['screen_name'] == follower
    end
    false
  end

end

