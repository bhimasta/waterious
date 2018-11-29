# frozen_string_literal: true

module Waterious
  # Create new token for a user
  class CreateSummaryForUser
    def self.call(owner_id:, summary_data:)
      Account.first(id: owner_id)
             .add_owned_summary(summary_data)
    end
  end
end
