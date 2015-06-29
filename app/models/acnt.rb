class Acnt < ActiveRecord::Base
  include CoinUtil

  belongs_to :user
  belongs_to :cointype
  has_many :coinio

  validates :user_id, presence: true, uniqueness: { scope: :cointype_id }
  validates :cointype_id, presence: true  
  validates :balance, numericality: {greater_than_or_equal_to: 0.0}
  validates :locked_bal, numericality: {greater_than_or_equal_to: 0.0}
  validate :balance_tobe_bigger_than_locked_bal
 
  def self.registration(user_id, coin_t, user_num)
    coin = Cointype.find_by(ticker: coin_t)
    acnt_num = user_num.to_s
    addr = Coinrpc.getnewaddr(coin.ticker, acnt_num)
    Acnt.create!(user_id: user_id, cointype_id: coin.id,
      balance:  0, locked_bal: 0, addr_in: addr, acnt_num: acnt_num)
  end

  def self.registration_w_addr(user_id, coin_t, user_num, addr)
    # 新しく address を取らない。
    coin = Cointype.find_by(ticker: coin_t)
    acnt_num = user_num.to_s
    Acnt.create!(user_id: user_id, cointype_id: coin.id,
      balance:  0, locked_bal: 0, addr_in: addr, acnt_num: acnt_num)
  end

  def lock_amt(amt)
    self.locked_bal += amt
  end

  def unlock_amt(amt)
    self.locked_bal -= amt
  end

  private
    def balance_tobe_bigger_than_locked_bal
      if locked_bal > balance then
      	errors.add(:base, I18n.t('acnt.bal_not_enough_for_lock'))
      end
    end

end
