class ApiBitflyer < ApiCoin

# btc と jpy のみ 2015/12/21

  mattr_accessor :logger
  self.logger ||= Rails.logger

  def initialize
    @public_url = "https://api.bitflyer.jp/v1/"
  end

  def get_last_price(c1t, c2t = "jpy")
    return false if c1t.upcase != "BTC" 
    return false if c2t.upcase != "JPY"
    json = get_ssl(@public_url + "getticker/")
    return json["ltp"]
  end

  def get_ticker(c1t, c2t = "jpy")
    return false if c1t.upcase != "BTC" 
    return false if c2t.upcase != "JPY"
    json = get_ssl(@public_url + "getticker/")
    return json
  end

  def get_ssl(address)
    begin
      super(address)
    rescue => e
      logger.error('BitFlyer connection eror.')
      logger.error('class:' + e.class.to_s)
      logger.error('msg:' + e.message)
      raise $!
    end
  end
end
