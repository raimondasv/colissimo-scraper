require 'digest/sha1'

module ColissimoScraper

  # Your parcel is ready to be shipped. It has not been taken on by La Poste yet. IN_TRANSIT
  # You parcel has been dropped-off at the shipping post office IN_TRANSIT
  # La Poste is handling your parcel. It is currently being routed. IN_TRANSIT
  # Your parcel has arrived at its delivery location IN_TRANSIT
  # Your parcel is ready for delivery ON_DELIVERY
  # Your parcel was delivered to the caretaker or frontdesk : DELIVERED

  IMAGE_SHA1_HASHES = {
    'cc07e840ec519540999aa37661949823747f351f' => ColissimoScraper::Status::DELIVERED,
    '464e7b209c5a215544265d67b3121b4aa5ebaaaf' => ColissimoScraper::Status::ON_DELIVERY,
    '7ea77d91f54952673d0144c66391ccaed8ee2fb5' => ColissimoScraper::Status::IN_TRANSIT,
    '7815d27ff487c8852da8fc99c6c0239342bfadf7' => ColissimoScraper::Status::IN_TRANSIT,
    '362f015d12c7b1cf0e09322c42adf4372e7fa64c' => ColissimoScraper::Status::IN_TRANSIT,
    '81b52b7762ce5cdb0aba58e2f61aac46d0c5517f' => ColissimoScraper::Status::IN_TRANSIT
  }

  class ImageHashTracker

    def initialize(page_parser, base_page_http_response)
      page_parser.fetch_images.each do |image|

        # For image hash tracker - preload only first image, thats why index == 1
        if image[:field] == DESCR_FIELD_URL && image[:index] == 1
          raw_image = get_image(image[:src], base_page_http_response)

          hash = Digest::SHA1.hexdigest(raw_image)
          status = IMAGE_SHA1_HASHES.fetch(hash, ColissimoScraper::Status::UNRECOGNISED)

          # No location or date information in this type of tracker
          tracking_list << Status.new(nil, nil, status)

          break
        end
      end
    end

    def tracking_list
      @tracking_list ||= []
    end

    def last
      tracking_list.last
    end

    private

    def get_image(url, base_page_http_response)
      ColissimoScraper.colissimo_website['/portail_colissimo/' + url].get(cookies: base_page_http_response.cookies)
    end

  end
end
