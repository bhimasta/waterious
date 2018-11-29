# frozen_string_literal: true

module Waterious
  # Create new request for a project
  class CreateGoneForSummary
    def self.call(summary_id:, gone_data:)
      Summary.first(id: summary_id)
             .add_gone(gone_data)
    end
  end
end
