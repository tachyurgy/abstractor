require "test_helper"

class EncounterTest < ActiveSupport::TestCase
  def ready_encounter
    e = encounter("Hand laceration")
    e.code_proposals.create!(kind: "dx", code: "S61.411A", description: "x", source: "human", state: "accepted", grounded: true, confidence: 100)
    e.code_proposals.create!(kind: "px", code: "12001", description: "x", source: "human", state: "accepted", grounded: true, confidence: 100)
    e
  end

  test "finalize refuses while a blocking issue exists and succeeds once it is resolved" do
    e = ready_encounter
    e.code_proposals.create!(kind: "dx", code: "R50.9", description: "x", source: "rules", state: "proposed", confidence: 50)
    assert_raises(Encounter::NotReady) { e.finalize!(by: "sam") }
    e.code_proposals.find_by!(code: "R50.9").review!(state: "rejected", by: "sam")
    e.finalize!(by: "sam")
    assert e.reload.finalized?
    assert_match(/\ACLM-\d{6}\z/, e.claim_number)
    assert_equal 1, e.events.where(action: "encounter.finalized").count
  end

  test "finalize is exactly-once under concurrent finalizers" do
    e = ready_encounter
    results = Array.new(8)
    threads = 8.times.map do |i|
      Thread.new do
        ActiveRecord::Base.connection_pool.with_connection do
          results[i] = begin
            Encounter.find(e.id).finalize!(by: "coder-#{i}"); :ok
          rescue Encounter::Finalized then :already
          end
        end
      end
    end
    threads.each(&:join)
    assert_equal 1, results.count(:ok), results.inspect
    assert_equal 7, results.count(:already)
    assert_equal 1, Event.where(encounter_id: e.id, action: "encounter.finalized").count
    assert_equal 1, Encounter.where(claim_number: e.reload.claim_number).count
  end

  test "reviews are refused after finalize and the event log is append-only" do
    e = ready_encounter
    e.finalize!(by: "sam")
    p = e.code_proposals.first
    assert_raises(Encounter::Finalized) { p.review!(state: "rejected", by: "sam") }
    ev = e.events.first
    assert_raises(ActiveRecord::ReadOnlyRecord) { ev.update!(actor: "x") }
    assert_not ev.destroy
  end

  test "evidence spans resolve only grounded, non-rejected quotes" do
    e = encounter("Right knee")
    CodingAgent.run!(e, coder: Coders::RuleCoder.new)
    spans = e.evidence_spans
    assert spans.any?
    assert spans.all? { |s| e.note.downcase[s[:start], s[:len]] == e.code_proposals.find_by(code: s[:code]).evidence.downcase }
    e.code_proposals.update_all(state: "rejected")
    assert_empty e.reload.evidence_spans
  end
end
