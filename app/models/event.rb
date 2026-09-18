class Event < ApplicationRecord
  belongs_to :encounter
  validates :actor, :action, presence: true

  def readonly? = persisted?   # append-only: rows can be created, never changed
  before_destroy { throw :abort }
end
