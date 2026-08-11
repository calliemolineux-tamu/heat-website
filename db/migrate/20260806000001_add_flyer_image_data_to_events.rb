# frozen_string_literal: true

# Add Shrine attachment column for an optional event flyer image
class AddFlyerImageDataToEvents < ActiveRecord::Migration[7.0]
  def change
    add_column :events, :flyer_image_data, :text
  end
end
