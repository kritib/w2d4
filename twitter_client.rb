require 'oauth'
require 'rest-client'
require 'addressable/uri'
require 'json'

require './secret_keys.rb'

class Twitter

  CONSUMER_KEY = Keys.new.get_oauth_consumer_key
  CONSUMER_SECRET = Keys.new.get_oauth_secret_key

  CONSUMER = OAuth::Consumer.new(
    CONSUMER_KEY,
    CONSUMER_SECRET,
    :site => "http://twitter.com")

  def access_token
    request_token = CONSUMER.get_request_token

    puts "Go to this URL: #{request_token.authorize_url}"

    puts "Type in your verification code:"
    oauth_verifier = gets.chomp

    @access_token = request_token.get_access_token(:oauth_verifier => oauth_verifier)
    nil
  end

  def get_tweet_from_user
    puts "Update status: "
    gets.chomp
  end

  def post_tweet
    tweet = get_tweet_from_user
    url = Addressable::URI.new(
        scheme: 'https',
        host: 'api.twitter.com',
        path: '1.1/statuses/update.json'
      ).to_s
    status = {status: tweet}
    response = @access_token.post(url, status).body
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
    response = @access_token.get(url).body
  end

  def user_statuses
  end

  def direct_message
  end

end

