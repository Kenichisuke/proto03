class ApiBtcbox < ApiCoin

# btc と jpy のみ 2015/12/21

  mattr_accessor :logger
  self.logger ||= Rails.logger

  def initialize
    @public_url = "https://www.btcbox.co.jp/api/v1/"
  end

  def get_last_price(c1t, c2t = "jpy")
    return false if c1t.upcase != "BTC" 
    return false if c2t.upcase != "JPY"
    json = get_ssl(@public_url + "ticker/")
    return json["last"]
  end

  def get_ticker(c1t, c2tc2t = "jpy")
    return false if c1t.upcase != "BTC" 
    return false if c2t.upcase != "JPY"
    json = get_ssl(@public_url + "ticker/")
    return json
  end

  def get_ssl(address)
    begin
      super(address)
    rescue => e
      logger.error('Btcbox connection eror.')
      logger.error('class:' + e.class.to_s)
      logger.error('msg:' + e.message)
      raise $!
    end
  end
end
