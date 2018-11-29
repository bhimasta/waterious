# frozen_string_literal: true

module Waterious
  # Policy to determine if account can view a project
  class SummaryPolicy
    # Scope of project policies
    class AccountScope
      def initialize(current_account, target_account = nil)
        target_account ||= current_account
        @full_scope = all_summaries(target_account)
        @current_account = current_account
        @target_account = target_account
      end

      def viewable
        @full_scope if @current_account == @target_account
      end

      private

      def all_summaries(account)
        account.owned_summaries
      end
    end
  end
end
