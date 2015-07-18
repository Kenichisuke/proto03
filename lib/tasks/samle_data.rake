namespace :db do
  desc "Fill database with sample data"
  task populate: :environment do
#    make_cointypes
#    make_users
    make_open_orders
    make_close_orders
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
  Cointype.create!(name: "Monacoin",
                ticker: "MONA",
                rank:   60,
                min_in: 0.001,
                fee_out: 0.001,
                fee_trd: 0.001)
  Cointype.create!(name: "Dogecoin",
                ticker: "DOGE",
                rank:   40,
                min_in: 0.1,
                fee_out: 1,
                fee_trd: 0.001)
end

def make_users
  password = "ffffffff"
  usr1 = User.create!(email: "example@abc.co.jp",
              password: password,
              password_confirmation: password, 
              confirmed_at: Time.now,
              confirmation_sent_at: Time.now,
              user_num: "100101",
              admin: true)
  Acnt.create!(user_id: usr1.id,
              cointype_id: Cointype.find_by(ticker: "BTC").id,
              balance:  0,
              locked_bal: 0,
              acnt_num: "100101",
              addr_in: "mpLXmL6khttHADCxahX3rUC6Xqk3pPyTHH")
  Acnt.create(user_id: usr1.id,
              cointype_id: Cointype.find_by(ticker: "LTC").id,
              balance:  0,
              locked_bal: 0,
              acnt_num: "100101",
              addr_in: "mjAhow8fmN9W1gNyVNBUD2Jt6NMRiBj34M")
  Acnt.create(user_id: usr1.id,
              cointype_id: Cointype.find_by(ticker: "MONA").id,
              balance:  0,
              locked_bal: 0,
              acnt_num: "100101",
              addr_in: "mqyakP8kmBLJRodUu4HFuMwibwSxAFSqUq")
  Acnt.create(user_id: usr1.id,
              cointype_id: Cointype.find_by(ticker: "DOGE").id,
              balance:  0,
              locked_bal: 0,
              acnt_num: "100101",
              addr_in: "nmMpAoMGqJvx2bGS3L8bZvs1FZ9TBvGzNW")
end


# create open orders  
def make_open_orders
  usr1 = User.find(6)
  make_open_order_coins(usr1.id,  "BTC", "LTC",       60.3, 0.2, 0.1)
  make_open_order_coins(usr1.id,  "BTC", "MONA",     1_810,   1,   1)
  make_open_order_coins(usr1.id,  "BTC", "DOGE", 1_467_406,   1,  10)    
  make_open_order_coins(usr1.id,  "LTC", "MONA",      29.9, 0.1,   1)    
  make_open_order_coins(usr1.id,  "LTC", "DOGE",   242_031,  10,  10)    
  make_open_order_coins(usr1.id, "MONA", "DOGE",       810,   1,  10)    
end

# step must be 0.1 or bigger
def make_open_order_coins(user_id, coint1, coint2, center, step, maxvol)
  10.times do | n |
    make_order(user_id, coint1, coint2,  true, (rand(10) + 1) * maxvol / 10.0, center - step * (n + 1))
    make_order(user_id, coint1, coint2, false, (rand(10) + 1) * maxvol / 10.0, center - step * (n + 1))
  end
end

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



def make_close_orders
  usr1 = User.find(6)
  tmstr = Time.local(2015, 7, 15, 6, 22, 0)
  tmend = Time.local(2015, 7, 17, 8, 22, 0) 

  make_close_order_coins(usr1.id, "BTC", "LTC",       60.3, tmstr, tmend, 5)
  make_close_order_coins(usr1.id, "BTC", "MONA",     1_810, tmstr, tmend, 5)
  make_close_order_coins(usr1.id, "BTC", "DOGE", 1_467_406, tmstr, tmend, 5)
  make_close_order_coins(usr1.id, "LTC", "MONA",      29.9, tmstr, tmend, 5)
  make_close_order_coins(usr1.id, "LTC", "DOGE",   242_031, tmstr, tmend, 5)
  make_close_order_coins(usr1.id, "MONA", "DOGE",      810, tmstr, tmend, 5)
end

# 時間をさかのぼってデータを作る。
# step : 何分おきのデータを作るのか
def make_close_order_coins(user_id, coin1_t, coin2_t, pr, tmstr, tmend, step)
  kai = ((tmend - tmstr) / ( step * 60) + 1).floor

  vl = 1

  kai.times do | n |

    tm = tmend - (n * step * 60)

    make_order_tr(user_id, user_id, coin1_t, coin2_t, vl, pr, tm)

    range = (pr * 0.08).round(0)
    if range < 3 then
      range = 3
    end

    pr = pr + (rand(range * 10) - (range * 5))/10.0
    if pr < 1.0 then
      pr = 1.0
    end

    tm = tmend - (n * step * 60)

  end

  # pr = 100
  # vl = 1.0
  # tm = Time.local(2015, 6, 27, 14, 2, 0) 
  # (12 * 72 + 1).times do | n |  # 3日と5分　分
  #   make_order_tr(usr1.id, usr2.id, 'BTC', 'MONA', true, vl, pr, tm)
  #   pr = pr + (rand(21) - 10)/10.0
  #   if pr < 1.0 then
  #     pr = 1.0
  #   end
  #   vl = (rand(20) + 1) / 10.0
  #   tm = tm + (5 * 60)  # 5分ずらす
  # end
end

# create closed order with trades
def make_order_tr(user1_id, user2_id, coin1_t, coin2_t, amt_a, rate, tm)
  coin1 = Cointype.find_by(ticker: coin1_t).id
  coin2 = Cointype.find_by(ticker: coin2_t).id
  ord = Order.create!(user_id: user1_id,
              coin_a_id: coin1,
              coin_b_id: coin2,
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
