class CodeProposal < ApplicationRecord
  STATES = %w[proposed accepted rejected].freeze
  belongs_to :encounter
  validates :kind, inclusion: { in: CodeSet::KINDS }
  validates :code, presence: true, uniqueness: { scope: [:encounter_id, :kind] }
  validates :state, inclusion: { in: STATES }
  validates :confidence, numericality: { in: 0..100 }

  scope :dx, -> { where(kind: "dx") }
  scope :px, -> { where(kind: "px") }
  scope :accepted, -> { where(state: "accepted") }
  scope :open, -> { where(state: "proposed") }

  after_create_commit  { broadcast_append_to encounter, target: "proposals-#{kind}", partial: "code_proposals/proposal", locals: { proposal: self } }
  after_update_commit  { broadcast_replace_to encounter, partial: "code_proposals/proposal", locals: { proposal: self } }

  def code_set = CodeSet.lookup(kind, code)
  def modifier_list = modifiers.split(",").map(&:strip).reject(&:empty?)
  def em? = !!code_set&.em
  def accepted? = state == "accepted"
  def proposed? = state == "proposed"

  def review!(state:, by:, modifiers: nil)
    transaction do
      encounter.lock!
      raise Encounter::Finalized, "encounter is finalized" if encounter.finalized?
      attrs = { state: state, reviewed_by: by, reviewed_at: Time.current }
      attrs[:modifiers] = modifiers if modifiers
      update!(attrs)
      encounter.events.create!(actor: by, action: "proposal.#{state}",
                               payload: { kind: kind, code: code, modifiers: self.modifiers })
    end
  end
end
