# frozen_string_literal: true

# AddPointsToEvents
class AddPointsToEvents < ActiveRecord::Migration[7.0]
  def up
    add_column :events, :points, :integer

    Event.reset_column_information
    Event.find_each { |event| event.update_column(:points, default_points_for(event)) }
  end

  def down
    remove_column :events, :points
  end

  private

  def default_points_for(event)
    return 1 if event.committee == 'general'
    return 1 unless event.start_time.present? && event.end_time.present?

    hours = (event.end_time - event.start_time) / 3600.0
    [hours.round, 1].max
  end
end
