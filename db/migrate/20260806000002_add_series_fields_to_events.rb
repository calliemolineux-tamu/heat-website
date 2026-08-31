# frozen_string_literal: true

# Add fields to support recurring event series
class AddSeriesFieldsToEvents < ActiveRecord::Migration[7.0]
  def change
    add_column :events, :series_id, :string
    add_column :events, :series_position, :integer
    add_column :events, :recurrence_note, :string
    add_index :events, :series_id
  end
end
