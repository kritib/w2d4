require 'rest-client'
require 'addressable/uri'
require 'json'
require './secret_keys.rb'

class IceCreamFinder

  def run
    get_key
    location_coordinates
    nearby_shops
  end

  def get_user_location
    puts "What address you at?"
    print "> "
    gets.chomp
  end

  def get_key
    @google_key = Keys.new.get_google_key
  end

  def location_coordinates
    location = get_user_location
    url = Addressable::URI.new(
        :scheme => 'http',
        :host => 'maps.googleapis.com',
        :path => 'maps/api/geocode/json',
        :query_values => {:address => location, :sensor => 'false'}
      ).to_s
    response = JSON.parse(RestClient.get(url))
    @user_coord = response["results"][0]["geometry"]["location"]
  end

  def nearby_shops
    location = "#{@user_coord["lat"]},#{@user_coord["lng"]}"
    url = Addressable::URI.new(
        :scheme => 'https',
        :host => 'maps.googleapis.com',
        :path => 'maps/api/place/nearbysearch/json',
        :query_values => {
          :key => @google_key,
          :location => location,
          :radius => '500',
          :sensor => 'false',
          :keyword =>'ice cream'
        }
      ).to_s
    response = JSON.parse(RestClient.get(url))
    p response
  end

  def directions

  end

end