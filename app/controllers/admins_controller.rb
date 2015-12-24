class AdminsController < ApplicationController

  include CoinUtil

  before_action :authenticate_user!
  before_action :admin_user

  def orderbook_exec  # orderを付き合わせて約定し、Tradeを作る。
    coin_relations = CoinRelation.all
    coin_relations.each do | cr |
      Orderbook.execute(cr)
    end
    flash[:notice] = "orderbok_exec done"
    redirect_back_or(root_path)
  end

  def orderbook_trade2acnt  # Tradeを元に、acntの情報を更新する。
    Orderbook.trade2acnt
    flash[:notice] = "orderbok_trade2acnt done"
    redirect_back_or(root_path)
  end

  def orderbook_depth  # open order の情報を元に気配ねの横ヒストグラムを作る。
    coin_relations = CoinRelation.all
    coin_relations.each do | cr |
      Orderbook.makedepth(cr)
    end
    flash[:notice] = "orderbok_depth done"    
    redirect_back_or(root_path)
  end

  def orderbook_plot  # open order の情報を元に気配ねの横ヒストグラムを作る。
    coin_relations = CoinRelation.all
    coin_relations.each do | cr |
      Orderbook.makeplot(cr)
    end
    flash[:notice] = "orderbok_plot done"    
    redirect_back_or(root_path)
  end

  def orderbook_total  # open order の3つのプロセスを行う。
    Orderbook.totalprocess
    flash[:notice] = "orderbok_total done"
    redirect_back_or(root_path)
  end

  def pricehist_exec # Tradeのデータを元に、PriceHistのデータを作る。
    coincomb = Cointype.tickercomb
    coincomb.each do | c |
      coin_a, coin_b = coin_order(c[0], c[1])
      Pricehistproc.execute(coin_a.id, coin_b.id)
    end
    flash[:notice] = "PriceHist_Exec done"
    redirect_back_or(root_path)
  end

  def pricehist_plot  # PriceHistのデータを元に、ローソクチャートを作る。
    coincomb = Cointype.tickercomb
    coincomb.each do | c |
      coin_a, coin_b = coin_order(c[0], c[1])
      Pricehistproc.makeplot(coin_a.id, coin_b.id)
    end
    flash[:notice] = "PriceHist_Plots done"    
    redirect_back_or(root_path)
  end

  def pricehist_total  # PriceHistのデータを元に、ローソクチャートを作る。
    Pricehistproc.totalprocess
    flash[:notice] = "PriceHist Total done"    
    redirect_back_or(root_path)
  end

  def walletcheck_exec # Walletの入金をチェックする。
    Walletcheck.totalprocess
    flash[:notice] = "Walletcheck total done"
    redirect_back_or(root_path)
  end


  def precheck_service
    tickers = Cointype.tickers
    @results = []
    tickers.each do | t |
      coin_id = coin_t2i(t)

      status = Coinrpc.status(t)
      if status != "Dead" then
        w_bal = Coinrpc.getbal(t)
      else
        w_bal = "N/A"
      end

      init_bal = Cointype.find(coin_id).init_amt     
      db_bal = Acnt.where(cointype: coin_id).sum(:balance)        
      db_locked_bal = Acnt.where(cointype: coin_id).sum(:locked_bal)
      db_diff_bal = Trade.where(coin_a_id: coin_id).where(flag: :tr_diffdone).sum(:amt_a)
      @results << CoinStatus.new(t, status, init_bal, db_bal, db_diff_bal, db_locked_bal, w_bal)
    end

    store_location

    # mysql.server が動いているか
    # orderbook のcron が動いているか
    # pricehist のcronが動いているか
    # walletcheck のcronが動いているか

  end

  def test_email_new
  end

  def test_email_create
    mailcont = test_email_create_params
    begin
      Contactmailer.test_email(mailcont).deliver
    rescue => e
      flash[ :alert ] = 'email failed: ' + e.message
    else
      flash[ :notice ] = 'email sent'
    ensure
      redirect_to('/' + I18n.locale.to_s)
    end
  end

  def index_order_btc_ltc
    common_index_order('BTC', 'LTC')
  end

  def index_order_btc_mona
    common_index_order('BTC', 'MONA')
  end

  def index_order_btc_doge
    common_index_order('BTC', 'DOGE')
  end

  def index_order_ltc_mona
    common_index_order('LTC', 'MONA')
  end

  def index_order_ltc_doge
    common_index_order('LTC', 'DOGE')
  end

  def index_order_mona_doge
    common_index_order('MONA', 'DOGE')
  end

  # def new_closed_order
  #   @closed_order = ClosedOrder.new
  # end

  def book_make_control  # Tradeを元に、acntの情報を更新する。
    BookMake.control
    # Autotrade.checkweb
    flash[:notice] = "check done"
    redirect_back_or(root_path)
  end
  
  private
    def common_index_order(coin1, coin2)
      @coin_a, @coin_b = coin_order(coin1, coin2)
      @orders = Order.coins(@coin_a.id, @coin_b.id).order('created_at DESC').page(params[:page]) 
      @tabinfo = @coin_a.ticker + '-' + @coin_b.ticker
      @path12 = admins_index_order_btc_ltc_path
      @path13 = admins_index_order_btc_mona_path
      @path14 = admins_index_order_btc_doge_path
      @path23 = admins_index_order_ltc_mona_path
      @path24 = admins_index_order_ltc_doge_path
      @path34 = admins_index_order_mona_doge_path
      store_location
      render 'index_order_form'
    end

    def test_email_create_params
      params.permit(:email, :title, :content)
    end

end

