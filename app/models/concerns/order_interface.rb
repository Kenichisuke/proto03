module OrderInterface
  extend ActiveSupport::Concern
  
  def order_create(usr_id, coin1_t, coin2_t, buysell, amt_a, amt_b)
    coin1_id = Cointype.find_by(ticker: coin1_t)
    coin2_id = Cointype.find_by(ticker: coin2_t)
    rate = (1.0 * amt_b) / amt_a
    flag = Order.flag("open_new")
    order = Order.new(user_id: user_id, coin_a_id: coin1_id, coin_a_id: coin1_id,
               amt_a: amt_a, amt_a: amt_b, amt_a_org: amt_a, amt_a: amt_b_org, 
               buysell: buysell, rate: rate, flag: flag )

    unless order.valid?
    	return false
    end

    unless valid_acnt_with_order(order)?
      return false 
    end

    begin
      save_new_order!
    rescue => e
      @order.errors.add(:base, I18n.t('errors.messages.order.try_later'))      
      return false
    end
  end

  private
    def valid_acnt_with_order(ord)?
      if ord.buysell
      	valid_acnt_with_order_sub(ord.coin_a_id, "amt_a")?
      else
      	valid_acnt_with_order_sub(ord.coin_b_id, "amt_b")?
      end  
    end

    def valid_acnt_with_order_sub(ord, ord_coin_id, acnt_amt)?
      acnt = Acnt.find_by(user_id: ord.user_id, cointype_id: ord_coin_id)
      acnt.lock_amt(ord.send(acnt_amt))
      if acnt.valid? then
        return true
      else
        ord.errors.add(acnt_amt, I18n.t('errors.messages.order.free_bal_not_enough'))      
        return false
      end
    end

    def save_new_order!
      ActiveRecord::Base.transaction do
        @order.save!
        @acnt.save!
      end
      logger.info('New order: order and anct saved.')
      # logger.info('New order: order and anct saved. Order_id:' + @order.id.to_s + ' acnt_id:' + @acnt.id.to_s)
    rescue => e
      logger.error('New order: order and anct NOT saved.')
      logger.error('class:' + e.class.to_s)
      logger.error('msg' + e.message)
      raise
    end
end
