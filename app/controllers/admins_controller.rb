class AdminsController < ApplicationController

  include CoinUtil

  before_action :authenticate_user!
  before_action :admin_user

  # for debuging
  @@coin1 = Cointype.find_by(ticker: 'BTC').id
  @@coin2 = Cointype.find_by(ticker: 'MONA').id
  # debuging end

  def orderbook_exec  # orderを付き合わせて約定し、Tradeを作る。
    Orderbook.execute(@@coin1, @@coin2)
    flash[:notice] = "orderbok_exec done"
    redirect_back_or(root_path)
  end

  def orderbook_trade2acnt  # Tradeを元に、acntの情報を更新する。
    Orderbook.trade2acnt
    flash[:notice] = "orderbok_trade2acnt done"
    redirect_back_or(root_path)
  end

  def orderbook_plot  # open order の情報を元に気配ねの横ヒストグラムを作る。
    Orderbook.makeplot(@@coin1, @@coin2)
    flash[:notice] = "orderbok_plot done"    
    redirect_back_or(root_path)
  end

  def orderbook_total  # open order の3つのプロセスを行う。
    Orderbook.totalprocess
    flash[:notice] = "orderbok_total process"    
    redirect_back_or(root_path)
  end

  def pricehist_exec # Tradeのデータを元に、PriceHistのデータを作る。
  	Pricehistproc.execute(@@coin1, @@coin2)
    redirect_back_or(root_path)
  end

  def pricehist_plot  # PriceHistのデータを元に、ローソクチャートを作る。
  	Pricehistproc.makeplot(@@coin1, @@coin2)
    redirect_back_or(root_path)
  end

  def pricehist_total  # PriceHistのデータを元に、ローソクチャートを作る。
    Pricehistproc.totalprocess
    redirect_back_or(root_path)
  end

  def walletcheck_exec # Walletの入金をチェックする。
    Walletcheck.totalprocess
    # Walletcheck.execute(@@coin2)
    redirect_back_or(root_path)
  end
 
  def precheck_service
#    tickers = Cointype.tickers
    tickers = %w(BTC MONA LTC)
    @results = []
    tickers.each do | t |
      coin_id = coin_t2i(t)
      w_bal = checkalive(t)
      init_bal = Cointype.find(coin_id).init_amt              
      db_bal = Acnt.where(cointype: coin_id).sum(:balance)        
      db_locked_bal = Acnt.where(cointype: coin_id).sum(:locked_bal)
      db_diff_bal = Trade.where(coin_a_id: coin_id).where(flag: :tr_diffdone).sum(:amt_a)
      if w_bal then
        @results << CoinStatus.new(t, "alive", init_bal, db_bal, db_diff_bal, db_locked_bal, w_bal)
      else
        @results << CoinStatus.new(t, "dead", init_bal, db_bal, db_diff_bal, db_locked_bal, "NA")
      end
    end

    # BTC walletが動いているか
    # LTC walletが動いているか
    # MONA walletが動いているか
    # 金額があっているか？

    # mysql.server が動いているか
    # orderbook のcron が動いているか
    # pricehist のcronが動いているか
    # walletcheck のcronが動いているか
  end

  def index_order_btc_mona
    common_index_order('BTC', 'MONA')
  end

  def index_order_btc_ltc
    common_index_order('BTC', 'LTC')
  end

  def index_order_ltc_mona
    common_index_order('LTC', 'MONA')
  end


private
    def common_index_order(coin1, coin2)
      @coin_a, @coin_b = coin_order(coin1, coin2)
      @orders = Order.coins(@coin_a.id, @coin_b.id).order('created_at DESC').page(params[:page]) 
      @tabinfo = @coin_a.ticker + '-' + @coin_b.ticker
      @path1 = orders_index_btc_mona_path
      @path2 = orders_index_btc_ltc_path
      @path3 = orders_index_ltc_mona_path
      store_location
      render 'index_order_form'
    end

    def checkalive(coin_t) # return balance when alive. false when dead.
      begin
        ret = Coinrpc.getbal(coin_t)
      rescue => e
        return false
      else
        return ret
      end
    end

end

