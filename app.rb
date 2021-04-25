require 'httparty'
require 'json'
require 'sinatra'

READ_MEMORY_API = ENV['READ_MEMORY_API']

get '/status' do
  'Healthy'
end

get '/api/v1/debug/readMemory' do
  (params['address'].to_i & 0xFF).to_s
end

post '/api/v1/execute' do
  request.body.rewind
  data = JSON.parse request.body.read
  high_byte = params['operand2'].to_i
  low_byte = params['operand1'].to_i
  address = (high_byte << 8) | low_byte

  data['state']['l'] = HTTParty.get("#{READ_MEMORY_API}?id=#{data['id']}&address=#{address}").to_i
  data['state']['h'] = HTTParty.get("#{READ_MEMORY_API}?id=#{data['id']}&address=#{(address + 1) & 0xFFFF}").to_i
  data['state']['cycles'] = data['state']['cycles'].to_i + 16

  content_type :json
  data.to_json
end