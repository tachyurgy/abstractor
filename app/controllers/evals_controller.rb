class EvalsController < ApplicationController
  def index
    @runs = EvalRun.limit(20)
    @cases = EvalCase.order(:id)
    @coder = CodingAgent.coder.name
  end

  def create
    RunEvalJob.perform_later
    redirect_to evals_path, notice: "Eval queued against #{CodingAgent.coder.name}. Refresh in a moment."
  end
end
