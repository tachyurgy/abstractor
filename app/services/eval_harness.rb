# Runs a coder over the labelled cases and scores it on the CODE SET, not on prose.
# A proposal counts as correct only if the exact code is in the gold set. Grounded
# percentage is reported separately because a coder that is right but cannot cite the
# note is a different failure from one that is wrong.
class EvalHarness
  # A coder that fails a case scores zero on it (every gold code becomes a miss) and the
  # error is recorded on the case. One transient failure must not abort a 16-case run.
  RETRIES = 4
  def self.propose_with_retry(coder, note)
    attempts = 0
    begin
      attempts += 1
      [coder.propose(note), nil]
    rescue StandardError => e
      if attempts < RETRIES
        # Free-tier model APIs answer bursts with 429/503; back off instead of failing the case.
        sleep(ENV.fetch("EVAL_BACKOFF", "12").to_f * attempts) unless Rails.env.test?
        retry
      end
      [[], "#{e.class}: #{e.message}"[0, 120].gsub(/\s+/, " ")]
    end
  end

  def self.run!(coder: CodingAgent.coder)
    cases = EvalCase.order(:id).to_a
    tp = fp = fn = 0; grounded = total = 0
    details = cases.map do |c|
      sleep(ENV.fetch("EVAL_PACE", "4").to_f) if coder.is_a?(Coders::GeminiCoder) && !Rails.env.test?
      props, err = propose_with_retry(coder, c.note)
      got  = props.map { |p| "#{p[:kind]}:#{p[:code]}" }.uniq
      gold = c.gold_dx.map { |x| "dx:#{x}" } + c.gold_px.map { |x| "px:#{x}" }
      hit = got & gold
      tp += hit.size; fp += (got - gold).size; fn += (gold - got).size
      g = props.count { |p| CodingAgent.ground?(c.note, p[:evidence]) }
      grounded += g; total += props.size
      { title: c.title, gold: gold, got: got, missed: gold - got, extra: got - gold, grounded: g, proposed: props.size, error: err }
    end
    precision = tp.zero? ? 0.0 : tp.to_f / (tp + fp)
    recall    = tp.zero? ? 0.0 : tp.to_f / (tp + fn)
    f1 = (precision + recall).zero? ? 0.0 : 2 * precision * recall / (precision + recall)
    EvalRun.create!(coder: coder.name, n_cases: cases.size, tp: tp, fp: fp, fn: fn,
                    precision: precision.round(4), recall: recall.round(4), f1: f1.round(4),
                    grounded_pct: (total.zero? ? 0.0 : grounded.to_f / total).round(4),
                    details: details, ran_at: Time.current)
  end
end
