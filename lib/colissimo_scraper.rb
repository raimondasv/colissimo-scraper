require 'rest_client'

require 'colissimo_scraper/status'
require 'colissimo_scraper/page_parser'
require 'colissimo_scraper/scraping_error'
require 'colissimo_scraper/image_hash_tracker'

module ColissimoScraper

  HTTP_HEADERS = {
    :origin => 'http://www.colissimo.fr',
    :referer => 'http://www.colissimo.fr/portail_colissimo/suivre.do?language=en_GB',
    :user_agent => 'Mozilla/5.0 (Macintosh; Intel Mac OS X 10_9_4) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/35.0.1916.153 Safari/537.36'
  }

  @@open_timeout = 10
  @@timeout = 10

  # POST /portail_colissimo/suivreResultatStubs.do HTTP/1.1
  # Host: www.colissimo.fr
  # Connection: keep-alive
  # Content-Length: 41
  # Accept: */*
  # Origin: http://www.colissimo.fr
  # X-Requested-With: XMLHttpRequest
  # User-Agent: Mozilla/5.0 (Macintosh; Intel Mac OS X 10_9_4) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/35.0.1916.153 Safari/537.36
  # Content-Type: application/x-www-form-urlencoded; charset=UTF-8
  # Referer: http://www.colissimo.fr/portail_colissimo/suivre.do?language=en_GB
  # Accept-Encoding: gzip,deflate,sdch
  # Accept-Language: en-US,en;q=0.8,lt;q=0.6
  # Cookie: JSESSIONID=46002B1A829964F4261812A97E76E5FD.tc-webclp-NODE1

  def self.timeout
    @@timeout
  end

  def self.timoeout=(timeout)
    @@timeout = timeout
  end

  def self.open_timeout
    @@open_timeout
  end

  def self.open_timeout=(open_timeout)
    @@open_timeout = open_timeout
  end

  def self.colissimo_website
    RestClient::Resource.new('http://www.colissimo.fr', headers: HTTP_HEADERS, timeout: timeout, open_timeout:open_timeout)
  end

  def self.valid_tracking_number?(parcel_number)
    /\A[A-Za-z0-9]{13}\z/ =~ parcel_number
  end

  def self.fetch_tracking_list(parcel_number)

    unless valid_tracking_number?(parcel_number)
      fail ArgumentError, "Invalid parcel number: #{parcel_number}"
    end

    begin
      http_response = get_page_response(parcel_number)

      ImageHashTracker.new(ColissimoScraper::PageParser.new(http_response.to_str), http_response)
    rescue RestClient::Exception => e
      raise ColissimoScraper::ScrapingError, "Unable to fetch Colissimo web page"
    end
  end

  private

  def self.get_page_response(parcel_number)
    colissimo_website['/portail_colissimo/suivreResultatStubs.do'].post(parcelnumber: parcel_number, language: 'en_GB')
  end

end
