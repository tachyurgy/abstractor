ENV["RAILS_ENV"] ||= "test"
require_relative "../config/environment"
require "rails/test_help"

module ActiveSupport
  class TestCase
    # Concurrency tests open their own connections; fixtures + transactional tests would hide the race.
    self.use_transactional_tests = false
    setup do
      [Event, CodeProposal, Encounter, EvalRun, EvalCase, Excludes1Rule, CodeSet].each(&:delete_all)
      Kernel.silence_warnings { load Rails.root.join("db/seeds.rb") }
    end

    def encounter(title_match)
      Encounter.find_by!("note like ?", "%#{title_match}%")
    end
  end
end
