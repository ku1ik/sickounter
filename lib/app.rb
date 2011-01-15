require "sinatra"
require "uri"
require_relative "models"

get '/' do
  f = params[:f] or raise Sinatra::NotFound

  target_url = URI.parse(f)
  referer_url = URI.parse(request.referer)

  if host = target_url.host || referer_url.host
    domain = Domain.find_or_create_by(:name => host)

    if target_url.path[0] == "/"
      path = target_url.path
    else
      path = File.dirname(referer_url.path + " ") + "/" + target_url.path
    end

    download = domain.downloads.find_or_create_by(:path => path)
    download.count += 1
    download.save
  end

  redirect(f)
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
