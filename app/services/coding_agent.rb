# Runs a coder against an encounter and writes its proposals as REVIEWABLE rows.
#
# The agent never accepts a code. It proposes; a human coder accepts, rejects or edits;
# the validator decides whether the accepted set can become a claim. Three guarantees
# the reviewer can rely on:
#
#   1. Grounding gate. A proposal's evidence quote is looked up in the note. Found: the
#      row is grounded and the UI highlights it in the note. Not found: the row is kept
#      (so nothing is silently dropped) but flagged unverified with its confidence halved,
#      so a confident hallucination never looks like a confident citation.
#   2. Dictionary gate. Only codes in the code dictionary survive (enforced in the coders).
#   3. Idempotent re-runs. Re-running the agent updates rationale/evidence on codes that
#      are still open and never touches a code a human has already reviewed.
class CodingAgent
  def self.coder
    Coders::GeminiCoder.configured? ? Coders::GeminiCoder.new : Coders::RuleCoder.new
  end

  def self.run!(encounter, coder: self.coder, actor: "agent")
    raise Encounter::Finalized, "encounter is finalized" if encounter.finalized?
    proposals = coder.propose(encounter.note)
    written = 0
    Encounter.transaction do
      proposals.each_with_index do |p, i|
        row = encounter.code_proposals.find_or_initialize_by(kind: p[:kind], code: p[:code])
        next if row.persisted? && !row.proposed?
        grounded = ground?(encounter.note, p[:evidence])
        row.assign_attributes(
          description: p[:description], rationale: p[:rationale], evidence: p[:evidence].to_s.strip,
          grounded: grounded, confidence: grounded ? p[:confidence] : p[:confidence] / 2,
          source: coder.name, position: i)
        row.save!
        written += 1
      end
      encounter.update!(status: "proposed", coder_used: coder.name) unless encounter.finalized?
      encounter.events.create!(actor: actor, action: "agent.proposed",
                               payload: { coder: coder.name, proposed: proposals.size, written: written,
                                          unverified: encounter.code_proposals.where(grounded: false).count })
    end
    encounter
  end

  # Whitespace-insensitive, case-insensitive containment. Anything looser (fuzzy match,
  # "close enough") would let the model cite words the clinician never wrote.
  def self.ground?(note, quote)
    q = quote.to_s.strip.downcase.gsub(/\s+/, " ")
    return false if q.length < 3
    note.to_s.downcase.gsub(/\s+/, " ").include?(q)
  end
end
