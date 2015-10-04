class OpenOrdersController < ApplicationController

  include CoinUtil

  before_action :authenticate_user!
  before_action :admin_user

  def new
    @admins = User.where(admin: true).order(id: :asc)
    @cointypes = Cointype.all.order(rank: :desc)
    usrid = @admins.first.id
    coin1id = @cointypes.first.id
    coin2id = @cointypes.second.id
    @open_order = OpenOrder.new(user_id: usrid, coin1: coin1id, coin2: coin2id)
  end
  

  def create
    @open_order = OpenOrder.new( open_order_params.symbolize_keys )
    @cointypes = Cointype.all
    @admins = User.where(admin: true).order(id: :asc) # in case of render 'new'

    if @open_order.coin1 == @open_order.coin2 then
      flash[ :alert ] = 'Error: same coins'
      render 'new' and return
    end
    if Cointype.find(@open_order.coin1).rank <= Cointype.find(@open_order.coin2).rank then
      flash[ :alert ] = 'Error: Order of coins is opposite'
      render 'new' and return
    end
    # お金のチェック
    if @open_order.eachamt <= 0 then
      flash[ :alert ] = 'Error: amount is negative or zero' 
      render 'new' and return
    end


    if @open_order.updown == 0 or @open_order.updown == 1 then
      @acnt = Acnt.find_by(user_id: @open_order.user.id, cointype_id: @open_order.coin1)
      if @open_order.eachamt * @open_order.eachamt > (@acnt.balance - @acnt.locked_bal) then 
        flash[ :alert ] = 'Error: account amount is not enough' 
        render 'new' and return
      end
    end
    if @open_order.updown == 0 or @open_order.updown == 2 then
      @acnt = Acnt.find_by(user_id: @open_order.user.id, cointype_id: @open_order.coin2)
      sum = open_order.num * (open_order.pr - (open_order.num + 1) * open_order.steprate / 2.0) * open_order.eachamt
      if sum >  (@acnt.balance - @acnt.locked_bal) then 
        flash[ :alert ] = 'Error: amount is negative or zero' 
        render 'new' and return
      end
    end

    if @open_order.updown == 0 or @open_order.updown == 1 then
      @acnt = Acnt.find_by(user_id: @open_order.user.id, cointype_id: @open_order.coin1)
      open_order.num.times do | i |
        Order.create(coin_a_id: @open_order.coin1 , coin_b_id: @open_order.coin2, 
          rate: open_order.pr + (i + 1) * open_order.steprate, amt_a: open_order.eachamt,
          buysell: true )
        @acnt.lock_amt(@open_order.eachamt).save
      end
    end

    if @open_order.updown == 0 or @open_order.updown == 2 then
      @acnt = Acnt.find_by(user_id: @open_order.user.id, cointype_id: @open_order.coin2)
      open_order.num.times do | i |
        rate = open_order.pr + (i + 1) * open_order.steprate
        Order.create(coin_a_id: @open_order.coin1 , coin_b_id: @open_order.coin2, 
          rate: rate, amt_a: open_order.eachamt, buysell: false )
        @acnt.lock_amt(@open_order.eachamt * rate).save
      end
    end
    flash[ :notice ] = 'Notice: open orders created.'
    redirect_to root_path
  end


  private

    def closed_order_params
      params.require(:open_order).permit(:user_id, :coin1, :coin2, :pr, :steprate, :num, :eachamt, :updown)
    end
 
end


