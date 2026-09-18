class EvalRun < ApplicationRecord
  validates :coder, presence: true
  default_scope { order(ran_at: :desc) }
end
