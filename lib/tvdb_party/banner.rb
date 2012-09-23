module TvdbParty
  class Banner
    attr_accessor :type, :subtype, :season, :path, :thumbnail_path, :language

    def initialize(options={})
      @type = options["BannerType"]
      @subtype = options["BannerType2"]
      @season = options["Season"]
      @path = options["BannerPath"]
      @language = options["Language"]
    end

    def url
      "http://thetvdb.com/banners/" + @path
    end

    def thumb_url
      "http://thetvdb.com/banners/_cache/" + @path
    end

  end
end