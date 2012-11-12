require 'sinatra'
require 'json'
require 'data_mapper'
require 'gchart'

get '/' do
  redirect '/sessions'
end

get '/sessions/:id' do
  @session = Session.get(params[:id])
  @title = session.to_s
  @plot_url = Gchart.scatter(
        data: [@session.taps.map { |t| t.time.round(2) }, Array.new(@session.taps.size, 1), Array.new(@session.taps.size, 10)],
        hAxis: {title: 'Taps', minValue: 0, maxValue: 60},
        vAxis: {title: '', minValue: 0, maxValue: 0},
        width: 800
      )
  erb :session
end

get '/sessions' do
  @sessions = Session.all
  @title = "Sessions"
  erb :sessions
end

post '/sessions' do
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

  def to_s
    "Session #{id}"
  end
end

class Tap
  include DataMapper::Resource
  property :id, Serial
  property :time, Float, :required => true
  belongs_to :session

  def to_s
    "Tap #{id} at #{time}"
  end
end
# DataMapper.finalize.auto_migrate!
DataMapper.finalize.auto_upgrade!