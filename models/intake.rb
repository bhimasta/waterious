# frozen_string_literal: true

require 'json'
require 'sequel'

module Waterious
  # Models a secret request
  class Intake < Sequel::Model
    many_to_one :summary

    plugin :timestamps
    plugin :whitelist_security

    set_allowed_columns :summary_id, :amount_intake,
                        :current_hydration, :notification

    def to_h
      {
        type: 'intake',
        id: id,
        amount_intake: amount_intake,
        current_hydration: current_hydration,
        notification: notification,
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
