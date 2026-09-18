require "test_helper"

class ClaimValidatorTest < ActiveSupport::TestCase
  def add(e, kind, code, state: "accepted", modifiers: "")
    e.code_proposals.create!(kind: kind, code: code, description: "x", source: "human", state: state,
                             evidence: "", grounded: true, confidence: 100, modifiers: modifiers)
  end
  def rules(e) = e.issues.map { |i| i[:rule] }

  test "excludes1 blocks E11.x with E10.x by prefix" do
    e = encounter("Diabetes and hypertension")
    add(e, "dx", "E11.9"); add(e, "dx", "E10.9")
    issue = e.issues.find { |i| i[:rule] == "excludes1" }
    assert issue, "expected an excludes1 issue"
    assert_equal "block", issue[:severity]
    assert_equal %w[E11.9 E10.9], issue[:codes]
  end

  test "excludes1 blocks F32 with F33 and J06 with J02.0" do
    e = encounter("Depression"); add(e, "dx", "F32.A"); add(e, "dx", "F33.1")
    assert_includes rules(e), "excludes1"
    e2 = encounter("sore throat"); add(e2, "dx", "J06.9"); add(e2, "dx", "J02.0")
    assert_includes rules(e2), "excludes1"
  end

  test "a category header is blocked; the billable subcode is not" do
    e = encounter("Diabetes and hypertension")
    add(e, "dx", "E11")
    assert_includes rules(e), "header-code"
    e.code_proposals.delete_all
    add(e, "dx", "E11.9")
    assert_not_includes rules(e), "header-code"
  end

  test "an E/M with a same-day procedure needs modifier 25" do
    e = encounter("Right knee")
    add(e, "dx", "M17.11"); add(e, "px", "20610"); em = add(e, "px", "99213")
    assert_includes rules(e), "modifier-25"
    em.update!(modifiers: "25")
    assert_not_includes rules(e), "modifier-25"
  end

  test "an E/M alone does not need modifier 25 and two E/Ms are blocked" do
    e = encounter("Depression")
    add(e, "dx", "F33.1"); add(e, "px", "99214")
    assert_not_includes rules(e), "modifier-25"
    add(e, "px", "99213")
    assert_includes rules(e), "multiple-em"
  end

  test "procedures with no diagnosis are blocked, unreviewed proposals are blocked, symptoms next to a definitive dx warn" do
    e = encounter("Hand laceration")
    add(e, "px", "12001")
    assert_includes rules(e), "no-diagnosis"
    add(e, "dx", "S61.411A"); add(e, "dx", "R50.9", state: "proposed")
    assert_includes rules(e), "unreviewed"
    e.code_proposals.find_by!(code: "R50.9").update!(state: "accepted")
    w = e.issues.find { |i| i[:rule] == "symptom-integral" }
    assert w && w[:severity] == "warn"
  end
end
