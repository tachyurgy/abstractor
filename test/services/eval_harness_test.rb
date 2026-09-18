require "test_helper"

class EvalHarnessTest < ActiveSupport::TestCase
  class Fixed
    def name = "fixed"
    def propose(note)
      # Right on the first case only, and one wrong extra code everywhere.
      out = [{ kind: "dx", code: "R51.9", description: "x", rationale: "r", evidence: "not in note", confidence: 50 }]
      out << { kind: "dx", code: "E11.9", description: "x", rationale: "r", evidence: "type 2 diabetes", confidence: 90 } if note.include?("type 2 diabetes, hypertension and hyperlipidemia")
      out
    end
  end

  test "precision, recall, f1 and grounded are computed on the code set" do
    r = EvalHarness.run!(coder: Fixed.new)
    gold_total = EvalCase.sum { |c| c.gold_dx.size + c.gold_px.size }
    assert_equal 16, r.n_cases
    assert_equal 1, r.tp
    assert_equal 16, r.fp           # one wrong extra per case
    assert_equal gold_total - 1, r.fn
    assert_in_delta 1.0 / 17, r.precision, 0.0001
    assert_in_delta 1.0 / gold_total, r.recall, 0.0001
    assert_in_delta 1.0 / 17, r.grounded_pct, 0.0001   # only the one true quote is grounded
    assert_equal "fixed", r.coder
  end

  test "the rules baseline has full recall on the labelled set" do
    r = EvalHarness.run!(coder: Coders::RuleCoder.new)
    assert_equal 1.0, r.recall.to_f
    assert r.precision.to_f < 1.0, "the baseline is supposed to over-code; if it is perfect the eval is not discriminating"
  end
end
