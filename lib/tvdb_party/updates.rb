module TvdbParty
  class Updates
    attr_accessor :series, :episodes, :banners

    def initialize(series = nil, episodes = nil, banners = nil)
      @series = series ? series : []
      @episodes = episodes ? episodes : []
      @banners = banners ? banners : []
    end
  end
end
