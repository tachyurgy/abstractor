# ICD-10-CM Excludes1 note: "NOT CODED HERE". The two conditions cannot occur together,
# so a claim carrying both is wrong by definition. Prefix match on either side so a
# category-level rule (E11 vs E10) covers every subcode (E11.9 vs E10.65).
class Excludes1Rule < ApplicationRecord
  validates :code_a, :code_b, :note, presence: true

  def self.conflicts_among(codes)
    codes = codes.map { |c| c.to_s.upcase }
    all.flat_map do |r|
      a = codes.select { |c| c.start_with?(r.code_a) }
      b = codes.select { |c| c.start_with?(r.code_b) }
      a.product(b).map { |x, y| { rule: r, codes: [x, y] } }
    end
  end
end
