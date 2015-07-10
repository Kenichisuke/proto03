# require 'usrdaemons/settle_order'

class OrdersController < ApplicationController

  include CoinUtil

  before_action :authenticate_user!, only: [:create, :show, :update,
      :index_btc_mona, :index_btc_ltc, :index_ltc_mona,
      :settle] 
  before_action :admin_user, only: :settle

  def btc_ltc
    common_new('BTC', 'LTC', true)
  end

  def btc_mona
    common_new('BTC', 'MONA', true)
  end

  def btc_doge
    common_new('BTC', 'DOGE', true)
  end

  def ltc_mona
    common_new('LTC', 'MONA', true)
  end

  def ltc_doge
    common_new('LTC', 'DOGE', true)
  end

  def mona_doge
    common_new('MONA', 'DOGE', true)
  end

  def create
    @order = Order.new(order_params)

    # check inputted amounts on the order
    # todo 数字であるかチェックするのロジックが必要

    flag_err = 0
    if @order.rate <= 0 then
      @order.errors.add(:rate, I18n.t('errors.messages.order.zero_or_negative'))
      # flash[ :alert ] = "Rate should be positive. Please input positive amounts"
      flag_err += 1
  	end
    if @order.amt_a <= 0 then 
      @order.errors.add(:amt_a, I18n.t('errors.messages.order.zero_or_negative'))
      # flash[ :alert ] = "Amount should be positive. Please input positive amounts"
      flag_err += 1
    end

    # TODO
    # 自分のopen order と約定が発生しないかチェック。

    # binding.pry

    if flag_err >0
      common_new(@order.coin_a.ticker, @order.coin_b.ticker, false)
      # redirect_back_or(root_path)
      return
    end
    @order.amt_b     = @order.rate * @order.amt_a    
    @order.amt_a_org = @order.amt_a
    @order.amt_b_org = @order.amt_b
    @order.user_id = current_user.id
    @order.flag = Order.flags[:open_new]

    # check whether buy or sell
    # binding.pry
    if params[:buy] then # buy
      @order.buysell = false
      acnt = Acnt.find_by(user_id: current_user.id, cointype_id: @order.coin_b_id)
      if @order.amt_b > (acnt.balance - acnt.locked_bal) then
        @order.errors.add(:amt_b, I18n.t('errors.messages.order.free_bal_not_enough'))      
        common_new(@order.coin_a.ticker, @order.coin_b.ticker, false)
        return
      end
      acnt.lock_amt(@order.amt_b)
    elsif params[:sell] then
      @order.buysell = true
      acnt = Acnt.find_by(user_id: current_user.id, cointype_id: @order.coin_a_id)
      if @order.amt_a > (acnt.balance - acnt.locked_bal) then
        @order.errors.add(:amt_a, I18n.t('errors.messages.order.free_bal_not_enough'))      
        common_new(@order.coin_a.ticker, @order.coin_b.ticker, false)
        return
      end
      acnt.lock_amt(@order.amt_a)
    else
      raise StandardError, 'neither buy nor sell !'
      # to do あとでちゃんと書く
    end

    begin
      ActiveRecord::Base.transaction do
  	    @order.save!
        acnt.save!
      end
    rescue => e
      @order.errors.add(:base, I18n.t('errors.messages.order.try_later'))      
      common_new(@order.coin_a.ticker, @order.coin_b.ticker, false)
      # flash[ :alert ] = "Order was canceled. Please input the order again"
      # redirect_back_or(root_path) and return
    end

    flash[ :notice ] = I18n.t('order.order_submit')
    common_new(@order.coin_a.ticker, @order.coin_b.ticker, true)
    # redirect_back_or(root_path)
  end

  def index_btc_ltc
    common_index('BTC', 'LTC')
  end

  def index_btc_mona
    common_index('BTC', 'MONA')
  end

  def index_btc_doge
    common_index('BTC', 'DOGE')
  end

  def index_ltc_mona
    common_index('LTC', 'MONA')
  end

  def index_ltc_doge
    common_index('LTC', 'DOGE')
  end

  def index_mona_doge
    common_index('MONA', 'DOGE')
  end

  def show
    @order = Order.find(params[:id])
    if @order.user.id != current_user.id then
      flash[ :alert ] = I18n.t('order.only_owner_can_see')
      redirect_to root_path
    end

    @coin_a = @order.coin_a
    @coin_b = @order.coin_b
    @trades = @order.trade.non_diff.page(params[:page])
    store_location
  end

  def update # 他人のオーダーを変更できないようにする。チェック！！
    order = Order.find(params[:id])
    if order.user.id != current_user.id then
      flash[ :alert ] = I18n.t('order.only_owner_can_cancel')
      redirect_to root_path
    end

    if order.buysell
      acnt = Acnt.find_by(user_id: order.user.id, cointype_id: order.coin_a)
      amt = order.amt_a
    else
      acnt = Acnt.find_by(user_id: order.user.id, cointype_id: order.coin_b)
      amt = order.amt_b
    end
    acnt.unlock_amt(amt)

    trade = Trade.new(order_id: order.id, amt_a: order.amt_a, amt_b: order.amt_b, fee: 0, flag: Trade.flags[:tr_cncl] )

    if ((order.flag != "open_new") && (order.flag != "open_per")) then 
      flash[ :alert ] = I18n.t('order.not_open')
      redirect_to root_path
    end
    flag = (order.flag == "open_new") ? Order.flags[:noex_cncl] : Order.flags[:exec_cncl]
    order.amt_a = 0
    order.amt_b = 0
    order.flag = flag
    ActiveRecord::Base.transaction do
      order.save!
      acnt.save!
      trade.save!
    end
    flash[ :notice ] = I18n.t('order.canceled')
    redirect_back_or(root_path)
  end



  private
    def common_new(coin1, coin2, new_flag)
      @coin_a, @coin_b = coin_order(coin1, coin2)
        # defined in lib/usrmodules/coin_util
      if new_flag then
        @order = Order.new(coin_a_id: @coin_a.id, coin_b_id: @coin_b.id)
      end
      @headinfo = "trade"
      @tabinfo = @coin_a.ticker + '-' + @coin_b.ticker
      @candleplot = "\'" + @tabinfo + '_candle' + "\'"
      @histplot = "\'" + @tabinfo + "_hist_" + I18n.locale.to_s + "\'"

      if current_user then
        a = Acnt.find_by(user_id: current_user.id, cointype_id: @coin_a.id)
        b = Acnt.find_by(user_id: current_user.id, cointype_id: @coin_b.id)
        @coin_a_bal = a.balance
        @coin_a_freebal = a.balance - a.locked_bal
        @coin_b_bal = b.balance
        @coin_b_freebal = b.balance - b.locked_bal
        @op_orders = current_user.order.openor.coins(@coin_a.id, @coin_b.id)
                    .order('created_at DESC').page(params[:page]).per(5)
      end
      @path12 = orders_btc_ltc_path
      @path13 = orders_btc_mona_path
      @path14 = orders_btc_doge_path
      @path23 = orders_ltc_mona_path
      @path24 = orders_ltc_doge_path
      @path34 = orders_mona_doge_path
      store_location
      render 'new_form'
    end

    def common_index(coin1, coin2)
      @coin_a, @coin_b = coin_order(coin1, coin2)
      @orders = current_user.order.coins(@coin_a.id, @coin_b.id).order('created_at DESC').page(params[:page]) 
      @headinfo = "order_list"
      @tabinfo = @coin_a.ticker + '-' + @coin_b.ticker
      @path12 = orders_btc_ltc_path
      @path13 = orders_btc_mona_path
      @path14 = orders_btc_doge_path
      @path23 = orders_ltc_mona_path
      @path24 = orders_ltc_doge_path
      @path34 = orders_mona_doge_path
      store_location
      render 'index_form'
    end

    def order_params
      params.require(:order).permit(:coin_a_id, :coin_b_id, :rate, :amt_a)
    end

end

