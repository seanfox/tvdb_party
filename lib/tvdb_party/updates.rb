module TvdbParty
  class Updates
    attr_accessor :series, :episodes, :banners

    def initialize(series = [], episodes = [], banners = [])
      @series = series
      @episodes = episodes
      @banners = banners
    end
  end
end
