# frozen_string_literal: true

require 'json'
require 'sequel'

module Waterious
  # Models a secret request
  class Gone < Sequel::Model
    many_to_one :summary

    plugin :timestamps
    plugin :whitelist_security

    set_allowed_columns :victim

    def to_h
      {
        type: 'gone',
        id: id,
        victim: victim,
        created_at: created_at,
        updated_at: updated_at,
        summary: summary
      }
    end

    def to_json(options = {})
      JSON(to_h, options)
    end
  end
end
