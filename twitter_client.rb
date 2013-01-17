require 'oauth'
require './secret_keys.rb'
require 'rest-client'
require 'addressable/uri'
require 'json'

class Twitter

  CONSUMER_KEY = Keys.new.get_oauth_consumer_key
  CONSUMER_SECRET = Keys.new.get_oauth_secret_key

  CONSUMER = OAuth::Consumer.new(
    CONSUMER_KEY,
    CONSUMER_SECRET,
    :site => "http://twitter.com")

  def get_access_token
    request_token = CONSUMER.get_request_token

    puts "Go to this URL: #{request_token.authorize_url}"

    puts "Type in your verification code:"
    oauth_verifier = gets.chomp

    @access_token = request_token.get_access_token(:oauth_verifier => oauth_verifier)
    nil
  end

  def post_tweet
  end

  def user_timeline
    url = Addressable::URI.new(
      scheme: 'https',
      host: 'api.twitter.com'
      path: '1.1/statuses/user_timeline.json'
      query_values: {
          count: '10'
        }
      ).to_s
    response = JSON.parse(RestClient.get(url))
    p response
  end

  def user_statuses
  end

  def direct_message
  end

end

