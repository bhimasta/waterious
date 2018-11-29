# frozen_string_literal: true

require 'sequel'

Sequel.migration do
  change do
    create_table(:summaries) do
      primary_key :id
      foreign_key :owner_id, :accounts

      Date :date_start, null: false
      Integer :living_object, null: false # 1 => Human # 2 => Animal # 3 => Plant
      Integer :current_hydration, null: false, default: 400
      Integer :total_intakes, null: false, default: 0
      Integer :total_die, null: false, default: 0

      DateTime :created_at
      DateTime :updated_at
    end
  end
end
