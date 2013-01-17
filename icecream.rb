require 'rest-client'
require 'addressable/uri'
require 'json'
require './secret_keys.rb'

class IceCreamFinder

  def initialize
    @google_key = Keys.new.get_google_key
  end

  def run
    location_coordinates
    print_stores
  end

  def user_location
    puts "What address you at?"
    print "> "
    gets.chomp
  end

  def print_stores
    stores = process_nearby_stores
    stores.each do |store|
      puts "Name: #{store[:name]}"
      puts "Rating: #{store[:rating]}"
      puts "Open: #{store[:open]}"
      puts "-" * 8
    end
    nil
  end

  def location_coordinates
    location = user_location
    url = Addressable::URI.new(
        :scheme => 'http',
        :host => 'maps.googleapis.com',
        :path => 'maps/api/geocode/json',
        :query_values => {:address => location, :sensor => 'false'}
      ).to_s
    response = JSON.parse(RestClient.get(url))
    @user_coord = response["results"][0]["geometry"]["location"]
  end

  def nearby_stores
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
  end

  def process_nearby_stores
    stores = nearby_stores
    store_array = []
    stores['results'].each do |store|
      store_hash = {}
      store_hash[:location] = store['geometry']['location']
      store_hash[:name] = store['name']
      store_hash[:open] = store['opening_hours']['open_now']
      store_hash[:rating] = store['rating']
      store_array << store_hash
    end
    store_array
  end

  def directions

  end

end


#location_hash = response["results"][0]['geometry']['location']
#name = response["results"][0]['name']
#open = response["results"][0]['opening_hours']['open_now']
#rating = response["results"][0]['rating']