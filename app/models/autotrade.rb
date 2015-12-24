class Autotrade < ActiveRecord::Base
  belongs_to :user
  belongs_to :coin_relation
end
