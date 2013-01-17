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
    stores = process_nearby_stores
    print_stores(stores)
    choice = user_store_choice(stores)
    directions(stores, choice)
  end

  def user_location
    puts "What address you at?"
    print "> "
    gets.chomp
  end

  def print_stores(stores)
    stores.each do |name, info|
      puts "Name: #{name}"
      puts "Rating: #{info['rating']}"
      puts "Open: #{info['open']}"
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
    store_hash = {}
    stores['results'].each do |store|
      store_hash[store['name']] = {
        'location' => store['geometry']['location'],
        'open' => store['opening_hours']['open_now'],
        'rating' => store['rating']
      }
    end
    store_hash
  end

  def user_store_choice(stores)
    while true
      puts "WHAT YOU WANT?"
      print "> "
      store_choice = gets.chomp
      return store_choice if stores.has_key?(store_choice)
      puts "invalid entry"
    end
  end

  def directions(stores, choice)
    origin = "#{@user_coord["lat"]},#{@user_coord["lng"]}"
    destination = "#{stores[choice]['location']['lat']},#{stores[choice]['location']['lng']}"
    url = Addressable::URI.new(
        scheme: 'https',
        host: 'maps.googleapis.com',
        path: 'maps/api/directions/json',
        query_values: {
          origin: origin,
          destination: destination,
          mode: 'walking'
          sensor: 'false'
        }
      ).to_s
    response = JSON.parse(RestClient.get(url))
    nil
  end

  def print_directions(directions)
  end

end