require 'spec_helper'
# require 'net/http'
# moved to spec/features/orders_spec.rb

describe OrdersController do

  coin1 = FactoryGirl.create(:bitcoin)
  coin2 = FactoryGirl.create(:litecoin)
  coin3 = FactoryGirl.create(:monacoin)
  coin4 = FactoryGirl.create(:dogecoin)

  FactoryGirl.create(:coin_relation, coin_a: coin1, coin_b: coin2)
  FactoryGirl.create(:coin_relation, coin_a: coin1, coin_b: coin3)
  FactoryGirl.create(:coin_relation, coin_a: coin1, coin_b: coin4)
  FactoryGirl.create(:coin_relation, coin_a: coin2, coin_b: coin3)
  FactoryGirl.create(:coin_relation, coin_a: coin2, coin_b: coin4)
  FactoryGirl.create(:coin_relation, coin_a: coin3, coin_b: coin4)

  user = FactoryGirl.create(:user)
  user2 = FactoryGirl.create(:user)
  acnt2 = user2.acnt.find_by(cointype_id: coin2.id)
  acnt2.locked_bal = 50
  acnt2.save

  describe "check setting" do
    it "No. of cointype" do
      expect(Cointype.count).to eq 4
    end
    it "check No. of acnts" do
      expect(user.acnt.count).to eq 4
    end
  end

  describe "visit root_path" do
    before{ visit root_path }

    # it "check" do
    #   puts page.body
    # end

    it "check page to have <h1>trade</h1> on root page" do
      expect(page).to have_selector('h1', text: I18n.t('order.trade')) 
    end
    it "check page if link available" do
      expect(page).to have_link( I18n.t('header.contact') ) 
    end
  end

  describe "test with login" do 
    before {
      visit new_user_session_path
      fill_in "メールアドレス", with: user.email
      fill_in "パスワード", with: user.password
      click_button "ログイン"
    }
    it "check page to have success message" do
      expect(page).to have_selector('div.alert.alert-notice.alert-dismissable',  
        text: I18n.t('devise.sessions.signed_in'))
    end
    describe "create order" do
      before {
        fill_in "レート", with: 10
        fill_in "数量", with: 1
        # save_and_open_page
        # 今の設定では、jsを使ったmodal windowsの確認画面は飛ばして処理されている。
      }
      it "to check incraese of No. of orders" do
        expect{ click_button "「BTC買い/LTC売り」を注文する" }
          .to change(Order, :count).by(1)
      end
    end
    describe "try to create wrong order" do
      before {
        fill_in "レート", with: "aa"
        fill_in "数量", with: 1
      }
      it "check page to have success message on order" do
        expect{ click_button "「BTC買い/LTC売り」を注文する" }
          .not_to change(Order, :count)
      end
    end
    describe "try to create wrong order" do
      before {
        fill_in "レート", with: 10
        fill_in "数量", with: "aa"
      }
      it "check page to have success message on order" do
        expect{ click_button "「BTC買い/LTC売り」を注文する" }
          .not_to change(Order, :count)
      end
    end    
    describe "try to create wrong order" do
      before {
        fill_in "レート", with: 10
        fill_in "数量", with: 0
      }
      it "check page to have success message on order" do
        expect{ click_button "「BTC買い/LTC売り」を注文する" }
          .not_to change(Order, :count)
      end  
    end
    describe "try to create wrong order" do
      before {
        fill_in "レート", with: 0
        fill_in "数量", with: 1
      }
      it "check page to have success message on order" do
        expect{ click_button "「BTC買い/LTC売り」を注文する" }
          .not_to change(Order, :count)
      end  
    end
    describe "try to create wrong order (excess of acount)" do
      before {
        fill_in "レート", with: 10
        fill_in "数量", with: 15
      }
      it "check page to have success message on order" do
        expect{ click_button "「BTC買い/LTC売り」を注文する" }
          .not_to change(Order, :count)
      end 
    end
    describe "try to create wrong order (excess of acount)" do
      before {
        fill_in "レート", with: 10
        fill_in "数量", with: 102
      }
      it "check page to have success message on order" do
        expect{ click_button "「BTC売り/LTC買い」を注文する" }
          .not_to change(Order, :count)
      end 
    end
  end

  describe "login with user2 (locked_bal=50, free_bal=50)" do 
    before {
      visit new_user_session_path
      fill_in "メールアドレス", with: user2.email
      fill_in "パスワード", with: user2.password
      click_button "ログイン"
    }
    describe "create order which exceed free_bal" do
      before {
        fill_in "レート", with: 10
        fill_in "数量", with: 6
      }
      it "check order count not change" do
        expect{ click_button "「BTC買い/LTC売り」を注文する" }
          .not_to change(Order, :count)
      end
    end
    describe "create order which exceed free_bal" do
      before{
        fill_in "レート", with: 10
        fill_in "数量", with: 6
        click_button "「BTC買い/LTC売り」を注文する"
      }
      it "check pageto  have error message on order" do
        expect(page).to have_content(I18n.t('errors.messages.order.free_bal_not_enough'))
      end
    end
  end
end
