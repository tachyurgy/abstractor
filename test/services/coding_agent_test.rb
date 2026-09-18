require "test_helper"

class CodingAgentTest < ActiveSupport::TestCase
  class FakeCoder
    def initialize(props) = @props = props
    def name = "fake"
    def propose(_note) = @props
  end

  test "grounding gate: a quote that is not in the note is kept but flagged and confidence halved" do
    e = encounter("Hand laceration")
    CodingAgent.run!(e, coder: FakeCoder.new([
      { kind: "dx", code: "S61.411A", description: "x", rationale: "r", evidence: "laceration to the dorsum of the right hand", confidence: 90 },
      { kind: "dx", code: "S61.412A", description: "x", rationale: "r", evidence: "laceration of the LEFT hand", confidence: 90 }
    ]))
    good = e.code_proposals.find_by!(code: "S61.411A")
    bad  = e.code_proposals.find_by!(code: "S61.412A")
    assert good.grounded? && good.confidence == 90
    assert_not bad.grounded?
    assert_equal 45, bad.confidence
    assert_equal 1, e.events.last.payload["unverified"]
  end

  test "grounding is whitespace and case insensitive but never fuzzy" do
    note = "Closed with 4 simple\n  interrupted sutures."
    assert CodingAgent.ground?(note, "closed with 4 simple interrupted sutures")
    assert_not CodingAgent.ground?(note, "closed with four simple interrupted sutures")
    assert_not CodingAgent.ground?(note, "")
  end

  test "re-running the agent never touches a proposal a human already reviewed" do
    e = encounter("Diabetes and hypertension")
    CodingAgent.run!(e, coder: Coders::RuleCoder.new)
    p = e.code_proposals.find_by!(code: "E11.9")
    p.review!(state: "accepted", by: "sam")
    CodingAgent.run!(e, coder: FakeCoder.new([{ kind: "dx", code: "E11.9", description: "x", rationale: "CHANGED", evidence: "nope", confidence: 1 }]))
    p.reload
    assert_equal "accepted", p.state
    assert_not_equal "CHANGED", p.rationale
    assert p.grounded?
  end

  test "with no API key the rules coder is chosen, and the dictionary rejects unknown codes" do
    key = ENV.delete("GEMINI_API_KEY")
    assert_kind_of Coders::RuleCoder, CodingAgent.coder
    assert_nil CodeSet.lookup("dx", "Z99.999")
  ensure
    ENV["GEMINI_API_KEY"] = key if key
  end

  test "the agent refuses to run on a finalized encounter" do
    e = encounter("Hand laceration")
    CodingAgent.run!(e, coder: Coders::RuleCoder.new)
    e.code_proposals.each { |p| p.review!(state: "accepted", by: "sam") }
    e.finalize!(by: "sam")
    assert_raises(Encounter::Finalized) { CodingAgent.run!(e, coder: Coders::RuleCoder.new) }
  end
end
