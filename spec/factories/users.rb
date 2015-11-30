# == Schema Information
#
# Table name: users
#
#  id                     :integer          not null, primary key
#  email                  :string(255)      default(""), not null
#  encrypted_password     :string(255)      default(""), not null
#  reset_password_token   :string(255)
#  reset_password_sent_at :datetime
#  remember_created_at    :datetime
#  sign_in_count          :integer          default(0), not null
#  current_sign_in_at     :datetime
#  last_sign_in_at        :datetime
#  current_sign_in_ip     :string(255)
#  last_sign_in_ip        :string(255)
#  confirmation_token     :string(255)
#  confirmed_at           :datetime
#  confirmation_sent_at   :datetime
#  unconfirmed_email      :string(255)
#  failed_attempts        :integer          default(0), not null
#  unlock_token           :string(255)
#  locked_at              :datetime
#  created_at             :datetime         not null
#  updated_at             :datetime         not null
#  user_num               :string(255)      default("0")
#  admin                  :boolean          default(FALSE)
#

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
