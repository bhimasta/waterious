# frozen_string_literal: true

require_relative 'gone'

module Waterious
  # Behaviors of the currently logged in account
  class Gones
    attr_reader :all

    def initialize(gone_list)
      @all = gone_list.map do |gone|
        Gone.first(id: gone.id)
      end
    end

    def to_json(options = {})
      JSON(@all, options)
    end
  end
end
