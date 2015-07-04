# == Schema Information
#
# Table name: orders
#
#  id         :integer          not null, primary key
#  user_id    :integer
#  coin_a_id  :integer
#  coin_b_id  :integer
#  amt_a_org  :decimal(32, 8)   default(0.0), not null
#  amt_b_org  :decimal(32, 8)   default(0.0), not null
#  amt_a      :decimal(32, 8)   default(0.0), not null
#  amt_b      :decimal(32, 8)   default(0.0), not null
#  rate       :decimal(32, 10)  default(0.0), not null
#  buysell    :boolean
#  flag       :integer
#  created_at :datetime         not null
#  updated_at :datetime         not null
#

class Order < ActiveRecord::Base
  belongs_to :user
  belongs_to :coin_a, class_name: "Cointype"
  belongs_to :coin_b, class_name: "Cointype"
  has_many :trade

  enum flag: {open_new: 0, open_per: 2, noex_cncl: 5, exec_cncl: 7, noex_expr: 9, exec_expr: 11, exec_exec: 15,
              b_fnsh: 1, b_onee: 2, b_cncl: 4, b_expr: 8, b_exec: 12 }

  # あとで、b_fnsh: 1, b_onee: 2, b_cncl: 4, b_expr: 8, b_exec: 12
  # をとりのぞく必要がある（だろう）。なぜなら、つかう方法がない。

  scope :openor, -> { where(flag: [0, 2]) }

  scope :match_order_sell, -> (max) { where(buysell: true).where(flag: [0, 2])
                .where('rate <= ?', max).order('rate ASC, created_at ASC') } 
  scope :match_order_buy, -> (min) { where(buysell: false).where(flag: [0, 2])
                .where('rate >= ?', min).order('rate DESC, created_at ASC') } 
  scope :coins, -> (coin1, coin2) { where("(coin_a_id = ? AND coin_b_id = ?)",coin1, coin2) }
  # scope :coin2ways, -> (coin1, coin2) { where("(coin_a_id = ? AND coin_b_id = ?) OR (coin_a_id = ? AND coin_b_id = ?)",
  #        coin1, coin2, coin2, coin1) }

  validates :user_id, presence:  true
  validates :coin_a_id, presence:  true
  validates :coin_b_id, presence:  true  
  validates :amt_a, numericality: { greater_than_or_equal_to: 0.0 }
  validates :amt_b, numericality: { greater_than_or_equal_to: 0.0 } 
  validates :amt_a_org, numericality: { greater_than_or_equal_to: 0.0 }
  validates :amt_b_org, numericality: { greater_than_or_equal_to: 0.0 } 
  validates :rate, numericality: { greater_than_or_equal_to: 0.0 } 
  validates :flag, presence:  true
end

# 0th bit  0: not finishted, 1: finished
# 1th bit  0: no execution, 1: 1 or more execution(s)
# 2nd, 3rd bit:  closing-status
#   01: expired
#   10: canceled
#   11: excecutsion
#
#   0000: 00: open_new     :no execution yet, open 
#   0100: 02: open_per     :pertially executed, open
#   1001: 09: noex_expr  :no execution, expired&closed 
#   1010: 05: noex_cncl  :no execution, canceled&closed
#   1101: 11: exec_expr  :execution(s), expired at last &closed
#   1110: 07: exec_cncl  :execution(s), cancled at last &closed
#   1111: 15: exec_exec  :execution(s), executed at last &closed
#
#   1000: 01: B_fnsh
#   0100: 02: B_onee
#   0010: 04: B_cncl
#   0001: 08: B_expr 
#   0011: 12: B_exec

