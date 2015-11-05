class Pricehistproc

	extend CoinUtil

  mattr_accessor :logger
  self.logger ||= Rails.logger

  def self.totalprocess
    logger.info('Pricehistporc.totalprcess start:' + Time.now.to_s)
    coincomb = Cointype.tickercomb
    coincomb.each do | c |
      coin_a, coin_b = coin_order(c[0], c[1])
      execute(coin_a.id, coin_b.id)
    end

    coincomb.each do | c |
      coin_a, coin_b = coin_order(c[0], c[1])
      makeplot(coin_a.id, coin_b.id)
    end

    logger.info('coin-combination: ' + coincomb.to_s)
    logger.info('Pricehistproc.totalprcess end: ' + Time.now.to_s)
  end

  def self.execute(coin1, coin2) # receive cointype_id
    #1hごとのデータを作る場合のみに対応。もし、5min, 15min, などを入れるときは修正必要！

    logger.debug('Pricehistproc.execute start: ' + coin1.to_s + ':' + coin2.to_s )

    last_time = 0

    pricehistcount = PriceHist.coins(coin1, coin2).where(ty: PriceHist.ties[:hr_1]).count
    tradecount = Trade.coins(coin1, coin2).where(flag: Trade.flags[:tr_close] ).count
    if pricehistcount > 0 then
      pricehist_last = PriceHist.coins(coin1, coin2).where(ty: PriceHist.ties[:hr_1]).order('dattim DESC').first
      pricehist_id = pricehist_last.id
      time_e = pricehist_last.dattim.to_i
      last_time = Time.at(time_e)
    elsif tradecount > 0 then
      time_e = Trade.coins(coin1, coin2).where(flag: Trade.flags[:tr_close] ).order('updated_at ASC').first.updated_at.to_i      
    else
      logger.info('No transction yet: ' + coin1.to_s + ':' + coin2.to_s )
      return
    end

    logger.debug('Pricehistproc.execute time_e: ' + Time.at(time_e).to_s )

    hr_e = time_e / (60 * 60)
    from_e = hr_e * (60 * 60)  # make epoc time

    from = Time.at(from_e)
    to = from + (60 * 60) -1
    now = Time.now

    while (from <= now)
      trades = Trade.coins(coin1, coin2).where(flag: Trade.flags[ :tr_close ]).where("updated_at >= ? AND updated_at <= ?", from, to).order('updated_at ASC')

      if trades.count > 0 then
        if from == last_time then    # もし、時間で　1hr　以外を使い始めると、ロジックがおかしくなる。
          pricehist = PriceHist.find( pricehist_id )
        else
          pricehist = PriceHist.new
        end
        ords = []
        trades.each do | tr |
           ords << tr.order.rate
        end
        pricehist.mx = ords.max
        pricehist.mn = ords.min

        pricehist.st = trades.first.order.rate
        pricehist.en = trades.last.order.rate
        pricehist.vl = trades.sum(:amt_a)     # 2で割る必要があるのではないか？
        pricehist.dattim = from
        pricehist.ty = :hr_1        # see app/model/pricehist.rb
        pricehist.coin_a_id = coin1
        pricehist.coin_b_id = coin2

        pricehist.save

      end
      from += (60 * 60)
      to += (60 * 60)
    end
    logger.debug('Pricehistproc.execute end: ')
  end

  def self.makeplot(coin1, coin2) # receive cointype_id
    logger.debug('Pricehistproc.makeplot start:' + coin1.to_s + ':' + coin2.to_s )

    tnow = Time.now
    hr = tnow.to_i / (60 * 60)
    from_e = (hr - 48 + 1) * (60 * 60)
    from = Time.at(from_e)

    prmonas = PriceHist.coins(coin1, coin2).where(ty: PriceHist.ties[:hr_1]).where("dattim >= ? AND dattim <= ?", from, tnow).order(dattim: :asc)
    # 本当は、重複がないかチェックが必要！
    # 後で修正
    plotdata = []
    prmonas.each do | pl |
      plotdata << [ pl.dattim.strftime("%Y-%m-%d %H:%M"), pl.st.round(3), pl.mx.round(3), pl.mn.round(3), pl.en.round(3) ]
    end
    ticker1 = Cointype.find(coin1).ticker
    ticker2 = Cointype.find(coin2).ticker
    filename = ticker1 + '-' + ticker2 + '_candle'
    min = from.strftime("%m/%d-%H:00")
    max = (tnow + (60*59)).strftime("%m/%d-%H:00")
    plottitle = min + ' ~ '+ max
    plotmin = Time.at(((( hr - 47)/ 4 ) * 4 - 1) * 60 * 60).strftime("%Y-%m-%d %H:00")
    plotmax = Time.at(((( hr + 5)/ 4 ) * 4 - 1) * 60 * 60).strftime("%Y-%m-%d %H:00")
    plotylabel = ticker1 + '-' + ticker2 + ' Rate'

    filecont = <<EOF
      (function() {
        var plot1;
        plot1 = $.jqplot(
          "#{filename}",
          [
            #{plotdata} 
          ],
          {
            title: '#{plottitle}',
            seriesDefaults: {
              renderer: jQuery . jqplot . OHLCRenderer,
              rendererOptions: {
                candleStick: true,
                fillUpBody: true,
                fillDownBody: true,
                upBodyColor: 'blue',
                downBodyColor: 'red'
              }
            },
            axes:{
              xaxis:{
                renderer: jQuery . jqplot . DateAxisRenderer,
                min: '#{plotmin}',
                max: '#{plotmax}',
                tickRenderer: jQuery . jqplot . CanvasAxisTickRenderer,
                tickInterval: '4 hours',
                tickOptions:{
                  formatString: '%d-%H:00',
                  angle: -60,
                  fontSize: '8pt'
                },
                label: "Date - Time"
              },
              yaxis:{
                labelRenderer: jQuery . jqplot . CanvasAxisLabelRenderer,
                label: '#{plotylabel}'
              }
            }
          }
        );
        plot1.replot();
        } )();
EOF
    filename = Cointype.find(coin1).ticker + '-' + Cointype.find(coin2).ticker + '_candle.js'
    File.open("./public/plotdata/#{filename}", "w+") do |f|
    # File.open('./app/views/layouts/_plot.html.erb', "w+") do |f|
      f.write(filecont)
    end
    logger.debug('Price candle chart created:' + filename)    
    logger.debug('Pricehistproc.makeplot end:')
  end

end