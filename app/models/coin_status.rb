class CoinStatus
  attr_accessor :ticker, :status, :init_bal, :db_bal, :db_diff_bal, :db_locked_bal, :wallet_bal

  def initialize(ticker = nil, status = nil, init_bal = nil, db_bal = nil, db_diff_bal = nil, db_locked_bal = nil, wallet_bal = nil)
  	@ticker = ticker
  	@status = status
  	@init_bal = init_bal
  	@db_bal = db_bal
  	@db_diff_bal = db_diff_bal  	
  	@db_locked_bal = db_locked_bal
  	@wallet_bal = wallet_bal
  end
end


