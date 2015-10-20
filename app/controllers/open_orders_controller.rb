class OpenOrdersController < ApplicationController

  include CoinUtil

  before_action :authenticate_user!
  before_action :admin_user

  def new
    # @admins = User.where(admin: true).order(id: :asc)
    # @acnts = []
    # coinlist_i = coin_list_i
    # @admins.each do | i |
    #   coinlist_i.each do | coinid |
    #     @acnts << Acnt.find_by(user_id: i.id, cointype_id: coinid)
    #   end
    # end
    # @cointypes = Cointype.all.order(rank: :desc)

    new_set # preparation for render 'new'. Defined in private

    usrid = @admins.first.id
    coin1id = @cointypes.first.id
    coin2id = @cointypes.second.id
    @open_order = OpenOrder.new(user_id: usrid, coin1: coin1id, coin2: coin2id)
  end
  

  def create

    # @admins = User.where(admin: true).order(id: :asc) # in case of render 'new'
    # @acnts = []
    # coinlist_i = coin_list_i
    # @admins.each do | i |
    #   coinlist_i.each do | coinid |
    #     @acnts << Acnt.find_by(user_id: i.id, cointype_id: coinid)
    #   end
    # end
    # @cointypes = Cointype.all

    new_set # preparation for render 'new'. Defined in private

    @open_order = OpenOrder.new( open_order_params.symbolize_keys )

    # エラー処理
    # 同じコインだとエラー
    if @open_order.coin1 == @open_order.coin2 then
      flash[ :alert ] = 'Error: same coins'
      render 'new' and return
    end

    # コインの順番が違うとエラー
    if Cointype.find(@open_order.coin1).rank <= Cointype.find(@open_order.coin2).rank then
      flash[ :alert ] = 'Error: Order of coins is opposite'
      render 'new' and return
    end

    # step_min が守られているか
    stepmin = CoinRelation.find_by(coin_a_id: @open_order.coin1, coin_b_id: @open_order.coin2).step_min
    if @open_order.pr % stepmin != 0 then
      flash[ :alert ] = 'Error: pr does not match step_min. It is ' + stepmin.to_s 
      render 'new' and return
    end 
    if @open_order.steprate % stepmin != 0 then
      flash[ :alert ] = 'Error: steprate does not match step_min. It is ' + stepmin.to_s 
      render 'new' and return
    end 

    # 金額がマイナスだとエラー
    if @open_order.eachamt <= 0 then
      flash[ :alert ] = 'Error: amount is negative or zero' 
      render 'new' and return
    end

    # up/down が正しく設定されているか
    if @open_order.updown != 0 and @open_order.updown != 1 and @open_order.updown != 2 then
      flash[ :alert ] = 'Error: Sell/Buy flag is not proper (0:Sell/Buy, 1:Sell, 2:Buy)' 
      render 'new' and return
    end

    # オーダを出すのに、コインを必要額以上持っていなければエラー（売りの場合）
    if @open_order.updown == 0 or @open_order.updown == 1 then
      acnt = Acnt.find_by(user_id: @open_order.user_id, cointype_id: @open_order.coin1)
      sum = @open_order.num * @open_order.eachamt
      if sum >  (acnt.balance - acnt.locked_bal) then 
        flash[ :alert ] = 'Error: account amount is not enough. Coin: ' +  coin_i2t(@open_order.coin1)
        render 'new' and return
      end
    end

    # コインを十分持っていなければエラー（買いの場合）
    if @open_order.updown == 0 or @open_order.updown == 2 then
      acnt = Acnt.find_by(user_id: @open_order.user_id, cointype_id: @open_order.coin2)
      sum = @open_order.num * (@open_order.pr - (@open_order.num + 1) * @open_order.steprate / 2.0) * @open_order.eachamt
      if sum >  (acnt.balance - acnt.locked_bal) then 
        flash[ :alert ] = 'Error: account amount is not enough. Coin: ' +  coin_i2t(@open_order.coin2)
        render 'new' and return
      end
    end

    # オーダーを作る。
    # 売りのオーダーを作る。
    if @open_order.updown == 0 or @open_order.updown == 1 then
      acnt = Acnt.find_by(user_id: @open_order.user_id, cointype_id: @open_order.coin1)
      @open_order.num.times do | i |
        rate = @open_order.pr + (i + 1) * @open_order.steprate
        amt_b = rate * @open_order.eachamt 
        Order.create(user_id:  @open_order.user_id, coin_a_id: @open_order.coin1, coin_b_id: @open_order.coin2, 
          amt_a_org:  @open_order.eachamt, amt_b_org: amt_b ,amt_a: @open_order.eachamt, amt_b: amt_b,
          rate: rate, buysell: true, flag: 0 )
      end
      sum = @open_order.num * @open_order.eachamt
      acnt.lock_amt( sum )
      acnt.save
    end

    # 買いのオーダーを作る。
    if @open_order.updown == 0 or @open_order.updown == 2 then
      acnt = Acnt.find_by(user_id: @open_order.user_id, cointype_id: @open_order.coin2)
      @open_order.num.times do | i |
        rate = @open_order.pr - (i + 1) * @open_order.steprate
        amt_b = rate * @open_order.eachamt 
        Order.create(user_id:  @open_order.user_id, coin_a_id: @open_order.coin1, coin_b_id: @open_order.coin2, 
          amt_a_org:  @open_order.eachamt, amt_b_org: amt_b ,amt_a: @open_order.eachamt, amt_b: amt_b,
          rate: rate, buysell: false, flag: 0 )
      end
      sum = @open_order.num * (@open_order.pr - (@open_order.num + 1) * @open_order.steprate / 2.0) * @open_order.eachamt
      acnt.lock_amt( sum)
      acnt.save
    end

    flash[ :notice ] = 'Notice: open orders created.'
    redirect_to root_path
  end

  def delete_new
    @admins = User.where(admin: true).order(id: :asc)
    @cointypes = Cointype.all.order(rank: :desc)
    usrid = @admins.first.id
    coin1id = @cointypes.first.id
    coin2id = @cointypes.second.id
    @open_order = OpenOrder.new(user_id: usrid, coin1: coin1id, coin2: coin2id)
  end

  def delete_check
    # prep for render 'delete_new'
    @admins = User.where(admin: true).order(id: :asc)
    @cointypes = Cointype.all.order(rank: :desc)



  end

  private

    def new_set
      @admins = User.where(admin: true).order(id: :asc) # in case of render 'new'
      @acnts = []
      coinlist_i = coin_list_i
      @admins.each do | i |
        coinlist_i.each do | coinid |
          @acnts << Acnt.find_by(user_id: i.id, cointype_id: coinid)
        end
      end
      @cointypes = Cointype.all
    end

    def open_order_params
      params.require(:open_order).permit(:user_id, :coin1, :coin2, :pr, :steprate, :num, :eachamt, :updown)
    end
 
    def open_order_params2
      params.require(:open_order).permit(:user_id, :coin1, :coin2, :updown)
    end

end


