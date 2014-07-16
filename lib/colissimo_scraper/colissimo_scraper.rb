require 'rest_client'

module ColissimoScraper

  HTTP_HEADERS = {
    :origin => 'http://www.colissimo.fr',
    :referer => 'http://www.colissimo.fr/portail_colissimo/suivre.do?language=en_GB',
    :user_agent => 'Mozilla/5.0 (Macintosh; Intel Mac OS X 10_9_4) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/35.0.1916.153 Safari/537.36'
  }

  TIMEOUT = 5

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

  def self.colissimo_website
    RestClient::Resource.new('http://www.colissimo.fr', :headers => HTTP_HEADERS,  :timeout => TIMEOUT, :open_timeout => TIMEOUT)
  end

  def self.get_status(parcel_number)
  
    unless /[A-Za-z0-9]{13}/ =~ parcel_number 
      fail ArgumentError, "Invalid parcel number: #{parcel_number}"
    end

    response = colissimo_website['/portail_colissimo/suivreResultatStubs.do'].post({ :parcelnumber => parcel_number, :language => 'en_GB' })

    colissimo_response = ColissimoScraper::Response.new(response.to_str)

    ImageHashCheck.new(colissimo_response, response).decide_status

    colissimo_response
  end

  private

  def list_image_urls(page_text, &block)

  end

end