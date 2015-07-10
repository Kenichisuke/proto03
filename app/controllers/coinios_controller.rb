class CoiniosController < ApplicationController

  before_action :authenticate_user!
  before_action :admin_user, only: [ :update, :checkalive ]

  def coinio_btc
    common_new('BTC', true)
  end

  def coinio_ltc
    common_new('LTC', true)
  end

  def coinio_mona
    common_new('MONA', true)
  end

  def coinio_doge
    common_new('DOGE', true)
  end

  def create
  	@coinio = Coinio.new(coinio_params)

  	flag_err = 0
    # 数字であるかチェックするのロジック

    # inputted amount check
    #  if coinio.amt <= 0 then
    #    flash[ :alert ] = "Amount should be positive. Please input positive amounts"
    #    flag_err += 1
    # end

    # acount amount check
    acnt = @coinio.acnt
  	if (@coinio.amt + @coinio.cointype.fee_out) > (acnt.balance - acnt.locked_bal) then
      @coinio.errors.add(:amt, I18n.t('errors.messages.amount_bigger_than_balance'))
      flag_err += 1
    end

    if flag_err >0
      common_new(@coinio.cointype.ticker, false)
      return
    end

    begin
      #coin address check
      # when wallet dead, exception occurs.
      addr_valid = Coinrpc.validateaddr(@coinio.cointype.ticker, @coinio.addr)
    rescue => e

    ## if you want to add reseve function, please comment in below 
      ## @coinio.flag = :out_reserve
      ## @coinio.txid = ""
      ## if @coinio.save then
      ##   flash[ :notice ] = "Your Coin transfer out request was submitted."
      ##   common_new(@coinio.cointype.ticker) and return
      ## else

        @coinio.errors.add(:base, I18n.t('errors.messages.try_later'))
        common_new(@coinio.cointype.ticker, false) and return
        # ログに残すこと！

      ## end
    end  

    if !addr_valid["isvalid"] then
      @coinio.errors.add(:addr, I18n.t('errors.messages.address_invalid'))
      # flash.now[ :alert ] = "Your requested address is invalid."
      # ログに残すこと！
      common_new(@coinio.cointype.ticker, false)
      return
    end

    # if addr_valid is true
    acnt.balance -= (@coinio.amt + acnt.cointype.fee_out) 
    if acnt.save then
      @coinio.txid = Coinrpc.sendaddr(@coinio.cointype.ticker, @coinio.addr, @coinio.amt)
      @coinio.txtype = :tx_send
      @coinio.fee = acnt.cointype.fee_out
      @coinio.flag = :out_sent      
      flash[ :notice ] = I18n.t('coinio.coinout_done')
    else
      coinio.flag = :out_abnormal
      @coinio.errors.add(:base, I18n.t('errors.messages.try_later'))
      # flash[ :alert ] = "Your Coin transfer out was not done. Please contact administratior."
    end
    @coinio.save
    common_new(@coinio.cointype.ticker, true)
  end

  private
    def common_new(coin_t, new_flag)   
      # 同じ画面から再度呼び出しの場合、flagに１を入れる。
      # これにより、@coinio を引き継ぐ。
      # @coinioには入力時のエラーなどの情報が入っている。
	    @coin = Cointype.find_by(ticker: coin_t)
	    @acnt = Acnt.find_by(user_id: current_user.id, cointype_id: @coin.id)
      if new_flag then
        @coinio = Coinio.new(cointype_id: @coin.id, acnt_id: @acnt.id)
      end
      @coinios = @acnt.coinio.order('created_at DESC').page(params[:page])
      @headinfo = "transferIO"
      @tabinfo = @coin.ticker

      @path1 = coinios_coinio_btc_path
      @path2 = coinios_coinio_ltc_path
      @path3 = coinios_coinio_mona_path
      @path4 = coinios_coinio_doge_path
	    render 'new_form' and return
    end

    def coinio_params
      params.require(:coinio).permit(:cointype_id, :amt, :addr, :acnt_id)
      # Viewの中でflagを一時的にTotalで使っている。取り込まないこと！
    end
end

