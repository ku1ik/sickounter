require 'rubygems'
require 'sinatra'

COUNTERS_DIR = File.join(File.dirname(__FILE__), 'counters')

get '/' do
  url = params[:f] or raise Sinatra::NotFound
  filename = url.gsub(/https?:\/\//, "").gsub(/[^a-zA-Z0-9_-]/, ".") + ".txt"
  path = File.join(COUNTERS_DIR, filename)
  puts path
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
  Dir[File.join(COUNTERS_DIR, "*.txt")].each do |counter|
    @downloads[counter.split("/")[-1]] = File.read(counter).strip.to_i
  end
  erb :stats
end
