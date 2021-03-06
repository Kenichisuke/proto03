# == Schema Information
#
# Table name: acnts
#
#  id          :integer          not null, primary key
#  user_id     :integer
#  cointype_id :integer
#  balance     :decimal(32, 8)   default(0.0), not null
#  locked_bal  :decimal(32, 8)   default(0.0), not null
#  addr_in     :string(255)
#  addr_out    :string(255)
#  created_at  :datetime         not null
#  updated_at  :datetime         not null
#  acnt_num    :string(255)
#

class Acnt < ActiveRecord::Base
  include CoinUtil

  belongs_to :user
  belongs_to :cointype
  has_many :coinios

  validates :user_id, presence: true, uniqueness: { scope: :cointype_id }
  validates :cointype_id, presence: true  
  validates :balance, numericality: {greater_than_or_equal_to: 0.0}
  validates :locked_bal, numericality: {greater_than_or_equal_to: 0.0}
  validate :balance_tobe_bigger_than_locked_bal

  def self.registration(user_id, coin_t, user_num)
    begin
      coin = Cointype.find_by(ticker: coin_t)
      addr = Coinrpc.getnewaddr(coin.ticker, user_num)
    rescue => e 
      logger.error('User registration: acnt registration cannot access wallet ' + coin.ticker )
      logger.error( e )
      addr = ""
    ensure
      Acnt.create(user_id: user_id, cointype_id: coin.id,
        balance: 0, locked_bal: 0, addr_in: addr, acnt_num: user_num)
    end
  end

  def self.registration_w_addr(user_id, coin_t, user_num, addr)
    # 新しく address を取らない。
    coin = Cointype.find_by(ticker: coin_t)
    Acnt.create!(user_id: user_id, cointype_id: coin.id,
      balance:  0, locked_bal: 0, addr_in: addr, acnt_num: user_num)
  end

  def free_bal
    self.balance - self.locked_bal
  end

  def lock_amt(amt)
    self.locked_bal += amt
  end

  def lock_amt?(amt)
    ((self.locked_bal + amt) <= self.balance) ? true : false 
  end

  def unlock_amt(amt)
    self.locked_bal -= amt
  end

  def unlock_amt?(amt)
    ((self.locked_bal - amt) > 0) ? true : false 
  end

  def self.find_user_coint(user_id, coin_t)
    Acnt.find_by(user: user_id, cointype: coin_t2i(coin_t))
  end

  def self.find_user_cr_buysell(user_id, cr, buysell)
    Acnt.find_by(user: user_id, cointype: (buysell ? cr.coin_a : cr.coin_b) )
  end

  private
    def balance_tobe_bigger_than_locked_bal
      if locked_bal > balance then
      	errors.add(:base, I18n.t('acnt.bal_not_enough_for_lock'))
      end
    end

end
