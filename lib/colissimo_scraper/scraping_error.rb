module ColissimoScraper

  class ScrapingError < StandardError

    attr_reader :cause

    def initialize(msg, cause = $!)
      super(msg)
      @cause = cause
    end

  end
end
