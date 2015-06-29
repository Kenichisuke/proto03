class Orderbook

  extend CoinUtil

  mattr_accessor :logger
  self.logger ||= Rails.logger


  def self.totalprocess
    logger.info('Orderbook.totalprcess start: ' + Time.now.to_s)
    coincomb = [["BTC", "MONA"], 
		        ["BTC", "LTC"],
		        ["LTC", "MONA"]]
    coincomb.each do | c |
      coin_a, coin_b = coin_order( c[0], c[1] )
      execute(coin_a.id, coin_b.id)
    end

    trade2acnt

    coincomb.each do | c |
      coin_a, coin_b = coin_order(c[0], c[1])
      makeplot(coin_a.id, coin_b.id)
    end

    logger.info('coin-combination: ' + coincomb.to_s)
    logger.info('Orderbook.totalprcess end: ' + Time.now.to_s)
  end

  def self.execute(coin1, coin2)  # receive cointype_id

    logger.debug('Orderbook.execute start:' + coin1.to_s + ':' + coin2.to_s )

    #check if there are overlaps or not between sell and buy
    sellcount = Order.openor.coins(coin1, coin2).where(buysell: true).count
    buycount = Order.openor.coins(coin1, coin2).where(buysell: false).count

    # binding.pry

    if ( sellcount == 0 || buycount == 0 ) then return false end
    minval = Order.openor.coins(coin1, coin2).where(buysell: true).minimum(:rate)
    maxval = Order.openor.coins(coin1, coin2).where(buysell: false).maximum(:rate)
    if minval > maxval then return false end


    sells = Order.openor.coins(coin1, coin2).match_order_sell(maxval)
    buys = Order.openor.coins(coin1, coin2).match_order_buy(minval)
    nsells = sells.count     
    nbuys  = buys.count

    # binding.pry

    # 付き合わせ
    i = 0
    j = 0
    while (i < nsells && j < nbuys)
      if sells[i].rate > buys[j].rate then break end
  
      # binding.pry

      if sells[i].amt_a > buys[j].amt_a then
        
        coinamt_a = buys[j].amt_a

        begin
          ActiveRecord::Base.transaction do
            create_trade(sells[i].id, buys[j].id, coin1, coin2, coinamt_a, coinamt_a * sells[i].rate, Trade.flags[:tr_new])
            create_trade(buys[j].id, sells[i].id, coin1, coin2, coinamt_a, buys[j].amt_b, Trade.flags[:tr_new])
            create_trade(sells[i].id, buys[j].id, coin1, coin2, 0, buys[j].amt_b - coinamt_a * sells[i].rate, Trade.flags[:tr_diffwip])

            sells[i].amt_a -= coinamt_a
            sells[i].amt_b -= coinamt_a * sells[i].rate
            sells[i].flag = Order.flags[:open_per] 

            buys[j].amt_a = 0   # -= buys[j].amt_a
            buys[j].amt_b = 0   # -= buys[j].amt_b
            buys[j].flag = Order.flags[:exec_exec]

            sells[i].save!
            buys[j].save!
          end
        rescue => e
          # エラーを書くロジック
          # log に書き出すロジック
          # 戻る
        end
        j += 1

        # binding.pry

      elsif sells[i].amt_a < buys[j].amt_a then

        coinamt_a = sells[i].amt_a
        begin
          ActiveRecord::Base.transaction do
            create_trade(sells[i].id, buys[j].id, coin1, coin2, coinamt_a, sells[i].amt_b, Trade.flags[:tr_new])
            create_trade(buys[j].id, sells[i].id, coin1, coin2, coinamt_a, coinamt_a * buys[j].rate, Trade.flags[:tr_new])
            create_trade(sells[i].id, buys[j].id, coin1, coin2, 0, coinamt_a * buys[j].rate - sells[i].amt_b, Trade.flags[:tr_diffwip])

            buys[j].amt_a -= coinamt_a
            buys[j].amt_b -= coinamt_a * buys[j].rate
            buys[j].flag = Order.flags[:open_per]

            sells[i].amt_a = 0    # -= sells[i].amt_a
            sells[i].amt_b = 0    # -= sells[i].amt_b 
            sells[i].flag = Order.flags[:exec_exec]
            sells[i].save!
            buys[j].save!
          end
        rescue => e
          # log に書き出すロジック
        end

        i += 1
        # binding.pry
      else   # sells[i].amt_a == buys[j].amt_a
        coinamt_a = sells[i].amt_a
        begin
          ActiveRecord::Base.transaction do
            create_trade(sells[i].id, buys[j].id, coin1, coin2, coinamt_a, sells[i].amt_b, Trade.flags[:tr_new])
            create_trade(buys[j].id, sells[i].id, coin1, coin2, coinamt_a, buys[j].amt_b, Trade.flags[:tr_new])
            create_trade(sells[i].id, buys[j].id, coin1, coin2, 0, buys[j].amt_b - sells[i].amt_b, Trade.flags[:tr_diffwip])

            sells[i].amt_a = 0
            sells[i].amt_b = 0 
            sells[i].flag = Order.flags[:exec_exec]

            buys[j].amt_a = 0
            buys[j].amt_b = 0
            buys[j].flag = Order.flags[:exec_exec]
            sells[i].save!
            buys[j].save!
          end
        rescue => e
          # log に書き出すロジック
        end
        i +=1
        j +=1
        # binding.pry
      end
    end

    logger.debug('Orderbook.execute end:' )
  end

  def self.create_trade(id1, id2, coin1, coin2, amt_a, amt_b, flag)

    order = Order.find(id1)
    if order.buysell then
      txrate = order.coin_b.fee_trd
      fee = amt_b * txrate
      amt_b -= fee
    else
      txrate = order.coin_a.fee_trd
      fee = amt_a * txrate
      amt_a -= fee
    end

#      Trade.create!(order_id: id1,  opps_id: id2, amt_a: amt_a, amt_b: amt_b, fee: fee, flag: flag)
    Trade.create!(order_id: id1, coin_a_id: coin1, coin_b_id: coin2, amt_a: amt_a, amt_b: amt_b, fee: fee, flag: flag)
  end

  def self.trade2acnt

    logger.debug('Orderbook.trade2acnt start:')

    count = Trade.where(flag: Trade.flags[:tr_new]).count
    if count <= 0 then return end
    trades = Trade.where(flag: Trade.flags[:tr_new])

    # binding.pry

    trades.each do | tr |
      usrid = tr.order.user_id
      coin1 = tr.order.coin_a_id
      coin2 = tr.order.coin_b_id

      ActiveRecord::Base.transaction do

        # binding.pry

        acntA = Acnt.lock.find_by(user_id: usrid, cointype_id: coin1)
        acntB = Acnt.lock.find_by(user_id: usrid, cointype_id: coin2)
        if tr.order.buysell then
          acntA.balance -= tr.amt_a
          acntA.locked_bal -= tr.amt_a
          acntB.balance += tr.amt_b
        else
          acntA.balance += tr.amt_a
          acntB.balance -= tr.amt_b
          acntB.locked_bal -= tr.amt_b
        end
        # binding.pry

        tr.flag = Trade.flags[:tr_close]
        acntA.save!
        acntB.save!
        tr.save!
      end
    end

    trades = Trade.where(flag: Trade.flags[:tr_diffwip])
    trades.each do | tr |
      usrid = User.first.id   # 修正必要
      coin2 = tr.order.coin_b_id

      ActiveRecord::Base.transaction do
        acntB = Acnt.lock.find_by(user_id: usrid, cointype_id: coin2)
        acntB.balance += tr.amt_b
        tr.flag = :tr_diffdone
        actB.save!
        tr.save!
      end 
    end

    logger.debug('Orderbook.trade2acnt end:')

  rescue => e
    logger.error('cannot save data at Transaction')
    logger.error('class:' + e.class)
    logger.error('msg' + e.message)
  end

  def self.makeplot(coin1, coin2)  # receive coin_id
    logger.debug('Orderbook.makeplot start:' + coin1.to_s + ':' + coin2.to_s )


    subss = []

    if Order.openor.coins(coin1, coin2).where(buysell: true).count > 0 then
      pr1 = Order.openor.coins(coin1, coin2).where(buysell: true).minimum(:rate)
      pr2 = Order.openor.coins(coin1, coin2).where(buysell: true).maximum(:rate)

      index = 0
      mx = -1
      tmp = ((pr1 * 10).floor/10.0)
      begin
        rsubs = Order.openor.coins(coin1, coin2).where(buysell: true).where('? <= rate AND rate < ?', tmp, tmp + 0.1)
        # binding.pry
        if rsubs.count > 0 then
          sum = rsubs.sum(:amt_a)
          subss << [tmp, sum]
          index += 1
          if sum > mx then
            mx = sum
          end
        end
        tmp += 0.1
        tmp = tmp.round(1)

        # binding.pry
      end while (index < 10) && (tmp <= pr2)
    end

    subbs = []

    if Order.openor.coins(coin1, coin2).where(buysell: false).count > 0 then

      pr1 = Order.openor.coins(coin1, coin2).where(buysell: false).maximum(:rate)
      pr2 = Order.openor.coins(coin1, coin2).where(buysell: false).minimum(:rate)
      index = 0
      tmp = ((pr1 * 10).ceil/10.0)
      begin
        rsubs = Order.openor.coins(coin1, coin2).where(buysell: false).where('? < rate AND rate <= ?', tmp - 0.1, tmp)

        if rsubs.count > 0 then
          sum = rsubs.sum(:amt_a)
          subbs << [tmp, sum]
          index += 1
          if sum > mx then
            mx = sum
          end
        end
        tmp -= 0.1
        tmp = tmp.round(1)
      end while (index < 10) && (tmp >= pr2)
    end

    lang = ['en', 'ja']  
    for la in lang
      filename = Cointype.find(coin1).ticker + '-' + Cointype.find(coin2).ticker + '_hist_' + la + '.html'
      fl = File.open("./app/assets/javascripts/plotdata/#{filename}", "w+")
      if (subss.any? || subbs.any?) then
        fl.puts %Q[<table>]
        if subss.any? then
          if la == 'ja' then
            fl.puts %Q[<tr><th width="40%">売注文数量</th><th width="20%">レート</th><th width="40%">買注文数量</th></tr>]
          elsif la == 'en' then
            fl.puts %Q[<tr><th width="40%">Ask size</th><th width="20%">Rate</th><th width="40%">Bit size</th></tr>]
          end
          subss.reverse_each do |x|
            fl.puts %Q[<tr>
              <td><div class="graph"><span class ="bar1" style="width:#{(x[1] * 100 / mx).floor}%">#{x[1]}</span></div></td>
              <td>#{x[0].round(1)}</td>
              <td></td>
              </tr>]
          end
        end
        if subbs.any? then
          subbs.each do |x|
            fl.puts %Q[<tr>
              <td></td>
              <td>#{x[0].round(1)}</td>            
              <td><div class="graph"><span class ="bar2" style="width:#{(x[1] * 100 / mx).floor}%">#{x[1]}</span></div></td>
              </tr>]
          end
        end
        fl.puts %Q[</table>]
      end
      fl.close
    end

    logger.debug('Orderbook histgram created :' + filename)   
    logger.debug('Orderbook.makeplot end:' )
  end

end
