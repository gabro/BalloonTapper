require 'sinatra'
require 'json'
require 'data_mapper'

post '/session' do
  puts 'Hello, world'
  taps = params[:taps]
  session = Session.new
  taps.each do |t|
  	tap = session.taps.new(time: t["time"])
  end
  session.save
end

DataMapper::setup(:default, "sqlite3://#{Dir.pwd}/bt.db")
class Session
	include DataMapper::Resource
	property :id, Serial
	has n, :taps
end

class Tap
  include DataMapper::Resource
  property :id, Serial
  property :time, Float, :required => true
  belongs_to :session, :key => true
end
DataMapper.finalize.auto_upgrade!