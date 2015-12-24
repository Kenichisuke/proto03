class RateFromSite
  def initialize


    api_z =ApiZaif.new
    a = api_z.get_last_price("BTC", "MONA")
    b = api_z.get_last_price("JPY", "MONA")
    c = api_z.get_last_price("JPY", "BTC")    
    if a != 0 and c != 0 and b !=0 then
      value = 0.3 * a + 0.7 * b/c
    elsif a != 0 and c == 0 then
      value = a
    elsif a == 0 and b != 0 and c != 0 then
      value = b/c
    else
      value = 0
    end
    @btc_mona = value

    api_h =ApiHitbtc.new
    @btc_ltc  = api_h.get_last_price("BTC", "LTC")
    @btc_doge = api_h.get_last_price("BTC", "DOGE")
  end

  def rate(cr)
    case cr.coin_a.ticker + cr.coin_b.ticker
    when "BTCLTC"
      @btc_ltc
    when "BTCMONA"
      @btc_mona
    when "BTCDOGE"
      @btc_doge
    when "LTCMONA"
      @btc_ltc.nonzero? ? (@btc_mona / @btc_ltc) : 0
    when "LTCDOGE"
      @btc_ltc.nonzero? ? (@btc_doge / @btc_ltc) : 0
    when "MONADOGE"
      @btc_mona.nonzero? ? (@btc_doge / @btc_mona) : 0
    else
      return false
    end
  end

end