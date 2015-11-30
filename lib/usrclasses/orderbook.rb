class Orderbook

  extend CoinUtil

  mattr_accessor :logger
  self.logger ||= Rails.logger


  def self.totalprocess
    logger.info('Orderbook.totalprcess start: ' + Time.now.to_s)
    coincomb = Cointype.tickercomb
    coincomb.each do | c |
      coin_a, coin_b = coin_order( c[0], c[1] )
      execute(coin_a.id, coin_b.id)
    end

    trade2acnt

    coincomb.each do | c |
      coin_a, coin_b = coin_order(c[0], c[1])
      makeplot(coin_a, coin_b)
    end

    logger.info('coin-combination: ' + coincomb.to_s)
    logger.info('Orderbook.totalprcess end: ' + Time.now.to_s)
  end

  def self.execute(coin1, coin2)  # receive cointype_id

    logger.debug('Orderbook.execute start:' + coin1.to_s + ':' + coin2.to_s )

    #check if there are overlaps or not between sell and buy
    sellcount = Order.openor.coins(coin1, coin2).where(buysell: true).count
    buycount = Order.openor.coins(coin1, coin2).where(buysell: false).count
    if ( sellcount == 0 || buycount == 0 ) then return false end

    # binding.pry

    minval = Order.openor.coins(coin1, coin2).where(buysell: true).minimum(:rate)
    maxval = Order.openor.coins(coin1, coin2).where(buysell: false).maximum(:rate)
    if minval > maxval then return false end


    sells = Order.openor.coins(coin1, coin2).match_order_sell(maxval)
    buys = Order.openor.coins(coin1, coin2).match_order_buy(minval)
    nsells = sells.count
    nbuys  = buys.count

#    binding.pry

    # 付き合わせ
    i = 0
    j = 0
    last_executed_value = nil

    while (i < nsells && j < nbuys)
      if sells[i].rate > buys[j].rate then break end
  
      # binding.pry

      if sells[i].amt_a > buys[j].amt_a then
        
        coinamt_a = buys[j].amt_a
        begin
          ActiveRecord::Base.transaction do
            create_trade(sells[i].id, buys[j].id, coin1, coin2, coinamt_a, coinamt_a * sells[i].rate, Trade.flags[:tr_new])
            create_trade(buys[j].id, sells[i].id, coin1, coin2, coinamt_a, buys[j].amt_b, Trade.flags[:tr_new])
            # create_trade(sells[i].id, buys[j].id, coin1, coin2, 0, buys[j].amt_b - coinamt_a * sells[i].rate, Trade.flags[:tr_diffwip])

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
          logger.error('cannot save Trades and Orders properly Orders id: ' + sells[i].id.to_s + ':' + buys[j].id.to_s )
          return
        end
        last_executed_value = buys[j].rate
        j += 1

        # binding.pry

      elsif sells[i].amt_a < buys[j].amt_a then

        coinamt_a = sells[i].amt_a
        begin
          ActiveRecord::Base.transaction do
            create_trade(sells[i].id, buys[j].id, coin1, coin2, coinamt_a, sells[i].amt_b, Trade.flags[:tr_new])
            create_trade(buys[j].id, sells[i].id, coin1, coin2, coinamt_a, coinamt_a * buys[j].rate, Trade.flags[:tr_new])
            # create_trade(sells[i].id, buys[j].id, coin1, coin2, 0, coinamt_a * buys[j].rate - sells[i].amt_b, Trade.flags[:tr_diffwip])

            buys[j].amt_a -= coinamt_a
            buys[j].amt_b -= coinamt_a * buys[j].rate
            buys[j].flag = Order.flags[:open_per]

            # binding.pry

            sells[i].amt_a = 0    # -= sells[i].amt_a
            sells[i].amt_b = 0    # -= sells[i].amt_b 
            sells[i].flag = Order.flags[:exec_exec]
            sells[i].save!
            buys[j].save!
          end
        rescue => e
          logger.error('cannot save Trades and Orders properly Orders id: ' + sells[i].id.to_s + ':' + buys[j].id.to_s )
          return
        end

        last_executed_value = sells[i].rate
        i += 1
        # binding.pry
      else   # sells[i].amt_a == buys[j].amt_a
        coinamt_a = sells[i].amt_a
        begin
          # binding.pry
          ActiveRecord::Base.transaction do
            create_trade(sells[i].id, buys[j].id, coin1, coin2, coinamt_a, sells[i].amt_b, Trade.flags[:tr_new])
            create_trade(buys[j].id, sells[i].id, coin1, coin2, coinamt_a, buys[j].amt_b, Trade.flags[:tr_new])
            # create_trade(sells[i].id, buys[j].id, coin1, coin2, 0, buys[j].amt_b - sells[i].amt_b, Trade.flags[:tr_diffwip])

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

        last_executed_value = sells[i].rate
        i +=1
        j +=1
        # binding.pry
      end
    end
    coin_r = CoinRelation.find_by(coin_a_id: coin1, coin_b_id: coin2)
    coin_r.rate_act = last_executed_value
    coin_r.save
    logger.debug('Orderbook.execute end:' )
  end

  def self.create_trade(id1, id2, coin1, coin2, amt_a, amt_b, flag)

    order = Order.find(id1)
    amt_a_diff = 0
    amt_b_diff = 0
    if order.buysell then
      txrate = order.coin_b.fee_trd
      fee = amt_b * txrate
      amt_b -= fee
      amt_b_diff = fee
    else
      txrate = order.coin_a.fee_trd
      fee = amt_a * txrate
      amt_a -= fee
      amt_a_diff = fee
    end
  #  binding.pry

#      Trade.create!(order_id: id1,  opps_id: id2, amt_a: amt_a, amt_b: amt_b, fee: fee, flag: flag)
    Trade.create!(order_id: id1, coin_a_id: coin1, coin_b_id: coin2, amt_a: amt_a, amt_b: amt_b, fee: fee, flag: flag)
    Trade.create!(order_id: id1, coin_a_id: coin1, coin_b_id: coin2, amt_a: amt_a_diff, amt_b: amt_b_diff, fee: 0, flag: Trade.flags[:tr_diffwip])
  end

  def self.trade2acnt

    logger.debug('Orderbook.trade2acnt start:')

    count = Trade.where(flag: Trade.flags[:tr_new]).count
    # puts "trade new count: #{count}"
    if count > 0 then
      trades = Trade.where(flag: Trade.flags[:tr_new])

      # binding.pry

      trades.each do | tr |
        usrid = tr.order.user_id
        coin1 = tr.order.coin_a_id
        coin2 = tr.order.coin_b_id

        ActiveRecord::Base.transaction do

          # binding.pry
          # puts "here"
          # puts tr.flag
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
          # puts 'Order controller Update: cannot get order data from DB'
          # puts "class:#{e.class}"
          # puts "msg:#{e.message}"
        end
      end
    end

    count = Trade.where(flag: Trade.flags[:tr_diffwip]).count
    # puts "trade diffwip count: #{count}"

    if count > 0 then

      trades = Trade.where(flag: Trade.flags[:tr_diffwip])

      trades.each do | tr |
        usrid = User.first.id   # TODO 修正必要
        coin1 = tr.order.coin_a_id
        coin2 = tr.order.coin_b_id

        ActiveRecord::Base.transaction do
          acntA = Acnt.lock.find_by(user_id: usrid, cointype_id: coin1)
          acntB = Acnt.lock.find_by(user_id: usrid, cointype_id: coin2)
          acntA.balance += tr.amt_a
          acntB.balance += tr.amt_b
          tr.flag = :tr_diffdone
          acntA.save!
          acntB.save!
          tr.save!
        end 
      end
    end

    logger.debug('Orderbook.trade2acnt end:')

  rescue => e
    logger.error('cannot save data at Transaction')
    logger.error('class:' + e.class.to_s)
    logger.error('msg' + e.message)
  end




  def self.makeplot(coin1, coin2)  # receive Cointype objects
    logger.info('Orderbook.makeplot start:' + coin1.to_s + ':' + coin2.to_s )


    coin_r = CoinRelation.find_by(coin_a: coin1, coin_b: coin2)
    step_min = coin_r.step_min
    step_half = step_min / 2.0
    mid = coin_r.rate_act

    return if ( !mid || mid == 0 )

    borders = Order.openor.coins(coin1.id, coin2.id)
            .where('? <= rate AND rate < ?', mid - step_half, mid + step_half)
    borders_sell = borders.where(buysell: true).sum(:amt_a)
    borders_buy  = borders.where(buysell: false).sum(:amt_a)

    if(borders_sell < borders_buy) then
      arr = Array.new(20) { |idx| (10 - idx) * step_min + mid}
      border = mid + step_half
    else
      arr = Array.new(20) { |idx| ( 9 - idx) * step_min + mid}
      border = mid - step_half       
    end

    mx = -1
    plotdata = arr.each_with_object([]) do | base, result |
      buysell = base > border ? true : false
      sum = Order.openor.coins(coin1, coin2).where(buysell: buysell).
        where('? <= rate AND rate < ?', base - step_half, base + step_half).sum(:amt_a)
      if sum > 0 then
        result << [base, sum, buysell]
        if sum > mx then
          mx = sum
        end
      end
    end

    return if ( mx == -1 )

    lang = ['en', 'ja']
    if step_min >= 1 then
      round_d = 0 
    else
      round_d = 1
    end
    # puts "here", coin1, coin2, step_min, round_d
    for la in lang
      filename = Cointype.find(coin1).ticker + '-' + Cointype.find(coin2).ticker + '_hist_' + la + '.html'
      fl = File.open("./public/plotdata/#{filename}", "w+")
      if (plotdata.any?) then
        fl.puts %Q[<table>]
        if la == 'ja' then
          fl.puts %Q[<tr><th width="35%">売注文数量</th><th width="30%">レート</th><th width="35%">買注文数量</th></tr>]
        elsif la == 'en' then
          fl.puts %Q[<tr><th width="35%">Ask size</th><th width="30%">Rate</th><th width="35%">Bit size</th></tr>]
        end
        if plotdata.any? {|x| x[2] == true } then
          plotdata.each do |x|
            if x[2] then
              fl.puts %Q[<tr>
                <td><div class="graph"><div class ="bar1" style="width:#{(x[1] * 100 / mx).floor}%"></div><p>#{x[1]}</p></div></td>]
              if round_d == 0 then
                fl.puts %Q[<td>#{ sprintf("%d", x[0].round(0)) }</td>]
              else
                fl.puts %Q[<td>#{ sprintf("%.1f", x[0].round(1)) }</td>]
              end
              fl.puts %Q[<td></td>
                </tr>]
            end
          end
        end
        if plotdata.any? {|x| x[2] == false } then
          plotdata.each do |x|
            if !(x[2]) then
              fl.puts %Q[<tr>
                <td></td>]
              if round_d == 0 then
                fl.puts %Q[<td>#{ sprintf("%d", x[0].round(0)) }</td>]
              else
                fl.puts %Q[<td>#{ sprintf("%.1f", x[0].round(1)) }</td>]
              end
              fl.puts %Q[<td><div class="graph"><div class ="bar2" style="width:#{(x[1] * 100 / mx).floor}%"></div><p>#{x[1]}</p></div></td>
                </tr>]
            end
          end
        end
        fl.puts %Q[</table>]
      end
      fl.close
    end

    logger.info('Orderbook histgram created :' + filename)   
    logger.info('Orderbook.makeplot end:' )
  end

end
