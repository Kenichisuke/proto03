require 'rqrcode'

class CoiniosController < ApplicationController

  before_action :authenticate_user!
  before_action :admin_user, only: [ :index_btc, :index_ltc, :index_mona, :index_doge, :update ]

  def coinio_btc
    common_new('BTC')
  end

  def coinio_ltc
    common_new('LTC')
  end

  def coinio_mona
    common_new('MONA')
  end

  def coinio_doge
    common_new('DOGE')
  end

  def create
  	@coinio = Coinio.new(coinio_params)
    @coin = @coinio.cointype
    @acnt = Acnt.find_by(user_id: current_user.id, cointype_id: @coin.id)

    # エラーでrenderするための用意！
    common_new_set
    action_s = 'coinio_' + @coin.ticker.downcase
    @lang_link = false
    @japanese_path = url_for(locale: 'ja', controller: :coinios, action: action_s, only_path: true)
    @english_path = url_for(locale: 'en', controller: :coinios, action: action_s, only_path: true)

    # 数字であるかチェックするのロジック
    unless @coinio.amt.is_a?(Numeric) then
      @coinio.errors.add(:amt, I18n.t('errors.messages.not_a_number'))
      @lang_link = true
      render 'common_new' and return 
    end

    flag_err = 0

    # inputted amount check
     if @coinio.amt <= 0 then
      @coinio.errors.add(:amt, I18n.t('errors.messages.greater_than', count: 0))
      flag_err += 1
    end

    # acount amount check
    acnt = @coinio.acnt
  	if (@coinio.amt + @coinio.cointype.fee_out) > (acnt.balance - acnt.locked_bal) then
      @coinio.errors.add(:amt, I18n.t('errors.messages.amount_bigger_than_balance'))
      flag_err += 1
    end

    if flag_err >0 then
      @lang_link = true
      render 'common_new' and return 
    end


    begin
      #coin address check
      # when wallet dead, exception occurs.
      addr_valid = Coinrpc.validateaddr(@coinio.cointype.ticker, @coinio.addr)
    rescue => e

    ## if you want to add reserve function, please comment in below 
      ## @coinio.flag = :out_reserve
      ## @coinio.txid = ""
      ## if @coinio.save then
      ##   flash[ :notice ] = "Your Coin transfer out request was submitted."
      ##   common_new(@coinio.cointype.ticker) and return
      ## else

        @coinio.errors.add(:base, I18n.t('errors.messages.try_later'))
        logger.error('Coinio send cannot access wallet ' + @coinio.cointype.ticker )
        logger.error( e.message )
        @lang_link = true
        render 'common_new' and return
      ## end
    end

    if !addr_valid["isvalid"] then
      @coinio.errors.add(:addr, I18n.t('errors.messages.address_invalid'))
      # ログに残すこと！
      @lang_link = true
      render 'common_new' and return
    end

    # if addr_valid is true
    begin # 送金する。金額がなければ失敗する。
      @coinio.txid = Coinrpc.sendaddr(@coinio.cointype.ticker, @coinio.addr, @coinio.amt)
    rescue => e
      # 予約を入れるロジック
      @coinio.txid = ""
      @coinio.tx_category = :tx_send
      @coinio.fee = acnt.cointype.fee_out
      @coinio.flag = :out_reserve
      @coinio.save
      logger.error('Coinio create reservation: coinio saved as reservation: ' + @coinio.cointype.ticker)
      logger.error( e.message )
      flash[ :notice ] = I18n.t('coinio.coinout_reserve')
      redirect_to @coinio
      return
    end

    acnt.balance -= (@coinio.amt + acnt.cointype.fee_out)
    @coinio.tx_category = :tx_send
    @coinio.fee = acnt.cointype.fee_out
    @coinio.flag = :out_sent

    begin #出金結果の記録をセーブする。
      save_coinio!
    rescue => e
      #この例外は普通おこらない。
      flash[ :alert ] = I18n.t('errors.messages.order.try_later')
      # @order.errors.add(:base, I18n.t('errors.messages.order.try_later'))
      logger.error('Cancel order: order, anct and trade NOT saved.')
      logger.error('class:' + e.class.to_s)
      logger.error('msg' + e.message)
      redirect_back_or(root_path)
      return
    end  

    flash[ :notice ] = I18n.t('coinio.coinout_done')  
    redirect_to @coinio

    # else
    #   coinio.flag = :out_abnormal
    #   @coinio.errors.add(:base, I18n.t('errors.messages.try_later'))
    #   # flash[ :alert ] = "Your Coin transfer out was not done. Please contact administratior."
    #   @lang_link = true
    #   render 'common_new' and return
    # end
  end

  def show
    begin
      @coinio = Coinio.find(params[:id])
    rescue => e  # データが存在しない時の処理
      logger.warn('Coinio controller show: cannot get order data from DB')
      logger.warn('class:' + e.class.to_s)
      logger.warn('msg' + e.message)
      flash[ :alert ] = I18n.t('order.only_owner_can_see')
      redirect_to root_path and return
    end

    # 他人のオーダーを変更できないようにする。チェック！！ 
    if @coinio.acnt.user.id != current_user.id then
      flash[ :alert ] = I18n.t('order.only_owner_can_see')
      redirect_to root_path
    end

    @coin =  @coinio.cointype
    @headinfo = "transferIO"
    action_s = 'coinio_' + @coin.ticker.downcase
    @path = url_for(locale: I18n.locale, controller: :coinios, action: action_s, only_path: true)
  end


  def index_btc
    common_new('BTC')
  end

  def index_ltc
    common_new('LTC')
  end

  def index_mona
    common_new('MONA')
  end

  def index_doge
    common_new('DOGE')
  end

  def update(coin_t)
  end

  private
    def common_new(coin_t)
	    @coin = Cointype.find_by(ticker: coin_t)
	    @acnt = Acnt.find_by(user_id: current_user.id, cointype_id: @coin.id)
      @coinio = Coinio.new(cointype_id: @coin.id, acnt_id: @acnt.id)

      common_new_set
      store_location
      render 'common_new' 
    end

    def common_new_set
      @coinios = @acnt.coinio.order('created_at DESC').page(params[:page])
      @addr_s = @coin.name.downcase + ':' + @acnt.addr_in
      @qr = RQRCode::QRCode.new( @addr_s, :size => 5, :level => :q )
      @headinfo = "transferIO"
      @tabinfo = @coin.ticker
      @path1 = coinios_coinio_btc_path
      @path2 = coinios_coinio_ltc_path
      @path3 = coinios_coinio_mona_path
      @path4 = coinios_coinio_doge_path
    end

    def save_coinio!
      ActiveRecord::Base.transaction do
        @coinio.save!
        @acnt.save!
      end
      logger.info('Coinio create: coinio and anct saved. Coinio_id:' + @coinio.id.to_s + ' acnt_id:' + @acnt.id.to_s + ' trade_id:' + @trade.id.to_s)
    rescue => e
      logger.error('Coinio create: coinio and anct NOT saved.')
      logger.error('class:' + e.class.to_s)
      logger.error('msg' + e.message)
      raise
    end

    def index_new(coin_t)
      @coin = Cointype.find_by(ticker: coin_t)
      @coinios = Coinio.where('cointype_id: @coin.id' ,'flag: :out_reserve').order('created_at DESC', 'rate DESC').page(params[:page]).per(20)
    end



    def coinio_params
      params.require(:coinio).permit(:cointype_id, :amt, :addr, :acnt_id)
      # Viewの中でflagを一時的にTotalで使っている。取り込まないこと！
    end
end

