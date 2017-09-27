#!/usr/bin/env ruby

require "digest/md5"
require 'time'
require 'net/http'
require "cgi"

require 'active_support/time'
require 'active_support/json'

book_information = {
      contact: {
        name: "Liping",
        email: "lp@163.com",
        phone: "10086",
        address: "beijing",
        postcode: "100100"
      },
      passengers: [
      {
        last_name: "zhang",
        first_name: "san",
        birthdate: "1986-09-01",
        passport: "A123456",
        email: "x@a.cn",
        phone: "15000367081",
        gender: "male"
      }
      ],
      sections: [
        "bc_01"
      ],
      seat_reserved: true
    }

def signature_of api_key, secret, params = {}
  time = Time.new.to_i
  hashdata = {api_key: api_key, t: time}.merge(params.reject {|k, v| v.is_a? Hash}.reject {|k, v| v.is_a? Array}.reject {|k, v| v.nil?})
  sign = Digest::MD5.hexdigest(hashdata.sort.map{|k,v| "#{k}=#{v}"}.join + secret)
  result = {
    From: api_key,
    Date: Time.at(time).httpdate,
    Authorization: sign
  }
end

#alpha
api_key = "1fdeae6e7fd44c9e991d21066a828f0c"
secret = "4dae4d6a-4874-4d60-8eac-67701520671d"
env = "alpha"

def send_http_post uri, api_key, secret, params
  res = Net::HTTP.start(uri.host, uri.port,
    :use_ssl => uri.scheme == 'https') { |http|
    request = Net::HTTP::Post.new uri
    signature = signature_of(api_key, secret, params)
    request["From"]=signature[:From]
    request["Date"]=signature[:Date]
    request["Authorization"]=signature[:Authorization]
    request["content_type"] = 'application/json'
    request.body = params.to_json
    response = http.request request # Net::HTTPResponse object
    async_resp = JSON(response.body)
  }

end

def send_http_get uri, api_key, secret, params
  Net::HTTP.start(uri.host, uri.port,
    :use_ssl => uri.scheme == 'https') { |http|
    request = Net::HTTP::Get.new uri
    signature = signature_of(api_key, secret, params)
    request["From"]=signature[:From]
    request["Date"]=signature[:Date]
    request["Authorization"]=signature[:Authorization]
    response = http.request request # Net::HTTPResponse object
    async_resp = JSON(response.body)
  }
end

begin
  uri = URI("https://#{env}.api.detie.cn/api/v2/online_orders")
  async_resp = send_http_post uri, api_key, secret, book_information
  p async_resp
  sleep(3)

  get_result_uri = URI("https://#{env}.api.detie.cn/api/v2/async_results/#{async_resp['async']}")
  50.times do
    sleep(3)
    book_result = send_http_get get_result_uri, api_key, secret, {async_key: async_resp['async']}
    p book_result
  end
rescue =>e
  p e
end