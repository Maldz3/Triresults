class RaceRef
  include Mongoid::Document
  field :n, type: String, as: :name
  field :date, type: Date

  embedded_in :entrant
  belongs_to :race, foreign_key: "_id"
end
