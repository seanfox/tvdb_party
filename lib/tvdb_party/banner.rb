module TvdbParty
  class Banner
    attr_accessor :type, :format, :season, :path, :thumbnail_path, :language, :last_updated_time

    def initialize(options={})
      @type = options["BannerType"] ? options["BannerType"] : options["type"]
      @format = options["BannerType2"] ? options["BannerType2"] : options["format"]
      @season = options["Season"]
      @path = options["BannerPath"] ? options["BannerPath"] : options["path"]
      @language = options["Language"]
      @last_updated_time = options["time"]
    end

    def url
      "http://thetvdb.com/banners/" + @path
    end

    def thumb_url
      "http://thetvdb.com/banners/_cache/" + @path
    end

  end
end