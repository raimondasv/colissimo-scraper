require 'nokogiri'

module ColissimoScraper

  DATE_FIELD_URL = 'date'
  SITE_FIELD_URL = 'site'
  DESCR_FIELD_URL = 'libe'

  class Response

    def initialize(body) 
      @html = Nokogiri::HTML(body)
    end

    def each_image_url
      node = @html.xpath("//div[@id='resultatSuivreDiv']/table/tbody")

      if node 
        node.xpath('tr/td/img').each do |img|
          src = img['src']

          if src =~ /imageio?/

            if /(.*)_date_(?<idx>\d+)/ =~ src
              yield src, DATE_FIELD_URL, idx.to_i
            end

            if /(.*)_site_(?<idx>\d+)/ =~ src
              yield src, SITE_FIELD_URL, idx.to_i
            end

            if /(.*)_libe_(?<idx>\d+)/ =~ src
              yield src, DESCR_FIELD_URL, idx.to_i
            end
          end
        end
      end
    end

    def empty?
      @html.xpath
    end

  end
end