class Walletcheck

  extend CoinUtil

  mattr_accessor :logger
  self.logger ||= Rails.logger

  def self.totalprocess
    logger.info('Walletcheck.totalprcess start: ' + Time.now.to_s)

    coin_ts = Cointype.tickers
    coin_ts.each do | co |
      execute( coin_t2i( co ) )
    end

    logger.info('cointype: ' + coin_ts.to_s)  
    logger.info('Walletcheck.totalprcess end: ' + Time.now.to_s)      
  end

  def self.execute(coin_id) # receive cointype_id
    # Walletに入金があったかをチェックする。これは、Wheneverで動かす予定。

    coin = Cointype.find(coin_id)

    logger.debug('Walletcheck.execute start: ' + coin.ticker)      
    logger.debug('the number of transactions: ' + Coinio.where(cointype: coin.id).pickup_categ.count.to_s)      

    if Coinio.where(cointype: coin.id).pickup_categ.count > 0 then
      # 過去に、coinioにcoinの入金記録がある場合。

      coinio_l = Coinio.where(cointype: coin.id).pickup_categ.last

      tx_found = false
      n_pickup = 2

      while !tx_found # Walletに取引情報がない間ループが回る。
        indx = 0
        n_pickup *= 4

        if n_pickup > 0x3FFFFFFF then
          n_pickup = 0x3FFFFFFF
          # このif文の条件には引っかからないはず！
        elsif n_pickup == 0x3FFFFFFF then
          logger.unknown('Walletcheck.execute: n_pikcup beceme too big: ' + n_pickup.to_s)      
          raise StandardError, "tx not found in wallet."
          # このelsif文の条件には引っかからないはず！
          # to do
        end

        list = Coinrpc.listtrxs(coin.ticker, n_pickup)

        list.each do | l | 
          if l['txid']  == coinio_l.txid then
            tx_found = true
            indx += 1
            break
          end
          indx += 1
        end

        if (n_pickup > list.count) && !tx_found then 
          # （Coinioには入金情報があるのに）Walletに入金情報がない場合
          logger.unknown('Walletcheck.execute: tx exists on coinio, But not on wallet. txid: ' + coinio_l.txid)          
          raise StandardError, "tx not found in wallet."
        end
      end
    else # 過去に、coinio にcoinの入金記録がない場合。

      # coinio_l = Coinio.where(cointype: coin.id).pickup_categ.last
      # logger.debug('last record of coinio: ' + coinio_l)

      indx = 0
      n_pickup = 2
      begin
        n_pickup *= 4
        if n_pickup > 0x3FFFFFFF then
          n_pickup = 0x3FFFFFFF
          # このif文の条件には引っかからないはず！
        elsif  n_pickup == 0x3FFFFFFF then
          logger.unknown('Walletcheck.execute: n_pikcup beceme too big: ' + n_pickup.to_s) 
          raise StandardError, "tx not found in wallet."
          # このelsif文の条件には引っかからないはず！          
        end
        
        list = Coinrpc.listtrxs(coin.ticker, n_pickup) 

      end while (list.count >= n_pickup) # 取りに行ったデータ数より、実際の数が小さくなるまでループが回る。
    end

    n_save = 0
    for i in indx...list.count do
      if coinio_savedata(list[i], coin) then
        n_save += 1
      end
    end

    logger.debug('check transactions (list) from ' + indx.to_s + ' to ' + list.count.to_s)
    logger.info( n_save.to_s + ' CoinIO transactions saved: ' + coin.ticker)

      # immature として記録されているCoinioのデータの処理
      # 過去に、coinioにcoinの入金記録がある場合。
    coinio_list = Coinio.where(cointype: coin.id).where(tx_category: Coinio.tx_categories[:tx_immature])

    coinio_list.each do | co |
      l = Coinrpc.gettx(coin.ticker, co.txid)
      if l['details'][0]['category'] == "generate" then
        acnt = Acnt.find( l['account'], cointype: coin.id )
        if (co.amount - l['details']['amount']) > 1e-6 then
          logger.unknown('amount generated changed. txid: ' + co.txid) 
          raise StandardError, "amount in wallet changed."
        end
        # acnt.balance += co.amount        
        acnt.balance += l['details'][0]['amount']
        co.category = :tx_generate
        co.flag = :in_done
        coinio.save
        acnt.save
      end
    end

    logger.debug('Walletcheck.execute end:' )
  end

  def self.coinio_savedata(l, coin)  # coinios_controller とまとめてヘルパーにするべき？s
    if (l['category']  == 'receive') then
      acnt = Acnt.find_by(acnt_num: l['account'], cointype: coin.id )
      if acnt then
        acnt.balance += l['amount']
        coinio = Coinio.new(cointype_id: coin.id, amt: l['amount'], tx_category: :tx_receive,
          flag: :in_done, txid: l['txid'], addr: l['address'], acnt_id: acnt.id, fee: 0)
        acnt.save
        coinio.save
      end
    elsif l['category']  == 'generate' then
      acnt = Acnt.find_by(acnt_num: l['account'], cointype: coin.id  )
      if acnt then
        acnt.balance += l['amount']
        coinio = Coinio.new(cointype_id: coin.id, tx_category: :tx_generate, amt: l['amount'],
               flag: :in_done, txid: l['txid'], addr: l['address'], acnt_id: acnt.id, fee: 0)
        acnt.save
        coinio.save
      end
    elsif l['category']  == 'immature' then
      acnt = Acnt.find_by(acnt_num: l['account'], cointype: coin.id  )
      if acnt then     
        coinio = Coinio.new(cointype_id: coin.id, tx_category: :tx_immature, amt: l['amount'],  
                flag: :in_yet, txid: l['txid'], addr: l['address'], acnt_id: acnt.id, fee: 0)
        coinio.save
      end
    end
  end
end

