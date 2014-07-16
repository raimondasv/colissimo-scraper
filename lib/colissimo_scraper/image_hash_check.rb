require 'digest/sha1'

module ColissimoScraper

  UNRECOGNISED = 'unrecognised'
  IN_TRANSIT = 'in_transit'
  ON_DELIVERY = 'on_delivery'
  UNDELIVERED = 'undelivered'
  HELD_AT_ENQUIRY_OFFICE = 'held_at_enquiry_office'
  DELIVERED = 'delivered'

  SHA1_HASH = 

  class ImageHashCheck < Struct.new(:calissimo_response, :response)

    def decide_status
      calissimo_response.each_image_url do |url, type, index| 

        if type == DESCR_FIELD_URL && index == 1
          raw = ColissimoScraper.colissimo_website['/portail_colissimo/' + url].get :cookies => response.cookies
        end
      end
    end
  end

end