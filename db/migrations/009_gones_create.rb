# frozen_string_literal: true

require 'sequel'

Sequel.migration do
  change do
    create_table(:gones) do
      primary_key :id
      foreign_key :summary_id, table: :summaries

      String :victim, null: true
      DateTime :created_at
      DateTime :updated_at

      # unique [:project_id, :relative_path, :filename]
    end
  end
end
