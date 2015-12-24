class OpenOrdersController < ApplicationController

  include CoinUtil
  include CoinMath

  before_action :authenticate_user!
  before_action :admin_user

  def new
    new_set    
    @open_order = OpenOrder.new(user_id: @admins.first.id)
  end
  
  def create

    new_set # preparation for render 'new'. Defined in private
    @open_order = OpenOrder.new( open_order_params.symbolize_keys )


    # step_min が守られているか
    cr = CoinRelation.find(@open_order.coin_relation_id) 
    unless cr.rate_check?(@open_order.rate) then
      flash[ :alert ] = 'Error: pr does not match step_min.' 
      render 'new' and return
    end 
    unless cr.rate_check?(@open_order.steprate) then
      flash[ :alert ] = 'Error: steprate does not match step_min.'
      render 'new' and return
    end 

    # 金額がマイナスだとエラー
    if @open_order.amt <= 0 then
      flash[ :alert ] = 'Error: amount is negative or zero' 
      render 'new' and return
    end

    # up/down が正しく設定されているか
    if @open_order.updown != 1 and @open_order.updown != 2 then
      flash[ :alert ] = 'Error: Sell/Buy flag is not proper (0:Sell/Buy, 1:Sell, 2:Buy)' 
      render 'new' and return
    end

    # オーダーの配列を作る
    omc = OrderMultiCreate.new(user: User.find( @open_order.user_id), coin_relation: cr);
    amt = significant_digits(((1.0 * @open_order.amt) / @open_order.num), 3)   # 有効桁数を３にしている。
    tim = @open_order.num
    tim.times do | i |
      rate = @open_order.rate + @open_order.steprate * (i + 1) * (@open_order.updown == 1 ? 1 : -1)
      unless omc.add_order(rate: rate, amt: amt, buysell: ( @open_order.updown == 1 ? true : false))
        flash[ :alert ] = 'Error: Account amount is probably not enough. Coin: ' + 
          ( @open_order.updown == 1 ? cr.coin_a.ticker : cr.coin_a.ticker )
        render 'new' and return
      end
    end

    # オーダーをチェック
    unless omc.check_acnt_with_order?
      flash[ :alert ] = 'Error: Account amount is probably not enough.'
      render 'new' and return
    end

    # オーダーを作る
    begin
      omc.save_new_orders!
    rescue => e
      flash[ :alert ] = 'Error: Account amount is probably not enough.'
      render 'new' and return
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
      # @cointypes = Cointype.all
      @coin_relations = CoinRelation.all
    end

    def open_order_params
      params.require(:open_order).permit(:user_id, :coin_relation_id, :rate, :steprate, :num, :amt, :updown)
    end
 
    # def open_order_params2
    #   params.require(:open_order).permit(:user_id, :coin1, :coin2, :updown)
    # end

end


