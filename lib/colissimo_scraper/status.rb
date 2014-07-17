module ColissimoScraper

  class Status

    UNRECOGNISED = 'unrecognised'
    IN_TRANSIT = 'in_transit'
    ON_DELIVERY = 'on_delivery'
    DELIVERED = 'delivered'

    attr_reader :date, :location, :status

    def initialize(date, location, status)
      @date = date
      @location = location
      @status = status
    end
  end

end