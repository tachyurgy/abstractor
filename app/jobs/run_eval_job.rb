class RunEvalJob < ApplicationJob
  queue_as :default
  def perform = EvalHarness.run!
end
