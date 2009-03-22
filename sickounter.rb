require 'rubygems'
require 'sinatra'

COUNTERS_DIR = ENV['COUNTERS_DIR'] || File.join(File.dirname(__FILE__), 'counters')

get '/' do
  url = params[:f] or raise Sinatra::NotFound
  filename = url.gsub(/https?:\/\//, "").gsub(/[^a-zA-Z0-9_-]/, ".") + ".txt"
  path = File.join(COUNTERS_DIR, filename)
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

__END__

@@stats
<h1>Sickounter download statistics</h1>

<div id="main">
<table class="wide">
  <tr>
    <th>File</th>
    <th class="dl">Downloads</th>
  </tr>
  <% @downloads.keys.sort_by { |counter| -@downloads[counter] }.each do |counter| %>
  <tr>
    <td><%= counter %></td>
    <td><%= @downloads[counter] %></td>
  </tr>
  <% end %>
</table>
</div>

@@layout
<html>
<head>
  <title>Sickounter download statistics</title>
  <style>
    body { background-color: white; color: black; font: 8pt Verdana }
    th { background-color: #789 }
    tr th { font-weight: bold; text-align: left; color: white }
    td, th { padding: 10px }
    td { border-right: 1px solid #ccc; border-bottom: 1px solid #ccc }
    div#main { margin: 0 auto; text-align: center; width: 800px }
    table { border-left: 1px solid #ccc; border-bottom: 2px solid #ccc; border-spacing:0; }
    table.wide { width: 100% }
    th.dl { width: 50px }
    h1 { text-align: center; margin-bottom: 60px }
  </style>
</head>
<body>
<%= yield %>
</body>
</html>
