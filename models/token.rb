# frozen_string_literal: true

require 'json'
require 'sequel'

# require_relative account/account

module Waterious
  # Models a token
  class Token < Sequel::Model
    many_to_one :owner, class: :'Waterious::Account'

    plugin :timestamps
    plugin :whitelist_security

    set_allowed_columns :name, :value, :description, :owner_id

    def value
      SecureDB.decrypt(value_secure)
    end

    def value=(plaintext)
      self.value_secure = SecureDB.encrypt(plaintext)
    end

    def to_h
      {
        type: 'token',
        id: id,
        name: name,
        value: value,
        description: description
      }
    end

    def to_json(options = {})
      JSON(to_h, options)
    end

    def full_details
      to_h.merge(
        owner: owner
      )
    end
  end
end
