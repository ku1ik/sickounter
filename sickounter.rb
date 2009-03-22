require 'rubygems'
require 'sinatra'

get '/' do
  url = params[:f] or raise Sinatra::NotFound
  filename = url.gsub(/https?:\/\//, "").gsub(/[^a-zA-Z0-9_-]/, ".") + ".txt"
  path = "counters/#{filename}"
  val = (File.read(path).strip.to_i rescue 0) + 1
  File.open(path, "w") do |f|
    f.flock(File::LOCK_EX)
    f.puts(val.to_s)
    f.flock(File::LOCK_UN)
  end
  redirect(url)
end

get '/stats' do
  @downloads = {}
  Dir["counters/*.txt"].each do |counter|
    @downloads[counter.split("/")[1]] = File.read(counter).strip.to_i
  end
  erb :stats
end
