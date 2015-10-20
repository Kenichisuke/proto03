# require 'usrdaemons/settle_order'

class OrdersController < ApplicationController

  include CoinUtil

  before_action :authenticate_user!, only: [ :create, :show, :edit, :update,
     :index_btc_ltc,  :index_btc_mona, :index_btc_doge, 
     :index_ltc_mona, :index_ltc_doge, :index_mona_doge] 

  def btc_ltc
    common_new('BTC', 'LTC')
  end

  def btc_mona
    common_new('BTC', 'MONA')
  end

  def btc_doge
    common_new('BTC', 'DOGE')
  end

  def ltc_mona
    common_new('LTC', 'MONA')
  end

  def ltc_doge
    common_new('LTC', 'DOGE')
  end

  def mona_doge
    common_new('MONA', 'DOGE')
  end

  def create
    @order = Order.new(order_params)
    @coin_a = @order.coin_a
    @coin_b = @order.coin_b

    if params[:sell] then # sell
      @buysellinfo = "sell"
      @order.buysell = true
    elsif params[:buy] then # buy
      @buysellinfo = "buy"
      @order.buysell = false
    else
      raise StandardError, 'neither buy nor sell !'
      # TODO あとでちゃんと書く
    end

    # エラーでrenderするための用意！
    common_new_set
    action_s = @coin_a.ticker.downcase + '_' + @coin_b.ticker.downcase
    @lang_link = false
    @japanese_path = url_for(locale: 'ja', controller: :orders, action: action_s, only_path: true)
    @english_path = url_for(locale: 'en', controller: :orders, action: action_s, only_path: true)


    # check if inputted amounts are numeric or not on the order
    flag_err = 0
    unless @order.rate.is_a?(Numeric) then
      @order.errors.add(:rate, I18n.t('errors.messages.not_a_number'))
      flag_err += 1
    end
    unless @order.amt_a.is_a?(Numeric) then 
      @order.errors.add(:amt_a, I18n.t('errors.messages.not_a_number'))
      flag_err += 1
    end
    if flag_err >0
      @lang_link = true
      render 'common_new'
      return
    end

    # check if inputted amounts are positive or not
    flag_err = 0
    if @order.rate <= 0 then
      @order.errors.add(:rate, I18n.t('errors.messages.order.zero_or_negative'))
      flag_err += 1
  	end
    if @order.amt_a <= 0 then 
      @order.errors.add(:amt_a, I18n.t('errors.messages.order.zero_or_negative'))
      flag_err += 1
    end

    # TODO  自分のopen order と約定が発生しないかチェック。


    if flag_err >0
      @lang_link = true
      render 'common_new'
      return
    end

    @order.amt_b     = @order.rate * @order.amt_a    
    @order.amt_a_org = @order.amt_a
    @order.amt_b_org = @order.amt_b
    @order.user_id = current_user.id
    @order.flag = "open_new"  # defined in order.rb

    # check whether buy or sell
    if @order.buysell then # sell
      @order.buysell = true
      @acnt = Acnt.find_by(user_id: current_user.id, cointype_id: @order.coin_a_id)
      if @order.amt_a > (@acnt.balance - @acnt.locked_bal) then
        @order.errors.add(:amt_a, I18n.t('errors.messages.order.free_bal_not_enough'))
        @lang_link = true
        render 'common_new'
        return
      end
      @acnt.lock_amt(@order.amt_a)
    else # buy
      @order.buysell = false
      @acnt = Acnt.find_by(user_id: current_user.id, cointype_id: @order.coin_b_id)
      if @order.amt_b > (@acnt.balance - @acnt.locked_bal) then
        @order.errors.add(:amt_b, I18n.t('errors.messages.order.free_bal_not_enough'))      
        @lang_link = true
        render 'common_new'
        return
      end
      @acnt.lock_amt(@order.amt_b)
    end

    begin
      save_new_order!
    rescue => e
      @order.errors.add(:base, I18n.t('errors.messages.order.try_later'))      
      @lang_link = true
      render 'common_new'
      return
    end

    flash[ :notice ] = I18n.t('order.order_submit')
    redirect_to @order    
  end

  def show
    @order = Order.find(params[:id])
    @coin_a = @order.coin_a
    @coin_b = @order.coin_b
    coina_s = @coin_a.ticker.downcase
    coinb_s = @coin_b.ticker.downcase
    action_s = coina_s + '_' + coinb_s
    @path = url_for(locale: I18n.locale, controller: :orders, action: action_s, only_path: true)
    @headinfo = "trade"
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

  def edit
    begin
      @order = Order.find(params[:id])
    rescue => e  # データが存在しない時の処理
      logger.warn('Order controller edit: cannot get order data from DB')
      logger.warn('class:' + e.class.to_s)
      logger.warn('msg' + e.message)
      flash[ :alert ] = I18n.t('order.only_owner_can_see')
      redirect_to root_path and return
    end

   # 他人のオーダーを変更できないようにする。チェック！！
    if @order.user.id != current_user.id then
      flash[ :alert ] = I18n.t('order.only_owner_can_see')
      redirect_to root_path
    end

    @trades = @order.trade.non_diff.page(params[:page])
  end


  def update  # cancellation
    begin
      @order = Order.find(params[:id])
    rescue => e  # データが存在しない時の処理
      logger.warn('Order controller Update: cannot get order data from DB')
      logger.warn('class:' + e.class.to_s)
      logger.warn('msg' + e.message)
      flash[ :alert ] = I18n.t('order.only_owner_can_see')
      redirect_to root_path and return
    end

   # 他人のオーダーを変更できないようにする。チェック！！
    if @order.user.id != current_user.id then
      flash[ :alert ] = I18n.t('order.only_owner_can_cancel')
      redirect_to root_path and return
    end

    # オーダーがOpenで無い場合
    if (( @order.flag != "open_new") && ( @order.flag != "open_per")) then 
      flash[ :alert ] = I18n.t('order.not_open')
      redirect_to root_path and return
    end

    update_cancel
#####
    # if @order.buysell
    #   @acnt = Acnt.find_by(user_id: @order.user.id, cointype_id: @order.coin_a)
    #   amt = @order.amt_a
    # else
    #   @acnt = Acnt.find_by(user_id: @order.user.id, cointype_id: @order.coin_b)
    #   amt = @order.amt_b
    # end
    # @acnt.unlock_amt(amt)
    # @trade = Trade.new(order_id: @order.id, amt_a: @order.amt_a, amt_b: @order.amt_b, fee: 0, flag: Trade.flags[:tr_cncl] )
    # flag = ( @order.flag == "open_new") ? Order.flags[:noex_cncl] : Order.flags[:exec_cncl]

    # @order.amt_a = 0
    # @order.amt_b = 0
    # @order.flag = flag
#####

    begin
      save_order_cancellation!
    rescue => e
      flash[ :alert ] = I18n.t('errors.messages.order.try_later')
      # @order.errors.add(:base, I18n.t('errors.messages.order.try_later'))
      redirect_back_or(root_path)
      return
    end

    flash[ :notice ] = I18n.t('order.canceled')
    redirect_back_or(root_path)
  end

  def update_cancel( myorder = nil )
    @order ||= myorder

    if @order.buysell then
      @acnt = Acnt.find_by(user_id: @order.user.id, cointype_id: @order.coin_a)
      amt = @order.amt_a
    else
      @acnt = Acnt.find_by(user_id: @order.user.id, cointype_id: @order.coin_b)
      amt = @order.amt_b
    end
    @acnt.unlock_amt(amt)
    @trade = Trade.new(order_id: @order.id, amt_a: @order.amt_a, amt_b: @order.amt_b, fee: 0, flag: Trade.flags[:tr_cncl] )
    flag = ( @order.flag == "open_new") ? Order.flags[:noex_cncl] : Order.flags[:exec_cncl]

    @order.amt_a = 0
    @order.amt_b = 0
    @order.flag = flag
  end

  def save_order_cancellation!
    ActiveRecord::Base.transaction do
      @order.save!
      @acnt.save!
      @trade.save!
    end
    logger.info('Cancel order: order, anct and trade saved. Order_id:' + @order.id.to_s + ' acnt_id:' + @acnt.id.to_s + ' trade_id:' + @trade.id.to_s)
  rescue => e
    logger.error('Cancel order: order, anct and trade NOT saved.')
    logger.error('class:' + e.class.to_s)
    logger.error('msg' + e.message)
    raise
  end

  private
    def common_new(coin1, coin2)
      @coin_a, @coin_b = coin_order(coin1, coin2)
      @order = Order.new(coin_a_id: @coin_a.id, coin_b_id: @coin_b.id)
      @buysellinfo = "buy"
      common_new_set
      store_location
      render 'common_new'      
    end

    def common_new_set
      @headinfo = "trade"
      @tabinfo = @coin_a.ticker + '-' + @coin_b.ticker
      @candleplot = "\'" + @tabinfo + '_candle' + "\'"
      @histplot = "\'" + @tabinfo + "_hist_" + I18n.locale.to_s + "\'"
      @step_min = CoinRelation.find_by(coin_a_id: @coin_a.id, coin_b_id: @coin_b.id).step_min
      if current_user then
        a = Acnt.find_by(user_id: current_user.id, cointype_id: @coin_a.id)
        b = Acnt.find_by(user_id: current_user.id, cointype_id: @coin_b.id)
        @coin_a_bal = a.balance
        @coin_a_freebal = a.balance - a.locked_bal
        @coin_b_bal = b.balance
        @coin_b_freebal = b.balance - b.locked_bal
        @op_orders = current_user.order.openor.coins(@coin_a.id, @coin_b.id)
                    .order('created_at DESC', 'rate DESC').page(params[:page]).per(5)
      end
      @path12 = orders_btc_ltc_path
      @path13 = orders_btc_mona_path
      @path14 = orders_btc_doge_path
      @path23 = orders_ltc_mona_path
      @path24 = orders_ltc_doge_path
      @path34 = orders_mona_doge_path
    end

    def common_index(coin1, coin2)
      @coin_a, @coin_b = coin_order(coin1, coin2)
      @orders = current_user.order.coins(@coin_a.id, @coin_b.id).order('created_at DESC', 'rate DESC').page(params[:page]) 
      @headinfo = "order_list"
      @tabinfo = @coin_a.ticker + '-' + @coin_b.ticker
      @path12 = orders_index_btc_ltc_path
      @path13 = orders_index_btc_mona_path
      @path14 = orders_index_btc_doge_path
      @path23 = orders_index_ltc_mona_path
      @path24 = orders_index_ltc_doge_path
      @path34 = orders_index_mona_doge_path
      store_location
      render 'common_index'
    end

    def save_new_order!
      ActiveRecord::Base.transaction do
        @order.save!
        @acnt.save!
      end
      logger.info('New order: order and anct saved. Order_id:' + @order.id.to_s + ' acnt_id:' + @acnt.id.to_s)
    rescue => e
      logger.error('New order: order and anct NOT saved.')
      logger.error('class:' + e.class.to_s)
      logger.error('msg' + e.message)
      raise
    end


    def order_params
      params.require(:order).permit(:coin_a_id, :coin_b_id, :rate, :amt_a)
    end

end

