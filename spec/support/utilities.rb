include ApplicationHelper

def sign_in(user)
  visit new_user_session_path
  fill_in "メールアドレス", with: user.email
  fill_in "パスワード", with: user.password
  click_button "ログイン"
end

# 
# below mmethods are to check orderbook.rb
# 

# acnt の合計のコインの金額を返す。
def total_amount_in_acounts(coin)
  Acnt.where(cointype: coin).sum(:balance)
end

# locked_balの合計と、Open Orderの未決済金額が釣り合うか。
# 釣り合えばその額、でなればfalseを返す。
def check_amount_yet_in_orders_and_aconts(coin)
  comb = Cointype.tickercomb
  order_amt = 0
  comb.each do | com |
    coin1 = coin_t2c(com[0])
    coin2 = coin_t2c(com[1])
    if com[0] == coin.ticker then
      order_amt += Order.where(coin_a: coin1, coin_b: coin2, buysell: true).sum(:amt_a)
    elsif com[1] == coin.ticker then
      order_amt += Order.where(coin_a: coin1, coin_b: coin2, buysell: false).sum(:amt_b)
    end
  end
  locked_bal = Acnt.where(cointype: coin).sum(:locked_bal)
  if order_amt == locked_bal
    return locked_bal
  else
    return false
    # return order_amt, locked_bal
  end
end



# def sign_in(user, options={})
#   if options[:no_capybara]
#     # Capybaraを使用していない場合にもサインインする。
#     remember_token = User.new_remember_token
#     cookies[:remember_token] = remember_token
#     user.update_attribute(:remember_token, User.encrypt(remember_token))
#   else
#     visit new_user_session_path
#     fill_in "メールアドレス", with: user.email
#     fill_in "パスワード", with: user.password
#     click_button "ログイン"
#   end
# end

