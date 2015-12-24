class Orderbook

  extend CoinUtil

  mattr_accessor :logger
  self.logger ||= Rails.logger

  N_DISPLAY_BOOK = 10

  def self.totalprocess
    logger.info('Orderbook.totalprcess start: ' + Time.now.to_s)

    crs = CoinRelation.all

    crs.each do | cr |
      execute(cr)
    end

    trade2acnt

    crs.each do | cr |
      makedepth(cr)
      makeplot(cr)
    end

    logger.info('Orderbook.totalprcess end: ' + Time.now.to_s)
  end

  def self.execute(cr)  # receive cointype_id

    logger.debug('Orderbook.execute start:' + cr.coin_a.ticker + ':' + cr.coin_b.ticker )

    #check if there are overlaps or not between sell and buy
    sellcount = Order.openor.coin_rel( cr ).where(buysell: true).count
    buycount = Order.openor.coin_rel( cr ).where(buysell: false).count
    if ( sellcount == 0 && buycount == 0 ) then 
      cr.rate_act = 0
      cr.save
      logger.debug('Orderbook.execute end:' )
      return false 
    elsif( sellcount == 0 && buycount != 0 ) then 
      cr.rate_act = Order.openor.coin_rel( cr ).where(buysell: false).maximum(:rate)
      cr.save      
      logger.debug('Orderbook.execute end:' )
      return false
    elsif ( sellcount != 0 && buycount == 0 ) then 
      cr.rate_act = Order.openor.coin_rel( cr ).where(buysell: true).minimum(:rate)
      cr.save
      logger.debug('Orderbook.execute end:' )
      return false
    end

    # binding.pry

    minval = Order.openor.coin_rel( cr ).where(buysell: true).minimum(:rate)
    maxval = Order.openor.coin_rel( cr ).where(buysell: false).maximum(:rate)

    if minval > maxval then
      cr.rate_act = cr.represent_value( (maxval + minval) / 2.0 )
      cr.save
      logger.debug('Orderbook.execute end:' )
      return false 
    end

    # coin_r = CoinRelation.find_by(coin_a: coin1, coin_b: coin2)
    cr.depth_upper = minval if cr.depth_upper < minval
    cr.depth_lower = maxval if cr.depth_lower < maxval
    cr.save

    sells = Order.openor.coin_rel( cr ).match_order_sell(maxval)
    buys = Order.openor.coin_rel( cr ).match_order_buy(minval)
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
            create_trade(sells[i].id, buys[j].id, cr, coinamt_a, coinamt_a * sells[i].rate, Trade.flags[:tr_new])
            create_trade(buys[j].id, sells[i].id, cr, coinamt_a, buys[j].amt_b, Trade.flags[:tr_new])
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
          logger.error('1. cannot save Trades and Orders properly Orders id: ' + sells[i].id.to_s + ':' + buys[j].id.to_s )
          logger.error('class: ' + e.class.to_s)
          logger.error('msg: ' + e.message)
          return
        end
        last_executed_value = buys[j].rate
        j += 1

        # binding.pry

      elsif sells[i].amt_a < buys[j].amt_a then

        coinamt_a = sells[i].amt_a
        begin
          ActiveRecord::Base.transaction do
            create_trade(sells[i].id, buys[j].id, cr, coinamt_a, sells[i].amt_b, Trade.flags[:tr_new])
            create_trade(buys[j].id, sells[i].id, cr, coinamt_a, coinamt_a * buys[j].rate, Trade.flags[:tr_new])
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
          logger.error('2. cannot save Trades and Orders properly Orders id: ' + sells[i].id.to_s + ':' + buys[j].id.to_s )
          logger.error('class: ' + e.class.to_s)
          logger.error('msg: ' + e.message)
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
            create_trade(sells[i].id, buys[j].id, cr, coinamt_a, sells[i].amt_b, Trade.flags[:tr_new])
            create_trade(buys[j].id, sells[i].id, cr, coinamt_a, buys[j].amt_b, Trade.flags[:tr_new])
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
          logger.error('3. cannot save Trades and Orders properly Orders id: ' + sells[i].id.to_s + ':' + buys[j].id.to_s )
          logger.error('class: ' + e.class.to_s)
          logger.error('msg: ' + e.message)
        end

        last_executed_value = sells[i].rate
        i +=1
        j +=1
        # binding.pry
      end
    end
    # coin_r = CoinRelation.find_by(coin_a_id: coin1, coin_b_id: coin2)
    cr.rate_act = last_executed_value
    cr.save
    logger.debug('Orderbook.execute end:' )
  end

  def self.create_trade(id1, id2, cr, amt_a, amt_b, flag)

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
    Trade.create!(order_id: id1, coin_a_id: cr.coin_a_id, coin_b_id: cr.coin_b_id, amt_a: amt_a, amt_b: amt_b, fee: fee, flag: flag)
    Trade.create!(order_id: id1, coin_a_id: cr.coin_a_id, coin_b_id: cr.coin_b_id, amt_a: amt_a_diff, amt_b: amt_b_diff, fee: 0, flag: Trade.flags[:tr_diffwip])
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


  def self.makedepth(cr) # need to make

    now = Time.current
    cr.depth_fullupdate ||= now.since(-365.days)

    if now > cr.depth_fullupdate.since(-1.day) then    # 本番では使わない
#    if now > cr.depth_fullupdate.since(1.day) then    # 本番では使う

      maxval = Order.openor.coin_rel(cr).maximum(:rate)
      minval = Order.openor.coin_rel(cr).minimum(:rate)
      Depth.where(coin_relation: cr).delete_all

      if maxval == nil then   # データがなければ終了
        cr.depth_fullupdate = now
        cr.save
        return false
      end
    else 
      return false unless cr.depth_upper && cr.depth_lower
      maxval = cr.depth_upper
      minval = cr.depth_lower
      Depth.where(coin_relation: cr)
        .where("? <= rate AND rate <= ?", minval, maxval).delete_all
    end


    arr = cr.array(maxval, minval, true)
    return false if (!arr || arr.size == 0)

    step_half = cr.step_min / 2.0
    arr.each_with_object([]) do | rate |
      orders = Order.openor.coin_rel(cr).
        where('? <= rate AND rate < ?', rate - step_half, rate + step_half)
      [true, false].each do | buysell |  
        sum = orders.where(buysell: buysell).sum(:amt_b)
        if sum > 0 then
          Depth.create(coin_relation: cr, rate: rate, amt: sum, buysell: buysell)
        end 
      end
    end

    # depth_data = sort_depth(cr, maxval, minval)

    # error = 0
    # buy_h = nil
    # depth_data.each_with_index do | data, idx |
    #   if data[1] > 0 && data[2] > 0 then
    #     error += 1
    #   end
    #   if data[2] > 0 then
    #     buy_h ||= data[0]
    #   end
    # end

    # buy_h = 0 unless buy_h
    # if error == 0 then
    #   Depth.where(coin_relation: cr)
    #     .where("? <= rate AND rate <= ?", minval, maxval).delete_all

    #   depth_data.each do | data |
    #     amt = data[0] > buy_h ? data[1] : data[2]
    #     Depth.create(coin_relation: cr, rate: data[0], amt: amt)
    #   end
    #   cr.rate_ref = buy_h ? buy_h : 0
      cr.depth_fullupdate = now
      cr.depth_upper = cr.rate_act
      cr.depth_lower = cr.rate_act
      cr.save
    # else
    #   mailcont = { 'coin1' => cr.coin_a.name, 'coin2' => cr.coin_b.name }
    #   Contactmailer.error_depth_email(mailcont).deliver_now
    # end
  end

  def self.makeplot(cr)  # receive CoinRelation objects
    
    logger.info('Orderbook.makeplot start:' + cr.coin_a.name + ':' + cr.coin_b.name )

    if Depth.where(coin_relation: cr).count > 0 then
      sells = Depth.where(coin_relation: cr, buysell: true).order('rate ASC').limit(N_DISPLAY_BOOK * 2)
      buys = Depth.where(coin_relation: cr, buysell: false).order('rate DESC').limit(N_DISPLAY_BOOK * 2)

      # ソートする
      # bookdata の構造
      # [rate, sell のamt の金額, buy のamt の金額]
      bookdata = []
      i, j = 0, 0
      n_sells = [ sells.count, N_DISPLAY_BOOK * 2].min
      n_buys =  [  buys.count, N_DISPLAY_BOOK * 2].min

      while i < n_sells && j < n_buys
        if cr.represent_index( sells[n_sells - 1 - i ].rate ) > cr.represent_index( buys[j].rate) then
          bookdata << [sells[n_sells - 1 - i].rate, sells[n_sells - 1 - i].amt, 0 ]
          i += 1
        elsif cr.represent_index( sells[n_sells - 1 - i].rate ) < cr.represent_index( buys[j].rate) then
          bookdata << [buys[j].rate, 0, buys[j].amt]
          j += 1        
        else
          bookdata << [sells[n_sells - 1 - i].rate, sells[n_sells - 1 - i].amt, buys[j].amt]
          i += 1
          j += 1
        end
      end
      while i < n_sells
        bookdata << [sells[n_sells - 1 - i].rate, sells[n_sells - 1 - i].amt, 0 ]
        i += 1
      end
      while j < n_buys
        bookdata << [buys[j].rate, 0, buys[j].amt]
        j += 1      
      end

      # 表示するデータを選ぶ
      # 約定価格を中心とした上下10のデータ
      rpi = cr.represent_index(cr.rate_act)
      center_idx = ([n_sells, n_buys].max / 2 ).round(0).to_i
      bookdata.each_with_index do | dat, idx |
        if cr.represent_index( dat[0]) <= rpi then
          center_idx = idx
          break
        end
      end
      # binding.pry
      min_idx = [0,               center_idx - N_DISPLAY_BOOK].max
      max_idx = [center_idx + N_DISPLAY_BOOK,   bookdata.size].min
      plotdata = bookdata.values_at(min_idx ... max_idx)

      # max の amt_b を調べる。 
      mx = 0
      plotdata.each do | dat |
        [1,2].each do | i |
          if (dat[i] != nil && dat[i] > mx) then
            mx = dat[i]
          end
        end
      end
    else
      plotdata = []
    end

    # make HTML file
    lang = ['en', 'ja']
    if cr.step_min >= 1 then
      round_d = 0 
    else
      round_d = 1
    end
    for la in lang
      filename = cr.coin_a.ticker + '-' + cr.coin_b.ticker + '_hist_' + la + '.html'
      fl = File.open("./public/plotdata/#{filename}", "w+")
      fl.puts %Q[<table>]
      if la == 'ja' then
        fl.puts %Q[<tr><th width="35%">売注文数量</th><th width="30%">レート</th><th width="35%">買注文数量</th></tr>]
      elsif la == 'en' then
        fl.puts %Q[<tr><th width="35%">Ask size</th><th width="30%">Rate</th><th width="35%">Bit size</th></tr>]
      end
      plotdata.each do |x|
        if x[1] > 0 && x[2] == 0 then
          fl.puts %Q[<tr>
            <td><div class="graph"><div class ="bar1" style="width:#{(x[1] * 100 / mx).floor}%"></div><p>#{x[1]}</p></div></td>]
          if round_d == 0 then
            fl.puts %Q[<td>#{ sprintf("%d", x[0].round(0)) }</td>]
          else
            fl.puts %Q[<td>#{ sprintf("%.1f", x[0].round(1)) }</td>]
          end
          fl.puts %Q[<td></td>
            </tr>]
        elsif x[1] == 0 && x[2] > 0 then
          fl.puts %Q[<tr>
            <td></td>]
          if round_d == 0 then
            fl.puts %Q[<td>#{ sprintf("%d", x[0].round(0)) }</td>]
          else
            fl.puts %Q[<td>#{ sprintf("%.1f", x[0].round(1)) }</td>]
          end
          fl.puts %Q[<td><div class="graph"><div class ="bar2" style="width:#{(x[2] * 100 / mx).floor}%"></div><p>#{x[2]}</p></div></td>
            </tr>]
        elsif x[1] > 0 && x[2] > 0 then
          fl.puts %Q[<tr>
            <td><div class="graph"><div class ="bar1" style="width:#{(x[1] * 100 / mx).floor}%"></div><p>#{x[1]}</p></div></td>]
          if round_d == 0 then
            fl.puts %Q[<td>#{ sprintf("%d", x[0].round(0)) }</td>]
          else
            fl.puts %Q[<td>#{ sprintf("%.1f", x[0].round(1)) }</td>]
          end
          fl.puts %Q[<td><div class="graph"><div class ="bar2" style="width:#{(x[2] * 100 / mx).floor}%"></div><p>#{x[2]}</p></div></td>
            </tr>]
        end
      end
      fl.puts %Q[</table>]
      fl.close
    end

    logger.info('Orderbook histgram created :' + filename)   
    logger.info('Orderbook.makeplot end:' )
  end

end
