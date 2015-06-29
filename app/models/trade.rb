class Trade < ActiveRecord::Base
  belongs_to :order
  enum flag: [:tr_new, :tr_close, :tr_diffdone, :tr_diffwip, :tr_cncl, :tr_expr] 

  scope :coins, -> (coin1, coin2) { where("(coin_a_id = ? AND coin_b_id = ?)", coin1, coin2 )}
  # scope :non_diff, -> { where(flag: [:tr_new, :tr_close, :tr_wip, :tr_cncl, :tr_expr]) }
  scope :non_diff, -> { where(flag: [0, 1, 4, 5]) }
end

