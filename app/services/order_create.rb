class OrderCreate

  # TODO 現在（2015/12/3時点では、誰のオーダーでも操作できる。修正必要！！）
  # サブクラスを作って、そこでユーザー認証などをさせる必要があるだろう。

  mattr_accessor :logger
  self.logger ||= Rails.logger

	def initialize(user:, coin_relation:, rate:, buysell:, amt:)
    if buysell then
      amt_a = amt
      amt_b = rate * amt
    else
      amt_a = (1.0 * amt) / rate
      amt_b = amt
    end
    @cr = coin_relation
    @order = Order.new(user: user,
      coin_a: coin_relation.coin_a, coin_b: coin_relation.coin_b, 
      rate: rate, buysell: buysell, 
      amt_a: amt_a, amt_b: amt_b, amt_a_org: amt_a, amt_b_org: amt_b, flag: "open_new")
	end

  def check_order?
    flag = true
    unless @cr.lot_check?(@order.amt_a) then
      @order.errors.add(:amt_a, I18n.t('errors.messages.order.lot_min', lot_min: @cr.lot_min))
      flag = false
    end
    unless @cr.rate_check?(@order.rate) then
      @order.errors.add(:rate, I18n.t('errors.messages.order.step_min', step_min: @cr.step_min))
      flag = false
    end
    return false unless flag
    flag = false unless @order.valid?
    acnt = Acnt.find_by(user: @order.user, cointype: @order.send( @order.buysell ? :coin_a : :coin_b))
    unless acnt.lock_amt?( @order.send( @order.buysell ? :amt_a : :amt_b ) )
      @order.errors.add( (@order.buysell ? :amt_a : :amt_b), I18n.t('errors.messages.order.free_bal_not_enough'))
      return false
    end
    return flag
  end

  def save_new_order_with_acnt!
    @cr.depth_upper ||= @order.rate    
    @cr.depth_lower ||= @order.rate
    @cr.depth_upper = @order.rate if @cr.depth_upper < @order.rate
    @cr.depth_lower = @order.rate if @cr.depth_lower > @order.rate
    @cr.save

    amt = @order.send( @order.buysell ? :amt_a : :amt_b)
    @acnt = Acnt.find_by(user: @order.user, cointype: @order.send( @order.buysell ? :coin_a : :coin_b))
    @acnt.lock_amt( amt )
    begin
      retry_on_error(3) { transaction_order_acnt }
    rescue => e
      @acnt.unlock_amt( amt)
      logger.error('New order: order and anct NOT saved.')
      logger.error('class: ' + e.class.to_s)
      logger.error('msg: ' + e.message)
      raise $!
    else
      logger.info('New_order: order and anct saved. Order_id:' + @order.id.to_s + ' acnt_id:' + @acnt.id.to_s)
    end
  end

  # エラーメッセージを出すために必要。
  def get_order
    @order
  end

  def get_order_buysell
    @order.buysell
  end

  def get_order_amt
    @order.send( @order.buysell ? :amt_a : :amt_b )
  end


  private

    # 分けている理由
    # スタブを使ってテストできるようにするため。

    def transaction_order_acnt
      ActiveRecord::Base.transaction do
        @order.save!
        @acnt.save!
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
        retry
      else
        raise $!
      end
    end

end