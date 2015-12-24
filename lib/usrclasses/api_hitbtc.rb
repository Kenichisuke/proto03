class ApiHitbtc < ApiCoin

# btc と ltc 2015/12/21

  mattr_accessor :logger
  self.logger ||= Rails.logger

  def initialize
    @public_url = "https://api.hitbtc.com/api/1/public/"
  end

  def get_last_price(c1t, c2t)
    coins = c2t.upcase + c1t.upcase
    return 0 unless coins === "LTCBTC" || coins === "DOGEBTC"
    begin
      json = get_ssl(@public_url + coins + "/ticker")        
    rescue => e
      logger.error('Hitbtc connection error.')
      logger.error('class:' + e.class.to_s)
      logger.error('msg:' + e.message)
      return 0
    else
      val = json["last"].to_f
      if val.nonzero? then
        return 1.0 / val
      else
        return 0
      end
    end
  end

  # def get_ticker(c1t, c2t)
  #   coins = c2t.upcase + c1t.upcase
  #   return false unless coins === "LTCBTC" || coins === "DOGEBTC"  
  #   json = get_ssl(@public_url + coins + "/ticker")
  #   return json
  # end

  def get_ssl(address)
    begin
      super(address)
    rescue => e
      logger.error('Hitbtc connection error.')
      logger.error('class:' + e.class.to_s)
      logger.error('msg:' + e.message)
      raise $!
    end
  end
end
