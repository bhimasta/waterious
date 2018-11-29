# frozen_string_literal: true

module Waterious
  # Edit password
  class EditPassword
    def self.call(new_password:)
      Account.password = (new_password)
    end
  end
end
