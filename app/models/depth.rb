class Depth < ActiveRecord::Base
  belongs_to :coin_relation

  scope :coin_rel, -> (rel) { where("coin_relation_id = ?", rel) }

end
