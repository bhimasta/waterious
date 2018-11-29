# frozen_string_literal: true

module Waterious
  # Policy to determine if an account can view a particular project
  class SummaryPolicy
    def initialize(account, summary)
      @account = account
      @summary = summary
    end

    def can_view?
      account_is_owner?
    end

    def can_edit?
      account_is_owner?
    end

    def can_delete?
      account_is_owner?
    end

    def can_add_intakes?
      account_is_owner?
    end

    def can_reduce_intakes?
      account_is_owner?
    end

    def can_edit_intakes?
      account_is_owner?
    end

    def can_remove_intakes?
      account_is_owner?
    end

    def summary
      {
        can_view: can_view?,
        can_edit: can_edit?,
        can_delete: can_delete?,
        can_add_intakes: can_add_intakes?,
        can_reduce_intakes: can_reduce_intakes?,
        can_edit_intakes: can_edit_intakes?,
        can_remove_intakes: can_remove_intakes?
      }
    end

    private

    def account_is_owner?
      @summary.owner == @account
    end
  end
end
