module TvdbParty
  class InvalidXmlParser < HTTParty::Parser
    def xml
      MultiXml.parse(cleaned_body)
    end

    def cleaned_body
      body.dup.tap do |cleaned|
        possibly_invalid_fields.each do |field|
          cleaned.gsub!("<#{field}>", "<#{field}><![CDATA[")
          cleaned.gsub!("</#{field}>", "]]></#{field}>")
        end
      end
    end

    def possibly_invalid_fields
      %w[ Overview SeriesName IMDB_ID Actors ]
    end
  end

  class Search
    include HTTParty
    include HTTParty::Icebox
    attr_accessor :language
    cache :store => 'file', :timeout => 120, :location => Dir.tmpdir + '/tvdb_party'

    base_uri 'www.thetvdb.com/api'

    parser InvalidXmlParser

    def initialize(the_api_key, language = 'en')
      @api_key = the_api_key
      @language = language
    end

    def get_server_time
      response = self.class.get("/Updates.php", {:query => {:type => 'none'}})
      return nil unless response["Items"]
      response["Items"]["Time"]
    end

    def get_series_updates(timestamp)
      get_updates(timestamp, 'series')
    end

    def get_episodes_updates(timestamp)
      get_updates(timestamp, 'episode')
    end

    def get_all_updates(timestamp)
      get_updates(timestamp, 'all')
    end

    def search(series_name)
      response = self.class.get("/GetSeries.php", {:query => {:seriesname => series_name, :language => @language}})
      return [] unless response["Data"]

      case response["Data"]["Series"]
        when Array
          response["Data"]["Series"].map {|result| Series.new(self, result)}
        when Hash
          [Series.new(self, response["Data"]["Series"])]
        else
          []
      end
    end
    
    def search_by_imdb_id(imdb_id)
      response = self.class.get("/GetSeriesByRemoteID.php", {:query => {:imdbid => imdb_id, :language => @language}})
      return [] unless response["Data"]

      case response["Data"]["Series"]
      when Array
        response["Data"]["Series"]
      when Hash
        [response["Data"]["Series"]]
      else
        []
      end
    end 

    def get_series_by_id(series_id, language = self.language)
      response = self.class.get("/#{@api_key}/series/#{series_id}/#{language}.xml")

      if response["Data"] && response["Data"]["Series"]
        Series.new(self, response["Data"]["Series"])
      else
        nil
      end
    end

    def get_episode_by_id(episode_id, language = self.language)
      response = self.class.get("/#{@api_key}/episodes/#{episode_id}/#{language}.xml")
      if response["Data"] && response["Data"]["Episode"]
        Episode.new(self, response["Data"]["Episode"])
      else
        nil
      end
    end

    def get_episode(series, season_number, episode_number, language = self.language)
      response = self.class.get("/#{@api_key}/series/#{series.id}/default/#{season_number}/#{episode_number}/#{language}.xml")
      if response["Data"] && response["Data"]["Episode"]
        Episode.new(self, response["Data"]["Episode"])
      else
        nil
      end
    end

    def get_all_episodes_by_series_id(series_id, language = self.language)
      response = self.class.get("/#{@api_key}/series/#{series_id}/all/#{language}.xml")
      return [] unless response["Data"] && response["Data"]["Episode"]
      case response["Data"]["Episode"]
      when Array
        response["Data"]["Episode"].map{|result| Episode.new(self, result)}
      when Hash
        [Episode.new(response["Data"]["Episode"])]
      else
        []
      end
    end

    def get_all_episodes(series, language = self.language)
      get_all_episodes_by_series_id(series.id, language)
    end

    def get_actors_by_id(series_id)
      response = self.class.get("/#{@api_key}/series/#{series_id}/actors.xml")
      if response["Actors"] && response["Actors"]["Actor"]
        response["Actors"]["Actor"].collect {|a| Actor.new(a)}
      else
        nil
      end
    end

    def get_actors(series)
      get_actors_by_id series.id
    end

    def get_banners_by_id(series_id)
      response = self.class.get("/#{@api_key}/series/#{series_id}/banners.xml")
      return [] unless response["Banners"] && response["Banners"]["Banner"]
      case response["Banners"]["Banner"]
      when Array
        response["Banners"]["Banner"].map{|result| Banner.new(result)}
      when Hash
        [Banner.new(response["Banners"]["Banner"])]
      else
        []
      end
    end

    def get_banners(series)
      get_banners_by_id series.id
    end

    private

    def get_updates(timestamp, update_type)
      response = self.class.get("/Updates.php", {:query => { :time => timestamp, :type => update_type}})
      return response["Items"] ? response["Items"] : []
    end

  end
end