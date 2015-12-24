require 'zaif'

class BookMake

  include CoinMath
  
  mattr_accessor :logger
  self.logger ||= Rails.logger

  def initialize
    @user = User.where(autotrader: true).sample
    logger.error("Autotrader, User id: #{ @user.id }")
    # @user = User.where(autotrader: true).first
    @ratefs = RateFromSite.new
  end


  def control
    crs = CoinRelation.all
    crs.each do | cr |
      tradeinfo = @user.autotrades.find_by(coin_relation: cr)
      rate = @ratefs.rate(cr)
      # binding.pry
      next unless rate
      next if rate.zero?
      next if ((tradeinfo.rate_ref - rate).abs <= tradeinfo.trig)
      next if rate < cr.step_min

      upper_lim = rate + tradeinfo.range
      lower_lim = [ rate - tradeinfo.range, cr.step_min ].max

      # if rate > tradeinfo.rate_ref then

        # upper_limより上をキャンセル。
        cancel_openor(cr, true, upper_lim, true)
        # rateより下をキャンセル。
        cancel_openor(cr, true, rate, false)

        # Uより下, rate より上を注文
        amt_a = Acnt.find_user_cr_buysell(@user, cr, true).free_bal * tradeinfo.portion
        if cr.lot_check?( amt_a / 10.0) then
          create_openor(cr, true, rate, upper_lim, amt_a)
        end


        # 買い側
        # rateより上をキャンセル。本当はいらないはず。
        cancel_openor(cr, false, rate, true)
        # Lより下をキャンセル。
        cancel_openor(cr, false, lower_lim, false)

        # rateより下、Lより上を注文
        # amt_b = Acnt.find_user_coint(@user, "MONA").free_bal * tradeinfo.portion
        amt_b = Acnt.find_user_cr_buysell(@user, cr, false).free_bal * tradeinfo.portion
        if cr.lot_check?( amt_b / (10.0 * rate)) then
          create_openor(cr, false, rate, lower_lim, amt_b)
        end

      # else

      #   # move down
      #   # 売り側
      #   # Uより上をキャンセル。
      #   cancel_openor(cr, true, upper_lim, true)
      #   # rateより下をキャンセル。本当はいらないはず。
      #   cancel_openor(cr, true, rate, false)

      #   # Aより上、Uより下を注文
      #   # amt_a = Acnt.find_user_coint(@user, "BTC").free_bal * tradeinfo.portion
      #   amt_a = Acnt.find_user_cr_buysell(@user, cr, true).free_bal * tradeinfo.portion
      #   # binding.pry
      #   if cr.lot_check?( amt_a / 10.0) then
      #     create_openor(cr, true, rate, upper_lim, amt_a)
      #   end

      #   # 買い側
      #   # Aより上をキャンセル。
      #   cancel_openor(cr, false, rate, true)
      #   # lower_limより下をキャンセル。本当はいらないはず。
      #   cancel_openor(cr, false, lower_lim, false)
      #   # Lより上、rateより下を注文
      #   # amt_b = Acnt.find_user_coint(@user, "MONA").free_bal * tradeinfo.portion
      #   amt_b = Acnt.find_user_cr_buysell(@user, cr, false).free_bal * tradeinfo.portion
      #   if cr.lot_check?( amt_b / (10.0 * rate)) then
      #     create_openor(cr, false, rate, lower_lim, amt_b)
      #   end
      # end
      tradeinfo.rate_ref = rate
      tradeinfo.save
    end
  end

  def create_openor(cr, buysell, rate_base, rate_lim, total_amt)
    # create の時はイコールを入れない。
    # したがって、cr.array でfalse を入れる。

    # 作るオーダのレートの配列を作る。

=begin
    # オーダーを作る。
    # 現状では、上からオーダを作る。したがって、
    # ターゲットのレートから遠いところのオーダーのみが作られる可能性がある。
    # 最小値、最大値より範囲を決める。
    # 隙間の配列を作る方がいい。
    if updown then
      ord_lim = Order.openor.coin_rel(cr).where(buysell: buysell)
        .where("rate <= ?", rate_lim ).maximum(:rate)
      ord_lim ||= rate_lim
      return false if (ord_lim > rate_base)
      arr = cr.array( rate_base, ord_lim, false )
    else
      ord_lim = Order.openor.coin_rel(cr).where(buysell: buysell)
        .where("rate >= ?", rate_lim ).minimum(:rate)
      ord_lim ||= rate_lim        
      return false if ord_lim < rate_base
      arr = cr.array( ord_lim, rate_base, false )
    end
=end

    # オーダのないrateの配列を作る。
    arr_full_range = cr.array(rate_base, rate_lim, false)
    return false if (!arr_full_range || arr_full_range.size == 0)

    step_half = cr.step_min / 2.0
    arr_blank = arr_full_range.each_with_object([]) do | rate, result |
      if Order.openor.coin_rel(cr).where(buysell: buysell)
          .where("? <= rate AND rate < ?", rate - step_half, rate + step_half).count == 0 then
        result << rate
      end
    end

    # オーダーを作る。
    return false if arr_blank.size == 0
    amt = significant_digits(((1.0 * total_amt) / arr_blank.size), 3)   # 有効桁数を３にしている。
    omc = OrderMultiCreate.new(user: @user, coin_relation: cr);
    arr_blank.each do | rate |
      return false unless omc.add_order(rate: rate, amt: amt, buysell: buysell)
    end
    return false unless omc.check_acnt_with_order?

    begin
      omc.save_new_orders!
    rescue => e
      logger.error('book_make.rb cannot make order')
      logger.error('class: ' + e.class.to_s)
      logger.error('msg: ' + e.message)
      return false
    end
  end


  def cancel_openor(cr, buysell, line, updown)
    # updown: (true)上側を削除するか、(false)下側を削除するか
    # cancel の時はイコールを入れる。

    orders = Order.openor.coin_rel(cr).where(user_id: @user.id, buysell: buysell)
        .send( :where, ( updown ? "rate >= ?" : "rate <= ?"), line)
    orders.each do | ord |
      order_cancel = OrderCancel.new( ord )
      # TODO エラー処理、例外処理
      order_cancel.prep_cancel?
      order_cancel.save_cancel!
    end
  end

end


