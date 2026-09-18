class Encounter < ApplicationRecord
  class Finalized < StandardError; end
  class NotReady  < StandardError; end

  STATUSES = %w[new proposed finalized].freeze
  has_many :code_proposals, -> { order(:position, :id) }, dependent: :destroy
  has_many :events, -> { order(:created_at, :id) }, dependent: :destroy
  validates :patient_ref, :provider, :date_of_service, :note, presence: true
  validates :status, inclusion: { in: STATUSES }

  broadcasts_refreshes

  scope :worklist, -> { order(Arel.sql("CASE status WHEN 'new' THEN 0 WHEN 'proposed' THEN 1 ELSE 2 END"), :date_of_service, :id) }

  def finalized? = status == "finalized"
  def accepted_dx = code_proposals.dx.accepted
  def accepted_px = code_proposals.px.accepted
  def issues = ClaimValidator.new(self).issues
  def ready? = !finalized? && issues.none? { |i| i[:severity] == "block" } && code_proposals.accepted.any?

  # Exactly once. The row lock serialises concurrent finalizers; the status re-read
  # under the lock is what makes the second one fail instead of double-issuing a claim.
  def finalize!(by:)
    transaction do
      lock!
      raise Finalized, "already finalized as #{claim_number}" if finalized?
      blocking = issues.select { |i| i[:severity] == "block" }
      raise NotReady, blocking.map { |i| i[:message] }.join("; ") if blocking.any?
      raise NotReady, "no accepted codes" if code_proposals.accepted.none?
      update!(status: "finalized", finalized_at: Time.current, finalized_by: by,
              claim_number: format("CLM-%06d", id))
      events.create!(actor: by, action: "encounter.finalized",
                     payload: { claim_number: claim_number,
                                dx: accepted_dx.map(&:code), px: accepted_px.map { |p| [p.code, p.modifiers].reject(&:blank?).join("-") } })
    end
    self
  end

  # Evidence highlighting: which accepted/proposed quotes appear where in the note.
  def evidence_spans
    code_proposals.where(grounded: true).where.not(state: "rejected").filter_map do |p|
      i = note.downcase.index(p.evidence.downcase.strip)
      i && { start: i, len: p.evidence.strip.length, code: p.code, kind: p.kind, state: p.state }
    end.sort_by { |s| s[:start] }
  end
end
