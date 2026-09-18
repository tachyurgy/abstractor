class CodeSet < ApplicationRecord
  KINDS = %w[dx px].freeze
  validates :kind, inclusion: { in: KINDS }
  validates :code, presence: true, uniqueness: { scope: :kind }

  scope :dx, -> { where(kind: "dx") }
  scope :px, -> { where(kind: "px") }

  def self.lookup(kind, code) = find_by(kind: kind, code: code.to_s.upcase.strip)

  def keyword_list = keywords.split("|").map(&:strip).reject(&:empty?)
end
