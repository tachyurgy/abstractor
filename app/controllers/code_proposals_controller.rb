class CodeProposalsController < ApplicationController
  def create
    e = Encounter.find(params[:encounter_id])
    p = params.require(:code_proposal).permit(:kind, :code, :evidence, :modifiers)
    cs = CodeSet.lookup(p[:kind], p[:code])
    if cs.nil?
      return redirect_to e, alert: "#{p[:code]} is not in the code dictionary"
    end
    row = e.code_proposals.create!(kind: cs.kind, code: cs.code, description: cs.description,
                                   rationale: "Added by #{current_coder}.", evidence: p[:evidence].to_s,
                                   grounded: CodingAgent.ground?(e.note, p[:evidence]), confidence: 100,
                                   source: "human", state: "accepted", modifiers: p[:modifiers].to_s,
                                   reviewed_by: current_coder, reviewed_at: Time.current, position: 99)
    e.events.create!(actor: current_coder, action: "proposal.added", payload: { kind: row.kind, code: row.code })
    e.touch
    redirect_to e
  rescue ActiveRecord::RecordInvalid => ex
    redirect_to e, alert: ex.message
  end

  def accept = review("accepted")
  def reject = review("rejected")
  def reopen = review("proposed")

  private

  def review(state)
    p = CodeProposal.find(params[:id])
    p.review!(state: state, by: current_coder, modifiers: params[:modifiers])
    p.encounter.touch   # refresh the worklist + issues panel for every open tab
    respond_to do |f|
      f.turbo_stream { render turbo_stream: [turbo_stream.replace(p, partial: "code_proposals/proposal", locals: { proposal: p }),
                                             turbo_stream.replace("issues", partial: "encounters/issues", locals: { encounter: p.encounter.reload })] }
      f.html { redirect_to p.encounter }
    end
  rescue Encounter::Finalized => ex
    redirect_to p.encounter, alert: ex.message
  end
end
