class ClosedOrdersController < ApplicationController

  include CoinUtil

  before_action :authenticate_user!
  before_action :admin_user

  def new
    tmnow = Time.now
    tmstr = tmnow - (2 * 24 * 60 * 60) #2日前
    @closed_order = ClosedOrder.new(user_id: 3, coin1: 1, coin2: 2, pr: 10, tmstr: tmstr, tmend: tmnow)
    @cointypes = Cointype.all
  end
  
  def create
    @closed_order = ClosedOrder.new( closed_order_params.symbolize_keys )
    @cointypes = Cointype.all

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

    make_close_order_coins(@closed_order.user_id, @closed_order.coin1, @closed_order.coin2, 
      @closed_order.pr, @closed_order.tmstr, @closed_order.tmend, @closed_order.stepmin)
    redirect_to root_path
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

    def closed_order_params
      params.require(:closed_order).permit(:user_id, :coin1, :coin2, :pr, :tmstr, :tmend, :stepmin)
    end

  end


