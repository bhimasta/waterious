# frozen_string_literal: true

require 'json'
require 'sequel'

require_relative 'account/account'

module Waterious
  # Models a project
  class Summary < Sequel::Model
    many_to_one :owner, class: :'Waterious::Account'

    one_to_many :intakes
    one_to_many :gones

    plugin :association_dependencies, intakes: :destroy
    plugin :association_dependencies, gones: :destroy

    plugin :timestamps
    plugin :whitelist_security

    set_allowed_columns :date_start, :living_object, :current_hydration,
                        :total_intakes, :total_die, :owner_id

    def to_h
      {
        type: 'summary',
        id: id,
        date_start: date_start,
        living_object: living_object,
        current_hydration: current_hydration,
        total_intakes: total_intakes,
        total_die: total_die,
        created_at: created_at,
        updated_at: updated_at
      }
    end

    def to_json(options = {})
      JSON(to_h, options)
    end

    def full_details
      to_h.merge(
        owner: owner,
        intakes: Intakes.new(intakes),
        gones: Gones.new(gones)
      )
    end
  end
end
