module CoinUtil

  def coin_order(coin1_t, coin2_t)
    coin_a = Cointype.find_by(ticker: coin1_t)
    coin_b = Cointype.find_by(ticker: coin2_t)
    if !coin_a || !coin_b then return false end

    if coin_a.rank > coin_b.rank then
      return coin_a, coin_b
    else
      return coin_b, coin_a
    end
  end

  def coin_t2c(coin_t)
    Cointype.find_by(ticker: coin_t)
    # return nil when it does not exists.
  end

  def coin_t2i(coin_t)
    Cointype.find_by(ticker: coin_t).id
    # return nil when it does not exists.
  end

  def coin_list_i
    allist = Cointype.all.order(rank: :desc)
    ret = []
    allist.each do | a |
      ret << a.id
    end
  end

end
