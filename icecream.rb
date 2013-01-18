require 'rest-client'
require 'addressable/uri'
require 'json'
require 'nokogiri'

require './secret_keys.rb'


#Kriti - overall, i like it. not really sure what comments to make here

class IceCreamFinder

  def initialize
  # Kriti - what is this? do we need to initalize a new key everytime we load this class?
    @google_key = Keys.new.get_google_key
  end

  def run
    location_coordinates
    stores = process_nearby_stores
    p stores
    print_stores(stores)
    choice = user_store_choice(stores)
    path = directions(stores, choice)
    print_directions(path)
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
    local_store_list = nearby_stores
    return puts "There's NOTHING near you" if local_store_list.nil?

    shops_by_name = {}
    local_store_list['results'].each do |store|
      one_store = {}
      one_store['location'] = store['geometry']['location']
      if store['opening_hours']
        one_store['open'] = store['opening_hours']['open_now']
      else
        one_store['open'] = 'Not Provided'
      end
      if store['rating']
        one_store['rating'] = store['rating']
      else
        one_store['rating'] = 'Not provided'
      end
      shops_by_name[store['name']] = one_store
    end
    shops_by_name
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
          mode: 'walking',
          sensor: 'false'
        }
      ).to_s
    response = JSON.parse(RestClient.get(url))
    response
  end

  def print_directions(directions)
    directions['routes'][0]['legs'][0]['steps'].each do |step|
      puts Nokogiri::HTML(step["html_instructions"]).text
    end
    nil
  end

end
