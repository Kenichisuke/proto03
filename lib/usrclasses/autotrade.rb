require 'zaif'
require 'pp'

class Autotrade

  extend CoinUtil

  def self.checkweb

    coin_a, coin_b = coin_order("BTC", "MONA")
=begin
  	api = Zaif::API.new
  	a = api.get_last_price(coin_b.ticker.downcase, coin_a.ticker.downcase)
  	b = api.get_last_price(coin_b.ticker.downcase)
  	c = api.get_last_price(coin_a.ticker.downcase)

    mini, maxi  = [1.0/a, c/b].minmax
    avrg = ((mini + maxi)/2.0).round( -1)
    # TODO use Coinrelation info
    upperlim = avrg + 50
    lowerlim = avrg - 50
#    user = User.where(admin: true).second
    user = User.third      # これは変更が必要！！！！
    orders = Order.openor.coins(coin_a.id, coin_b.id).where(user_id: user.id).where('rate < ?', lowerlim)
    orders.each do | ord |
      orderobj = OrdersController.new
      orderobj.update_cancel(ord)
      orderobj.save_order_cancellation!
    end
    orders = Order.openor.coins(coin_a.id, coin_b.id).where(user_id: user.id).where('rate > ?', upperlim)
    orders.each do | ord |
      orderobj = OrdersController.new
      orderobj.update_cancel(ord)
      orderobj.save_order_cancellation!

      # サービスクラスに切り出す！！！！

    end

=end

    coinrel = CoinRelation.find_by(coin_a_id: coin_a.id, coin_b_id: coin_b.id)

    avrg = 2580
    lowerlim = avrg - 50
    coinrel.rate_act = 2500
    
    if coinrel.rate_act < avrg then
      max1 = [lowerlim, coinrel.rate_act ].max
      num = ((avrg - max1)/10).round(0)
      tempary = Array ((max1 / 10) + 1).to_i ... (avrg/10).to_i 
      sellary = tempary.map{ | i | i * 10 }
      binding.pry
    end

    binding.pry
    # puts 'min:' + mini.to_s
    # puts 'max:' + maxi.to_s
    # puts 'avg:' + avrg.to_s
    
    # check order in this site
  end

  def self.clearorder
  end

  def self.makeorder
  end

end
