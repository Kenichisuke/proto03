class AcntsController < ApplicationController
  before_action :authenticate_user!

  def show
    @acnts = current_user.acnts
    @headinfo = "balance"
  end

end
