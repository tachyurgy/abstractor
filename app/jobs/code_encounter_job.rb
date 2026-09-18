class CodeEncounterJob < ApplicationJob
  queue_as :default
  def perform(encounter_id)
    CodingAgent.run!(Encounter.find(encounter_id))
  rescue StandardError => e
    Encounter.find(encounter_id).events.create!(actor: "agent", action: "agent.failed", payload: { error: "#{e.class}: #{e.message}"[0, 300] })
  end
end
