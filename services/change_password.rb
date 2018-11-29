# frozen_string_literal: true

module Waterious
  # Edit request
  class ChangePassword
    def self.call(email:, edit_data:)
      account = Account.first(email: email)
      account.update(edit_data)
    end
  end
end
