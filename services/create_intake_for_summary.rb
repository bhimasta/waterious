# frozen_string_literal: true

module Waterious
  # Create new request for a project
  class CreateIntakeForSummary
    def self.call(summary_id:, intake_data:)
      Summary.first(id: summary_id)
             .add_intake(intake_data)
    end
  end
end
