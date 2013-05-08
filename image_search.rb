require 'oauth'
require 'cgi'
require 'json'
require 'dalli'
require 'open-uri'

class ImageSearch

  KEY      = 'dj0yJmk9YWF3ODdGNWZPYjg2JmQ9WVdrOWVsWlZNRk5KTldFbWNHbzlNVEEyTURFNU1qWXkmcz1jb25zdW1lcnNlY3JldCZ4PTUz'
  SECRET   = 'a3d93853ba3bad8a99a175e8ffa90a702cd08cfa'
  CONSUMER = OAuth::Consumer.new(KEY, SECRET, { :site => 'http://yboss.yahooapis.com' })
  ATOKEN   = OAuth::AccessToken.new(CONSUMER)

  def self.search(term)

    result = cache.get(term)

    return result if result

    if result.nil?

      resp = ATOKEN.request(:get, "/ysearch/images?q=#{OAuth::Helper.escape term}&format=json")

      if resp.code == '200'
        data = JSON.parse(resp.body)

        result = {
          :url    => data['bossresponse']['images']['results'][0]['thumbnailurl'],
          :width  => data['bossresponse']['images']['results'][0]['thumbnailwidth'],
          :height => data['bossresponse']['images']['results'][0]['thumbnailheight'],
        }

        cache.set(term, result, 3600 * 24 * 30)

        return result

      else
        raise "#{resp.code} - #{term}"
      end

    end

  end

  def self.cache
    @cache ||= begin
      if ENV['MEMCACHE_SERVERS']
        Dalli::Client.new(["#{ENV['MEMCACHE_SERVERS']}:11211"], :username => ENV['MEMCACHE_USERNAME'], :password => ENV['MEMCACHE_PASSWORD'])
      else
        Dalli::Client.new(['localhost:11211'])
      end
    end
  end

end
