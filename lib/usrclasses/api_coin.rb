require 'json'
require 'uri'
require 'openssl'
require 'net/http'

class ApiCoin

  def initialize
    raise "no implementation. Please override"
  end

  def get_last_price
    raise "no implementation. Please override"
  end

  def get_ticker
    raise "no implementation. Please override"
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
          raise ConnectionFailedException, "Failed to connect"
        end
      }
    rescue
      raise
    end
  end

  class ConnectionFailedException < StandardError; end
  class APIErrorException < StandardError; end
  class JSONException < StandardError; end

end