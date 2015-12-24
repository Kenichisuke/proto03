class OrderMultiCreate

#  include ActiveModel::Model  #form_for を使うのに必要

  def initialize(user:, coin_relation:)
    @user = user
    @cr = coin_relation
    @arr = []
  end

  def add_order(rate:, amt:, buysell:)
    oc = OrderCreate.new(user: @user, coin_relation: @cr, rate: rate, buysell: buysell, amt: amt)
    return false unless oc.check_order?
    @arr << oc
  end

  def check_acnt_with_order?
    amts = @arr.each_with_object(Hash.new(0)) do | ord, result |
      result[ ord.get_order_buysell ] += ord.get_order_amt
    end
    [true, false].each do | tf |
      acnt = Acnt.find_by(user: @user, cointype: @cr.send( tf ? :coin_a : :coin_b ))
      return false unless acnt.lock_amt?(amts[tf])
    end
    return true
  end

  def save_new_orders!
    # TODO 一度にトランザクションできるように修正
    begin
      @arr.each do | ord |
        ord.save_new_order_with_acnt!
      end
    rescue => e
      logger.error('order_multi_create.rb cannot make order')
      # TODO ログを残す
      raise $!
    else
    #   @arr = []  
    end
  end

  def clear
    @arr = []
  end

  def size
    @arr.size
  end

end