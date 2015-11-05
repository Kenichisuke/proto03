class ClosedOrdersController < ApplicationController

  include CoinUtil

  before_action :authenticate_user!
  before_action :admin_user

  def new
    tmnow = Time.now
    tmstr = tmnow - (2 * 24 * 60 * 60) #2日前
    @admins = User.where(admin: true).order(id: :asc)
    @cointypes = Cointype.all.order(rank: :desc)
    usrid = @admins.first.id
    coin1id = @cointypes.first.id
    coin2id = @cointypes.second.id
    @closed_order = ClosedOrder.new(user_id: usrid, coin1: coin1id, coin2: coin2id, pr: 10, tmstr: tmstr, tmend: tmnow)
#    @step_min = CoinRelation.find_by(coin_a_id: coin1id, coin_b_id: coin2id).step_min
  end
  
  def create
    @closed_order = ClosedOrder.new( closed_order_params.symbolize_keys )
    @cointypes = Cointype.all
    @admins = User.where(admin: true).order(id: :asc) # in case of render 'new'

    if @closed_order.coin1 == @closed_order.coin2 then
      flash[ :alert ] = 'Error: same coins'
      render 'new' and return
    end
    if Cointype.find(@closed_order.coin1).rank <= Cointype.find(@closed_order.coin2).rank then
      flash[ :alert ] = 'Error: Order of coins is opposite'
      render 'new' and return
    end
    if @closed_order.tmstr > @closed_order.tmend then
      flash[ :alert ] = 'Error: Time order (from Start to End) is opposite'
      render 'new' and return
    end
    time_e = Trade.coins(@closed_order.coin1, @closed_order.coin2).where(flag: Trade.flags[:tr_close] ).order('updated_at DESC').first.updated_at
    if @closed_order.tmstr < time_e then
      flash[ :alert ] = 'Error: Time start is later than last recored trade'
      render 'new' and return
    end

    # to write latest traded price on database
    a = CoinRelation.find_by(coin_a_id:  @closed_order.coin1, coin_b_id:  @closed_order.coin2)
    a.rate_act = @closed_order.pr
    a.save

    make_close_order_coins(@closed_order.user_id, @closed_order.coin1, @closed_order.coin2, 
      @closed_order.pr, @closed_order.tmstr, @closed_order.tmend, @closed_order.stepmin)

    flash[ :notice ] = 'Notice: histrical trade data (candle) created.'
    redirect_to root_path
  end

  def delete_new
    tmnow = Time.now
    tmstr = tmnow - (2 * 24 * 60 * 60) #2日前
    @admins = User.where(admin: true).order(id: :asc)
    @cointypes = Cointype.all.order(rank: :desc)
    usrid = @admins.first.id
    coin1id = @cointypes.first.id
    coin2id = @cointypes.second.id
    @closed_order = ClosedOrder.new(user_id: usrid, coin1: coin1id, coin2: coin2id, tmstr: tmstr, tmend: tmnow)
  end

  def delete_check

    listup_orders_trades_price_hists
    @coin_a = Cointype.find( @closed_order.coin1 )
    @coin_b = Cointype.find( @closed_order.coin2 )
  end

  def delete_create
      listup_orders_trades_price_hists
      @closed_orders.delete_all
      @closed_trades.delete_all
      @price_hists.delete_all
      flash[ :notice ] = 'deleted'
      redirect_to root_path and return
  end


  private
  
    # 時間をさかのぼってデータを作る。
    # step : 何分おきのデータを作るのか
    def make_close_order_coins(user_id, coin1_i, coin2_i, pr, tmstr, tmend, step)
      kai = ((tmend - tmstr) / ( step * 60) + 1).floor
      vl = 1
      kai.times do | n |

        tm = tmend - (n * step * 60)
        make_order_tr(user_id, user_id, coin1_i, coin2_i, vl, pr, tm)

        range = (pr * 0.08).round(0)
        if range < 3 then
          range = 3
        end

        # pr += (rand(range * 10) - (range * 10　-　1) / 2.0) / 10.0
        pr += (rand(range * 10) - ((range * 10) - 1) / 2.0 ) / 10.0
        if pr < 1.0 then
          pr = 1.0
        end

        tm = tmend - (n * step * 60)
      end
    end

    # create closed order with trades
    def make_order_tr(user1_id, user2_id, coin1_i, coin2_i, amt_a, rate, tm)
      ord = Order.create!(user_id: user1_id,
                  coin_a_id: coin1_i,
                  coin_b_id: coin2_i,
                  buysell: true,   #btc売り円買い
                  amt_a: 0,
                  amt_b: 0,
                  amt_a_org: amt_a,
                  amt_b_org: amt_a * rate,
                  rate: rate,
                  flag: :exec_exec,
                  created_at: tm,
                  updated_at: tm)

      Trade.create!(order_id: ord.id,
                  coin_a_id: coin1_i,
                  coin_b_id: coin2_i,
                  amt_a: amt_a,
                  amt_b: amt_a * rate,
                  fee: 0,
                  flag: :tr_close,
                  created_at: tm,
                  updated_at: tm)

      ord = Order.create!(user_id: user2_id,
                  coin_a_id: coin1_i,
                  coin_b_id: coin2_i,
                  buysell: false,   #btc売り円買い
                  amt_a: 0,
                  amt_b: 0,
                  amt_a_org: amt_a,
                  amt_b_org: amt_a * rate,
                  rate: rate,
                  flag: :exec_exec,
                  created_at: tm,
                  updated_at: tm)
      Trade.create!(order_id: ord.id,
                  coin_a_id: coin1_i,
                  coin_b_id: coin2_i,       
                  amt_a: amt_a, 
                  amt_b: amt_a * rate, 
                  fee: 0,
                  flag: :tr_close,
                  created_at: tm,
                  updated_at: tm)
    end

    def listup_orders_trades_price_hists
      @closed_order = ClosedOrder.new( closed_order_params2.symbolize_keys )

      if @closed_order.coin1 == @closed_order.coin2 then
        flash[ :alert ] = 'Error: same coins'
        render 'delete_new' and return
      end
      if Cointype.find(@closed_order.coin1).rank <= Cointype.find(@closed_order.coin2).rank then
        flash[ :alert ] = 'Error: Order of coins is opposite'
        render 'delete_new' and return
      end
      if @closed_order.tmstr > @closed_order.tmend then
        flash[ :alert ] = 'Error: Time order (from Start to End) is opposite'
        render 'delete_new' and return
      end

      @closed_orders = Order.where(user_id: @closed_order.user_id).coins( @closed_order.coin1, @closed_order.coin2 )
        .where("? <= updated_at AND updated_at <= ?", @closed_order.tmstr, @closed_order.tmend )
        .where(flag: Order.flags[ :exec_exec ] ).order('updated_at ASC')

      @closed_trades = Trade.coins( @closed_order.coin1, @closed_order.coin2 )
        .where("? <= updated_at AND updated_at <= ?", @closed_order.tmstr, @closed_order.tmend )
        .where(flag: Trade.flags[ :tr_close ] ).order('updated_at ASC')

      @price_hists = PriceHist.coins( @closed_order.coin1, @closed_order.coin2 )
        .where("? <= dattim AND dattim <= ?", @closed_order.tmstr, @closed_order.tmend )
        .order('dattim ASC')

    end

    def closed_order_params
      params.require(:closed_order).permit(:user_id, :coin1, :coin2, :pr, :tmstr, :tmend, :stepmin)
    end

    def closed_order_params2
      params.require(:closed_order).permit(:user_id, :coin1, :coin2, :tmstr, :tmend)
    end

  end


