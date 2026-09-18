class EncountersController < ApplicationController
  def index
    @encounters = Encounter.worklist.includes(:code_proposals)
    @coder = CodingAgent.coder.name
  end

  def show
    @encounter = Encounter.includes(:code_proposals, :events).find(params[:id])
    @issues = @encounter.issues
  end

  def new = @encounter = Encounter.new(date_of_service: Date.current, provider: "Dr. Okafor")

  def create
    @encounter = Encounter.new(params.require(:encounter).permit(:patient_ref, :provider, :date_of_service, :note))
    if @encounter.save
      @encounter.events.create!(actor: current_coder, action: "encounter.created", payload: {})
      redirect_to @encounter, notice: "Encounter created. Run the coding agent when ready."
    else
      render :new, status: :unprocessable_entity
    end
  end

  def code
    e = Encounter.find(params[:id])
    e.events.create!(actor: current_coder, action: "agent.requested", payload: { coder: CodingAgent.coder.name })
    CodeEncounterJob.perform_later(e.id)
    redirect_to e, notice: "Coding agent queued (#{CodingAgent.coder.name}). Proposals stream in as they land."
  end

  def finalize
    e = Encounter.find(params[:id])
    e.finalize!(by: current_coder)
    redirect_to e, notice: "Finalized as #{e.claim_number}."
  rescue Encounter::Finalized, Encounter::NotReady => ex
    redirect_to e, alert: "Not finalized: #{ex.message}"
  end
end
