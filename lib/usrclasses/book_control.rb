class BookControl

  extend CoinUtil

  mattr_accessor :logger
  self.logger ||= Rails.logger

  def self.totalprocess
    logger.info('BookControl.totalprcess start: ' + Time.now.to_s)

    crs = CoinRelation.all
    obj = BookMake.new

    crs.each do | cr |
      Orderbook.execute(cr)
    end
    Orderbook.trade2acnt

    obj.control

    crs.each do | cr |
      Orderbook.execute(cr)
    end
    Orderbook.trade2acnt

    crs.each do | cr |
      Orderbook.makedepth( cr )
      Orderbook.makeplot( cr )
    end

    logger.info('BookControl.totalprcess end: ' + Time.now.to_s)
  end

end
