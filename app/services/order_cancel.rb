class OrderCancel

  # TODO 現在（2015/12/3時点では、誰のオーダーでも操作できる。修正必要！！）
  # サブクラスを作って、そこでユーザー認証などをさせる必要があるだろう。

  mattr_accessor :logger
  self.logger ||= Rails.logger

  def initialize(order)
	  @order = order
	end

  def prep_cancel?
    unless ( @order.open_new? || @order.open_per?) 
      return false
    end

    # if @order.buysell then
    #   @acnt = Acnt.find_by(user_id: @order.user.id, cointype_id: @order.coin_a)
    #   amt = @order.amt_a
    # else
    #   @acnt = Acnt.find_by(user_id: @order.user.id, cointype_id: @order.coin_b)
    #   amt = @order.amt_b
    # end
    amt = @order.send( @order.buysell ? :amt_a : :amt_b)
    @acnt = Acnt.find_by(user: @order.user, cointype: @order.send( @order.buysell ? :coin_a : :coin_b))
    @acnt.unlock_amt(amt)
    @trade = Trade.new(order_id: @order.id, amt_a: @order.amt_a, amt_b: @order.amt_b, fee: 0, flag: Trade.flags[:tr_cncl] )
    @order.amt_a = 0
    @order.amt_b = 0
    @order.flag = @order.open_new? ? Order.flags[:noex_cncl] : Order.flags[:exec_cncl]
    return true
  end

  def save_cancel!
    begin
      retry_on_error(3) { transaction_order_cancel }
    rescue => e
      logger.error('Cancel order: order, anct and trade NOT saved.')
      logger.error('class:' + e.class.to_s)
      logger.error('msg:' + e.message)
      logger.error("order_id: #{@order.id}")
      logger.error("coins: #{@order.coin_a.ticker} : #{@order.coin_b.ticker}")
      raise $!
    else
      logger.info('Cancel order: order, anct and trade saved. Order_id:' + @order.id.to_s + ' acnt_id:' + @acnt.id.to_s + ' trade_id:' + @trade.id.to_s)
    end
  end
  

  private

    def transaction_order_cancel
      ActiveRecord::Base.transaction do
        @order.save!
        @acnt.save!
        @trade.save!
      end
    end

    def retry_on_error(retry_count, &block)
      block.call
    rescue => e
      # rescue ActiveRecord::StatementInvalid => e
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