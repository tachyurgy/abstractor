module Coders
  # Deterministic baseline: a code is proposed when one of its vocabulary phrases appears
  # in the note. The phrase it matched IS the evidence, so it is grounded by construction.
  # It exists so the app runs with no API key, and so the eval harness has a floor the
  # model has to beat.
  class RuleCoder
    NAME = "rules".freeze
    def name = NAME

    def propose(note)
      text = note.downcase
      CodeSet.where(billable: true).order(:kind, :code).filter_map do |cs|
        hit = cs.keyword_list.find { |kw| text.match?(/(?<![a-z0-9])#{Regexp.escape(kw.downcase)}(?![a-z0-9])/) }
        next unless hit
        start = text.index(/(?<![a-z0-9])#{Regexp.escape(hit.downcase)}(?![a-z0-9])/)
        { kind: cs.kind, code: cs.code, description: cs.description,
          rationale: "Vocabulary match on \"#{hit}\".",
          evidence: note[start, hit.length], confidence: 55 }
      end
    end
  end
end
