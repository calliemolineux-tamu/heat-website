# frozen_string_literal: true

# Drop the archived column - the archive/unarchive feature has been removed.
class RemoveArchivedFromEvents < ActiveRecord::Migration[7.0]
  def change
    remove_column :events, :archived, :boolean, default: false, null: false
  end
end
