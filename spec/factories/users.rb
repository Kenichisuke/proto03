FactoryGirl.define do
  factory :user do
    sequence(:email) { |n| "person_#{n}@example.com"}
    # email "abc@example.com"
    password "foofoobar"
    password_confirmation "foofoobar"
    confirmed_at Time.now
    factory :admin do
      admin true
    end

    # after(:create) do | user |
    #   ["BTC", "LTC", "MONA", "DOGE"].each do | acnt |
    #     coin = Cointype.find_by(ticker: acnt)
    #     FactoryGirl.create(:acnt, cointype: coin, user: user )
    #   end
    # end

  end
end