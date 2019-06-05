require 'rubygems'
require 'sinatra'
require 'find'
require 'pdf/reader'
require 'digest/md5'
require 'socket'
require 'http'
require "./modulos/pdf"
require "./modulos/download"

include PdfConverter
include ExtractPdf

configure do
  set :bind, '0.0.0.0'
  set :port, 9292
end
get "/" do
  erb :index
end
post '/search' do
  filename = params[:filename]
  if File.exist?("./file/#{filename}.pdf" ) 
      arq = File.open("./file/#{filename}.pdf")
  end
  @result = extract_text(filename)
  @hash_1 = extract_download(filename) 
  @hash_2 =  Digest::MD5.hexdigest(@hash_1)
return "#{@result}|#{@hash_2}"
end
post '/download' do
  link = params[:filename]
  @name = nil
  @comp = nil
  conect = link.split("+")
  @arquivo = Array.new()
  conect.each do |i|
    count = i.split("|")
    host = count[0]
    @comp = count[2]
    file = count[3]
    @name = count[3]
    amount = count[4]
    cont = count[5]
    begin
    if body = HTTP.get("http://#{host}:9292/extract/=#{file}=#{amount}=#{cont}")
      @arquivo.push(body)
    puts "Requisição realizada!"
    end
    rescue Exception => e
    puts "Requisição perdida!"
    end
  end
  puts @comp
  @aux = @arquivo.join("\n")
  puts Digest::MD5.hexdigest(@aux)
  if conect.size == @arquivo.size
    File.write "./file/#{@name}.txt", @arquivo.join("\n")
    @download = "Completo!!!"
  else
    @download = "Incompleto!!!"
  end
  erb :show_result
end

get '/extract/:filename' do
  filename = params[:filename]
  resp = filename.split("=")
  porcent = []
  amount = extract_download(resp[1])
  for i in(resp[2].to_i..resp[3].to_i)
  porcent[i] = amount[i]
  end
  puts porcent.join("")
  return "#{porcent.join("")}"
end