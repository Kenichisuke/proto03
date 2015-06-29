class Coinio < ActiveRecord::Base
  belongs_to :cointype
  belongs_to :acnt

  enum tx_category: [ :tx_receive, :tx_immature, :tx_generate, :tx_send, :tx_orphan ]
  enum flag: { in_yet: 0, in_done: 6,
            out_sent: 7, out_abnormal: 19, out_reserve: 25,
            out_r_sent: 31, out_r_n_cncl: 59, out_r_n_acnt: 91, out_r_n_addr: 123 }


  scope :pickup_categ, -> { where(tx_category: [0, 1, 2]) }
  scope :action_coinio, -> { where(flag: [19, 25]).order('created_at DESC') }

  validates :cointype_id, presence:  true
  validates :amt, numericality: { greater_than: 0.0 }
end

# 0th bit  0: in, 1: out
# 1st bit  0: This coinio not closed, 1: closed (to not change anymore)
# 2nd bit  0: account not updated, 1: Account updated
# 
# when 0th bit, 0:in
#
#   0-2nd bit, txtype
#   000: immature: 00: in_yet   :tx_immatureの状態
#   011: (none):   06: in_done  :Wallet入金でない、入金（使わない予定）
#   011: receive:  06: in_done  :tx_receive で受け取った
#
# when 0th bit, 
#  3rd bit
#    0: 予約でない
#    1: 予約
#  4th bit, system status at created
#    0: normal, 1：abnormal
#  5-6th bit (closing status when reserve: 0th, 1st, 3rd bit がすべて1の時のみ)
#    00: OK (or NA)
#    01: キャンセル
#    10: 残高不足
#    11: アドレス不良
#
#   0--3--6th bit, txtype,
#   1110000: send:   007: out_sent     :sent, 正常終了
#   1100100: (none): 019: out_abnormal :異常終了
#   1001100: (none): 025: out_reserve  :Walletが動いていない(予約)no execution, canceled&closed
#   1111100: send:   031: out_r_sent   :予約後、sent, 正常終了
#   1101110: (none): 059: out_r_n_cncl :予約後、本人がキャンセル
#   1101101: (none): 091: out_r_n_acnt :予約後、残高不足
#   1101111: (none): 123: out_r_n_addr :予約後、アドレスが不良


