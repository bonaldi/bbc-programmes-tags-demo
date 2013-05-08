$: << '.'

require 'image_search'
require 'sinatra'
require 'rack/cache'
require 'nokogiri'

class Tag

  attr_reader :label, :value

  def initialize(value)
    @value = value
    @label = CGI::unescape(value.gsub('http://dbpedia.org/resource/', '').gsub('_', ' '))
  end

  def coocurrences
    pairs = `grep "#{value}" sorted_tag_data.txt | sort -nr | head -n 5`

    pairs.split("\n").map do |line|
      parts  = line.strip.split(" ")
      number = parts.first.to_i
      tags   = parts[1..-1].map { |t| t.gsub(/\<|\>/, '').gsub('http://dbpedia.org/resource/', '') }
      tag    = tags.find { |n| n !~ /#{value}/ }
      Tag.new(tag)
    end
  end

  def image
    ImageSearch.search(label)
  end

  def info
    data = JSON.parse(open('http://en.wikipedia.org/w/api.php?format=json&action=query&prop=extracts&titles=' + value).read)
    page = data['query']['pages'].keys.first
    html = Nokogiri.parse data['query']['pages'][page]['extract']
    html.xpath('//p').first.to_s.gsub(/\(.*\)/, '')
  end

end

use Rack::Cache

template :layout do
  %Q{<!DOCTYPE html>
    <html lang="en">
      <head>
        <meta charset="utf-8">
        <title><%= @tag.label %></title>
        <link rel="stylesheet" type="text/css" href="http://yui.yahooapis.com/3.10.0/build/cssreset/cssreset-min.css">
        <link rel="stylesheet" type="text/css" href="http://yui.yahooapis.com/3.10.0/build/cssgrids/cssgrids-min.css">
        <style type="text/css">
          body { color:#111; font-family: arial,sans-serif; padding:20px; }
          h1 { font-size:1.8rem; margin:10px 0; }
          h2 { font-size:1rem; margin:10px 0; }
          a { color: #0088cc; font-weight:bold; }
          .container { border:1px solid #ddd; border-radius:10px; padding:10px; width:500px; }
          #info { height:180px; }
          #info img { display:block; border: 1px solid #ddd; margin-right:10px; float:left; }
          #info p { height:110px; overflow:hidden; }
          #links { margin-top:10px; padding-left:20px; border-top:1px solid #ddd; font-size:0.8em; }
          #links h2 { margin-left:-20px; }
          #links .img { height:80px; width:80px; overflow:hidden; margin-bottom:20px; display:table-cell; vertical-align:middle; }
          #links .img img { display:block; margin:0 auto; }
          #links p { display:block; margin:10px auto; text-align:center; }
          #powered { font-size:0.7em; margin-top:10px; text-align:right; }
        </style>
      </head>
      <body>
        <%= yield %>
      </body>
    </html>}
end

template :tag do
  %Q{
    <div class='container'>
      <div id="info" class='yui3-u-1'>
        <img src="<%= @tag.image[:url] %>" width="<%= @tag.image[:width] %>" height="<%= @tag.image[:height] %>" />
        <h1><%= @tag.label %></h1>
        <%= @tag.info %>
      </div>
      <div id="links">
        <h2>Related:</h2>
        <% @links.each do |tag| %>
          <div class='yui3-u-1-6'>
            <div class='img'><img src="<%= tag.image[:url] %>" width="<%= tag.image[:width].to_i / 2 %>" height="<%= tag.image[:height].to_i / 2 %>" /></div>
            <p><a href="/tag/<%= tag.value %>"><%= tag.label %></a></p>
            </div>
        <% end %>
      </div>
      <p id="powered">Powered by <a href="http://www.gnu.org/software/grep/">grep</a></p>
    </div>
  }
end

get '/tag/:tag' do
  cache_control :public, :max_age => 36000
  @tag   = Tag.new(CGI::escape params[:tag])
  @links = @tag.coocurrences
  erb :tag
end

