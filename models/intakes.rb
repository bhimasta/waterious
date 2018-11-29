# frozen_string_literal: true

require_relative 'intake'

module Waterious
  # Behaviors of the currently logged in account
  class Intakes
    attr_reader :all

    def initialize(intake_list)
      @all = intake_list.map do |intake|
        Intake.first(id: intake.id)
      end
    end

    def to_json(options = {})
      JSON(@all, options)
    end
  end
end
