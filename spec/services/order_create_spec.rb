require 'rails_helper'

describe OrderCreate do

  coin1 = FactoryGirl.create(:bitcoin)
  coin2 = FactoryGirl.create(:litecoin)
  # coin3 = FactoryGirl.create(:monacoin)
  # coin4 = FactoryGirl.create(:dogecoin)

  let!( :user )  { FactoryGirl.create(:user) }
  let!( :acnt1 ) { FactoryGirl.create(:acnt, user: user, cointype: coin1, balance: 100)}
  let!( :acnt2 ) { FactoryGirl.create(:acnt, user: user, cointype: coin2, balance: 10000)}
  let( :cr)      { FactoryGirl.create(:coin_relation, coin_a: coin1, coin_b: coin2, step_min: 10 )}

  describe "Order without DB transation failure. " do

    context "sell order amount within account" do
      let( :order_create ) { OrderCreate.new( user: user, coin_relation: cr, rate: 100, buysell: true, amt: 100)}
      it "check order, return true" do
        expect( order_create.check_order? ).to eq true
      end
      it "save order and acnt, will success" do
        expect{ order_create.save_new_order_with_acnt! }.to change(Order, :count).by(1)
      end
      it "save order. acnt locked_bal change" do
        order_create.save_new_order_with_acnt!
        expect{ acnt1.reload }.to change(acnt1, :locked_bal).by(100)
        # reload necessary important !!!!!!!
      end
    end

    context "Buy order amount within account. " do
      let( :order_create ) { OrderCreate.new( user: user, coin_relation: cr, rate: 100, buysell: false, amt: 500)}
      it "check order, return true" do
        expect( order_create.check_order? ).to eq true
      end
      it "save order and acnt, will success" do
        expect{ order_create.save_new_order_with_acnt! }.to change(Order, :count).by(1)
      end
      it "save order. acnt locked_bal change" do
        order_create.save_new_order_with_acnt!
        expect{ acnt2.reload }.to change(acnt2, :locked_bal).by(500)
        # reload necessary important !!!!!!!
      end
    end

    context "Sell order amount bigger than account. " do
      let( :order_create ) { OrderCreate.new( user: user, coin_relation: cr, rate: 100, buysell: true, amt: 101)}
      it "preparation of transaction, return true or false" do
        expect( order_create.check_order? ).to eq false
      end
      it "save order and acnt, will give exception" do
        expect{ order_create.save_new_order_with_acnt! }.to raise_error(ActiveRecord::StatementInvalid)
      end
    end
  end
end

      # context "failure of new order, Database transaction error" do
      #   before {
      #     expect( order_create ).to receive( :transaction_order_acnt ).at_least(:once) { raise 'Hello, this is test!' }
      #     order_create.prep_acnt_with_order?
      #   }
      #   it "save order and acnt, but fail and throw exception" do
      #     expect { order_create.save_new_order_with_acnt! }.to raise_error( 'Hello, this is test!' )
      #   end

      #   it "try to save new order. but fail. NO. of order unchange" do
      #     cnt = Order.count
      #     begin
      #       order_create.save_new_order_with_acnt!
      #     rescue
      #       expect( Order.count - cnt ).to eq(0)
      #     else
      #       expect(true).to be false
      #     end
      #   end

      #   it "try to save new order. but fail. Acnt locked_bal unchange" do
      #     begin
      #       order_create.save_new_order_with_acnt!
      #     rescue
      #       acnt1.reload
      #       expect( acnt1.locked_bal ).to eq( 0 )
      #     else
      #       expect(true).to be false
      #     end
      #   end
      # end
    
