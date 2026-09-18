# Coding rules that make a claim wrong before a payer ever sees it. Illustrative subset
# of real ICD-10-CM / CPT conventions; each issue names the rule so a coder can dispute it.
#
#   block  - the claim cannot be finalized until resolved
#   warn   - finalizable, but the coder should look
class ClaimValidator
  def initialize(encounter) = @e = encounter

  def issues
    accepted = @e.code_proposals.accepted.to_a
    dx = accepted.select { |p| p.kind == "dx" }
    px = accepted.select { |p| p.kind == "px" }
    out = []

    @e.code_proposals.open.each do |p|
      out << { rule: "unreviewed", severity: "block", codes: [p.code],
               message: "#{p.code} is still unreviewed" }
    end

    dx.each do |p|
      cs = p.code_set
      if cs.nil?
        out << { rule: "unknown-code", severity: "block", codes: [p.code], message: "#{p.code} is not in the code dictionary" }
      elsif !cs.billable
        out << { rule: "header-code", severity: "block", codes: [p.code],
                 message: "#{p.code} is a category header; code to the highest specificity (e.g. #{p.code}.9)" }
      end
    end

    Excludes1Rule.conflicts_among(dx.map(&:code)).each do |c|
      out << { rule: "excludes1", severity: "block", codes: c[:codes],
               message: "#{c[:codes].join(' and ')} cannot be reported together (Excludes1: #{c[:rule].note})" }
    end

    if px.any? && dx.none?
      out << { rule: "no-diagnosis", severity: "block", codes: px.map(&:code),
               message: "Procedure codes need at least one accepted diagnosis to point to" }
    end

    em = px.select(&:em?)
    if em.size > 1
      out << { rule: "multiple-em", severity: "block", codes: em.map(&:code),
               message: "Only one E/M service per encounter" }
    end
    if em.size == 1 && (px - em).any? && !em.first.modifier_list.include?("25")
      out << { rule: "modifier-25", severity: "block", codes: [em.first.code],
               message: "#{em.first.code} billed with a same-day procedure (#{(px - em).map(&:code).join(', ')}) needs modifier 25" }
    end

    symptom = dx.select { |p| p.code.start_with?("R") }
    definitive = dx.reject { |p| p.code.start_with?("R", "Z") }
    if symptom.any? && definitive.any?
      out << { rule: "symptom-integral", severity: "warn", codes: symptom.map(&:code),
               message: "Symptom code(s) #{symptom.map(&:code).join(', ')} alongside a definitive diagnosis: drop them if the symptom is integral to #{definitive.map(&:code).join('/')}" }
    end

    @e.code_proposals.accepted.where(grounded: false).each do |p|
      out << { rule: "unverified-evidence", severity: "warn", codes: [p.code],
               message: "#{p.code} was accepted with a quote the note does not contain" }
    end
    out
  end
end
