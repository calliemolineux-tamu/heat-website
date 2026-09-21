# frozen_string_literal: true

# AddCommitteeToEvents
class AddCommitteeToEvents < ActiveRecord::Migration[7.0]
  def change
    add_column :events, :committee, :string, null: false, default: 'general'
  end
end
