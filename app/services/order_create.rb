class OrderCreate

  mattr_accessor :logger
  self.logger ||= Rails.logger

	def initialize(order)
	  @order = order
	end

  def prep_acnt_with_order?
    if @order.buysell
      prep_acnt_with_order_sub(@order.coin_a_id, :amt_a)
    else
      prep_acnt_with_order_sub(@order.coin_b_id, :amt_b)
    end
  end

  def save_new_order_with_acnt!
    begin
      retry_on_error(3) { transaction_order_acnt }
    rescue => e
      logger.error('New order: order and anct NOT saved.')
      logger.error('class:' + e.class.to_s)
      logger.error('msg:' + e.message)
      raise $!
    else
      logger.info('New_order: order and anct saved. Order_id:' + @order.id.to_s + ' acnt_id:' + @acnt.id.to_s)
      # puts('New_order: order and anct saved. Order_id:' + @order.id.to_s + ' acnt_id:' + @acnt.id.to_s)
    end
  end

 private

    def prep_acnt_with_order_sub(coin_id, acnt_amt)
      @acnt = Acnt.find_by(user_id: @order.user_id, cointype_id: coin_id)
      @acnt.lock_amt(@order.send(acnt_amt))
      unless @acnt.valid?
        @order.errors.add(acnt_amt, I18n.t('errors.messages.order.free_bal_not_enough'))      
        return false
      end
      return true
    end

    def transaction_order_acnt
      ActiveRecord::Base.transaction do
        @order.save!
        @acnt.save!
      end
    end

    def retry_on_error(retry_count, &block)
      block.call
    # rescue ActiveRecord::StatementInvalid
    rescue => e
      # cope with "Mysql2::Error: Deadlock found ..." exception
      if retry_count > 0
        sleep 0.2
        retry_count -= 1
        # puts "Retry execution (#{retry_count} retry left) .."
        retry
      else
        # to give ActiveRecord::StatementInvalid
        raise $!
      end
    end

  end