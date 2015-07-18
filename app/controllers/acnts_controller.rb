class AcntsController < ApplicationController
  before_action :authenticate_user!

  def show
    @acnts = current_user.acnt
    @headinfo = "balance"
  end

end
