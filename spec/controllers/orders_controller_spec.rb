require 'spec_helper'

describe "OrdersController"  do
  before do
   	FactoryGirl.create(:cointype)
  	# FactoryGirl.create(:user)
  	# FactoryGirl.create(:acnt)
  end

  describe "show login page" do
    it "hsould have the content login" do
      visit '/en/users/sign_in'
      expect(page).to have_content("Log in")
    end

	  # describe "login with valid information" do
	  #   before do
	  #     fill_in "Email",        with: "user_0@example.com"
	  #     fill_in "Password",     with: "foobar"
	  #     click_button "Log in"
	  #   end
	  #   it { should have_content('success') }

	  #   # describe "login and make order" do
    #   #   before do
	  #   #     fill_in "Rate:",          with: 10
	  #   #     fill_in "Amount",         with: 0.2
	  #   #     click_button "Issue Order 'Buy BTC / Sell LTC'"
	  #   #   end
   #   #    expect { click_button submit }.to change(Order, :count).by(1)
   #   #  end
   #  end
  end
end
