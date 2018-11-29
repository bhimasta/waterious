# frozen_string_literal: true

require 'sequel'

Sequel.migration do
  change do
    create_table(:intakes) do
      primary_key :id
      foreign_key :summary_id, table: :summaries

      Integer :amount_intake, null: false
      Integer :current_hydration, null: false
      Integer :notification, null: false, default: 0

      DateTime :created_at
      DateTime :updated_at

      # unique [:project_id, :relative_path, :filename]
    end
  end
end
