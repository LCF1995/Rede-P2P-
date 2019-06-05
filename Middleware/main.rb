require 'rubygems'
require 'sinatra'
require 'find'
require 'pdf/reader'
require 'digest/md5'
require 'socket'
require 'http'
require 'json'

set :bind, '0.0.0.0'
set :port, 9494

get "/" do
	host = request.ip
	File.open("hosts.txt", "a") do |line|
	  line.puts(host+";")
	  line.close unless line.closed?
	end
	erb :index
end

post '/search' do
	filename = params[:filename]

	if filename != nil
	hosts = IO.readlines('hosts.txt')
	link = Array.new()
	i = 0
	hosts.each do |line|
		aux = line.split(";").first
		i = i+1
		start_time = Time.now
		begin
		   if response = HTTP.post("http://#{aux}:4567/search",:form => {:filename => "#{filename}"})
				end_time = Time.now - start_time
				list = {:hash => "#{response.body}", :ip => "#{aux}", :lat => "#{end_time }"}
				link.push(list)
			end
				raise 'Procurando...'
		   rescue Exception => e
		     puts e.message
		end
	end
	@file = filename 
	@results = link.sort_by { |item| item[:lat] }.first(3)
	@amount = link[0][:hash].to_i

	if @results.size >= 3
	    @mean = 0
	    @third =  0
	    @fourth = 0
	    @point_2 =  0
	    @point_3 = 0
      if @amount.modulo(2) == 0
        @mean = @amount/2
        @third = @mean/3
        @fourth = @mean-@third
        @point_2 = @mean+@third
    	@point_3 = @point_2+@fourth
      else
        @mean = @amount/2.round(2)
        @third = @mean/2+1
        @fourth = @mean-@third+1
    	@point_2 = @mean+@third
    	@point_3 = @point_2+@fourth
    end
	end

    if @results.size >= 2
      	if @amount.modulo(2) == 0
        @mean = @amount/2
        @third = @mean
        @point_2 = @amount
      	else
        @mean = @amount/2.round(2)
        @third = @mean+1
        @point_2 =  @mean+@third
    	end
  	end
end
	erb :show_result
end

