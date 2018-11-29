# frozen_string_literal: true

require_relative 'summary'

module Waterious
  # Behaviors of the currently logged in account
  class Summaries
    attr_reader :all

    def initialize(summaries_list, account)
      @all = summaries_list.map do |summary|
        policy = SummaryPolicy.new(account, summary)
        Summary.first(id: summary.id)
               .full_details
               .merge(policies: policy.summary)
      end
    end

    def to_json(options = {})
      JSON(@all, options)
    end
  end
end
