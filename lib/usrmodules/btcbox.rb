require 'json'
require 'uri'
require 'openssl'
require 'net/http'

module Btcbox
  class API
    def initialize(opt = {})
      @btcbox_public_url = "https://www.btcbox.co.jp/api/v1/"
    end

    def get_last_price
      json = get_ssl(@btcbox_public_url + "ticker/")
      return json["last"]
    end

    def get_ticker
      json = get_ssl(@btcbox_public_url + "ticker/")
      return json
    end

    def get_ssl(address)
      uri = URI.parse(address)
      begin
        https = Net::HTTP.new(uri.host, uri.port)
        https.use_ssl = true
        https.open_timeout = 5
        https.read_timeout = 15
        https.verify_mode = OpenSSL::SSL::VERIFY_PEER
        https.verify_depth = 5

        https.start {|w|
          response = w.get(uri.request_uri)
          case response
          when Net::HTTPSuccess
            json = JSON.parse(response.body)
            raise JSONException, response.body if json == nil
            raise APIErrorException, json["error"] if json.is_a?(Hash) && json.has_key?("error")
            return json
          else
            raise ConnectionFailedException, "Failed to connect to Btcbox."
          end
        }
      rescue
        raise
      end
    end
  end

  class ConnectionFailedException < StandardError; end
  class APIErrorException < StandardError; end
  class JSONException < StandardError; end

end
