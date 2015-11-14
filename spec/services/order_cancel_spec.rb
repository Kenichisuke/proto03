require 'rails_helper'

describe OrderCancel do

  coin1 = FactoryGirl.create(:bitcoin)
  coin2 = FactoryGirl.create(:litecoin)
  # coin3 = FactoryGirl.create(:monacoin)
  # coin4 = FactoryGirl.create(:dogecoin)

  let( :user ) { FactoryGirl.create(:user) }
  let!( :acnt1 ) {FactoryGirl.create(:acnt, user: user, cointype: coin1, locked_bal: 50)}
  let!( :acnt2 ) {FactoryGirl.create(:acnt, user: user, cointype: coin2, locked_bal: 50)}
  let( :order_cancel ) { OrderCancel.new( order ) }

  describe "cancel order (Sell 1 BTC/Buy 10 LTC), balance=100, locked_bal=50" do
    let( :order ) { FactoryGirl.create(:order, user: user, coin_a: coin1, coin_b: coin2) }

    context "success of order cancellation" do
      it "preparation of order cancel, return true" do
        expect( order_cancel.prep_cancel? ).to eq true
      end
      it "save order cancellation. not throw exception" do
        order_cancel.prep_cancel?
        expect{ order_cancel.save_cancel! }.not_to raise_error
      end
      it "save order cancellation. create trade" do
        order_cancel.prep_cancel?
        expect{ order_cancel.save_cancel! }.to change(Trade, :count).by(1)
      end
      # important!!!
      # key: reload
      it "save order cancellation. acnt locked_bal change" do
        order_cancel.prep_cancel?
        order_cancel.save_cancel!
        expect{ acnt1.reload }.to change(acnt1, :locked_bal).by(-1)
      end
      it "save order cancellation. order flag change" do
        order_cancel.prep_cancel?
        order_cancel.save_cancel!
        order.reload
        expect( order.flag ).to eq( "noex_cncl" ) 
        # expect( order.noex_cncl? ).to true 
        # does not work. NoMethodError:
      end
    end

    context "failure of order cancellation, Database transaction error" do
      # important !!!!!!!
      # using stub
      before {
        expect( order_cancel ).to receive( :transaction_order_cancel ).at_least(:once) { raise 'Hello, this is test!' }
        order_cancel.prep_cancel?        
      }
      it "try to save order, acnt and trade. but fail and throw exception" do
        expect { order_cancel.save_cancel! }.to raise_error( 'Hello, this is test!' )
      end

      #important !!!
      # I do not know how to write the code in bettwer way.
      it "try to save order, acnt and trade. but fail and order flag remains 'open_new'" do
        begin
          order_cancel.save_cancel!
        rescue
          order.reload
          expect(order.flag).to eq("open_new")
        end
      end

      it "try to save order, acnt and trade. but fail and order flag remains 'open_new'" do
        begin
          order_cancel.save_cancel!
        rescue
          expect{ acnt1.reload}.not_to change(acnt1, :locked_bal)
        end
      end

      it "try to save order, acnt and trade. but fail and order flag remains 'open_new'" do
        cnt = Trade.count
        begin
          order_cancel.save_cancel!
        rescue
          expect( Trade.count - cnt ).to eq(0)
        end
      end
    end
  end

  describe "cancel order (Sell 1 BTC/Buy 10 LTC), balance=100, locked_bal=50" do
    let( :order ) { FactoryGirl.create(:order, user: user, coin_a: coin1, coin_b: coin2, buysell: false) }

    context "success of order cancellation" do

      it "preparation of order cancel, return true" do
        expect( order_cancel.prep_cancel? ).to eq true
      end

      it "save order cancellation. not throw exception" do
        order_cancel.prep_cancel?
        expect{ order_cancel.save_cancel! }.not_to raise_error
      end

      it "save order and check acnt amount" do
        order_cancel.prep_cancel?
        order_cancel.save_cancel!
        expect{ acnt2.reload }.to change(acnt2, :locked_bal).by(-10)
      end
    end
  end

  describe "cancel order (Sell 1 BTC/Buy 10 LTC) half executed. balance=100, locked_bal=50" do
    let( :order ) { FactoryGirl.create(:order, user: user, coin_a: coin1, coin_b: coin2, amt_a: 0.4, amt_b: 4, flag: :open_per) }

    context "success of order cancellation" do

      it "preparation of order cancel, return true" do
        expect( order_cancel.prep_cancel? ).to eq true
      end

      it "save order cancellation. not throw exception" do
        order_cancel.prep_cancel?
        expect{ order_cancel.save_cancel! }.not_to raise_error
      end

      it "save order cancellation. create trade" do
        order_cancel.prep_cancel?
        expect{ order_cancel.save_cancel! }.to change(Trade, :count).by(1)
      end

      it "save order cancellation. acnt locked_bal change" do
        order_cancel.prep_cancel?
        order_cancel.save_cancel!
        expect{ acnt1.reload }.to change(acnt1, :locked_bal).by(-0.4)
      end
    
      it "save order cancellation. order flag change" do
        order_cancel.prep_cancel?
        order_cancel.save_cancel!
        order.reload
        expect( order.flag ).to eq( "exec_cncl" ) 
        # expect( order.noex_cncl? ).to true 
        # does not work. NoMethodError:
      end
    end
  end

end

    
