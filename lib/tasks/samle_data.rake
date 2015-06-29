namespace :db do
  desc "Fill database with sample data"
  task populate: :environment do
    # make_cointypes
    make_users
    # make_coinios
  end
end

def make_cointypes
  Cointype.create!(name: "Bitcoin",
                ticker: "BTC",
                rank:   100,
                min_in: 0.0001,
                fee_out: 0.001,
                fee_trd: 0.001)
  Cointype.create!(name: "Litecoin",
                ticker: "LTC",
                rank:   80,
                min_in: 0.1,
                fee_out: 0.01,
                fee_trd: 0.001)
  Cointype.create!(name: "MonaCoin",
                ticker: "MONA",
                rank:   60,
                min_in: 0.001,
                fee_out: 0.001,
                fee_trd: 0.001)
  # Cointype.create!(name: "Dogecoin",
  #               ticker: "DOGE",
  #               rank:   40,
  #               min_in: 0.1,
  #               fee_out: 1,
  #               fee_trd: 0.001)
end

def make_users
  password = "ffffffff"
  # usr1 = User.create!(email: "example@abc.co.jp",
  #             password: password,
  #             password_confirmation: password, 
  #             confirmed_at: Time.now,
  #             confirmation_sent_at: Time.now,
  #             usernum: 100051,
  #             admin: true)
  # Acnt.create!(user_id: usr1.id,
  #             cointype_id: Cointype.find_by(ticker: "BTC").id,
  #             balance:  0,
  #             locked_bal: 0,
  #             acnt_num: "100051A")
  # Acnt.create(user_id: usr1.id,
  #             cointype_id: Cointype.find_by(ticker: "LTC").id,
  #             balance:  0,
  #             locked_bal: 0,
  #             acnt_num: "100051B",
  #             addr_in: "mw1NjCQDYTyRddtKCziDQhwTyWXQVqqcTB")
  # Acnt.create(user_id: usr1.id,
  #             cointype_id: Cointype.find_by(ticker: "MONA").id,
  #             balance:  0,
  #             locked_bal: 0,
  #             acnt_num: "100051C",
  #             addr_in: "mrBJG4KZjawmHUsPnq2hP4LrWbcuqnsBEv")

  # create open orders
  

  # 4.times do | n |
  #   make_order(usr1.id, "BTC", "MONA", true, 1, n + 100)
  #   make_order(usr1.id, "LTC", "MONA", true, 10, n + 10)
  #   make_order(usr1.id, "LTC", "MONA", true, 10, n + 10)
  # end

  usr1 = User.find(1)
  usr2 = User.find(5)

  # usr2 = User.create!(email: "example-4@abc.co.jp",
  #             password: password,
  #             password_confirmation: password, 
  #             confirmed_at: Time.now,
  #             confirmation_sent_at: Time.now,
  #             admin: false)
  # Acnt.create!(user_id: usr2.id,
  #             cointype_id: Cointype.find_by(ticker: "BTC").id,
  #             balance:  10,
  #             locked_bal: 0)
  # Acnt.create(user_id: usr2.id,
  #             cointype_id: Cointype.find_by(ticker: "LTC").id,
  #             balance:  100,
  #             locked_bal: 0)
  # Acnt.create(user_id: usr2.id,
  #             cointype_id: Cointype.find_by(ticker: "MONA").id,
  #             balance:  1000,
  #             locked_bal: 420,
  #             acnt_num: "154330")

  4.times do | n |
    make_order(usr2.id, "BTC", "MONA", false, 1, 99 - n)
    make_order(usr2.id, "LTC", "MONA", false, 10, 9 - n)
  end

  pr = 100
  vl = 1.0
  tm = Time.local(2015, 6, 27, 14, 2, 0) 
  (12 * 72 + 1).times do | n |  # 3日と5分　分
    make_order_tr(usr1.id, usr2.id, 'BTC', 'MONA', true, vl, pr, tm)
    pr = pr + (rand(21) - 10)/10.0
    if pr < 1.0 then
      pr = 1.0
    end
    vl = (rand(20) + 1) / 10.0
    tm = tm + (5 * 60)  # 5分ずらす
  end
end

# create open order
def make_order(user_id, coin1_t, coin2_t, buysell, amt_a, rate)
  Order.create!(user_id: user_id,
              coin_a_id: Cointype.find_by(ticker: coin1_t).id,
              coin_b_id: Cointype.find_by(ticker: coin2_t).id,
              buysell: buysell,   #btc売り円買い
              amt_a: amt_a,
              amt_b: amt_a * rate,
              amt_a_org: amt_a,
              amt_b_org: amt_a * rate,
              rate: rate,
              flag: 0)
end

# create closed order with trades
def make_order_tr(user1_id, user2_id, coin1_t, coin2_t, buysell, amt_a, rate, tm)
  coin1 = Cointype.find_by(ticker: coin1_t).id
  coin2 = Cointype.find_by(ticker: coin2_t).id
  ord = Order.create!(user_id: user1_id,
              coin_a_id: coin1,
              coin_b_id: coin2,
              buysell: buysell,   #btc売り円買い
              amt_a: 0,
              amt_b: 0,
              amt_a_org: amt_a,
              amt_b_org: amt_a * rate,
              rate: rate,
              flag: :exec_exec,
              created_at: tm,
              updated_at: tm)

  Trade.create!(order_id: ord.id,
              coin_a_id: coin1,
              coin_b_id: coin2,
              amt_a: amt_a,
              amt_b: amt_a * rate,
              fee: 0,
              flag: :tr_close,
              created_at: tm,
              updated_at: tm)

  ord = Order.create!(user_id: user2_id,
              coin_a_id: coin1,
              coin_b_id: coin2,
              buysell: !buysell,   #btc売り円買い
              amt_a: 0,
              amt_b: 0,
              amt_a_org: amt_a,
              amt_b_org: amt_a * rate,
              rate: rate,
              flag: :exec_exec,
              created_at: tm,
              updated_at: tm)
  Trade.create!(order_id: ord.id,
              coin_a_id: coin1,
              coin_b_id: coin2,       
              amt_a: amt_a, 
              amt_b: amt_a * rate, 
              fee: 0,
              flag: :tr_close,
              created_at: tm,
              updated_at: tm)
end

def make_coinios
  Coinio.create(cointype_id: 1, 
              tx_category: :tx_send,
              amt: 1,
              flag: :out_sent,
              acnt_id: 1,
              txid: "aa",
              fee: 0.001)
  Coinio.create(cointype_id: 1, 
              tx_category: :tx_send,
              amt: 1,
              flag: :out_abnormal,
              acnt_id: 1,
              txid: "aa",
              fee: 0.001)
  Coinio.create(cointype_id: 1, 
              tx_category: :tx_send,
              amt: 1,
              flag: :out_reserve,
              acnt_id: 1,
              txid: "aa",
              fee: 0.001)
  Coinio.create(cointype_id: 1, 
              tx_category: :tx_send,
              amt: 1,
              flag: :out_r_sent,
              acnt_id: 1,
              txid: "aa",
              fee: 0.001)
  Coinio.create(cointype_id: 1, 
              tx_category: :tx_send,
              amt: 1,
              flag: :out_r_n_cncl,
              acnt_id: 1,
              txid: "aa",
              fee: 0.001)
  Coinio.create(cointype_id: 1, 
              tx_category: :tx_send,
              amt: 1,
              flag: :out_r_n_acnt,
              acnt_id: 1,
              txid: "aa",
              fee: 0.001)
  Coinio.create(cointype_id: 1, 
              tx_category: :tx_send,
              amt: 1,
              flag: :out_r_n_addr,
              acnt_id: 1,
              txid: "aa",
              fee: 0.001)
  Coinio.create(cointype_id: 1, 
              tx_category: :tx_receive,
              amt: 2,
              flag: :in_done,
              acnt_id: 1,
              txid: "aa",
              fee: 0)
  Coinio.create(cointype_id: 1, 
              tx_category: :tx_generate,
              amt: 2,
              flag: :in_done,
              acnt_id: 1,
              txid: "aa",
              fee: 0)
  Coinio.create(cointype_id: 1, 
              tx_category: :tx_immature,
              amt: 2,
              flag: :in_yet,
              acnt_id: 1,
              txid: "aa",
              fee: 0)
end