require "usps-proxy/version"

require 'bundler/setup'
require 'sinatra/base'
require 'usps'
require 'dotenv'
require 'pry'
require 'json'
Dotenv.load

def zip_is_number?(zip)
  zip.to_i.to_s == zip
end

module UspsProxy
  class App < Sinatra::Base    
    get '/city_state' do
      content_type :json
      zip = params[:zip]
      
      if zip_is_number?(zip)
        request = USPS::Request::CityAndStateLookup.new(zip)
        response = request.send!
        
        response.get(zip).to_h.to_json
      else
        {
          error: 1, 
          message: "Invalid or missing zip code: #{zip}"
        }.to_json
      end
    end
    
    get '/address_verification' do
      content_type :json
      
      addy = USPS::Address.new
      addy.firm      = params[:firm]
      addy.address1  = params[:address1]
      addy.address2  = params[:address2]
      addy.city      = params[:city]
      addy.state     = params[:state]
      addy.zip5      = params[:zip5]
      addy.zip4      = params[:zip4]
      
      request = USPS::Request::AddressStandardization.new(addy)
      response = request.send!
      
      response.get(addy).to_h.to_json
    end
  end
end