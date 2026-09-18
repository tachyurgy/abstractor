class EvalCase < ApplicationRecord
  validates :title, :note, presence: true
end
