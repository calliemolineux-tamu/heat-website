# frozen_string_literal: true

require 'csv'

# Attendance
class Attendance < ApplicationRecord
  belongs_to :event
  belongs_to :user

  validates :user_id, uniqueness: { scope: :event_id, message: 'has already checked into this event' }

  # Sign-in roster export for a single event. The event name is repeated on every
  # row so multiple events can be pasted into one master sheet.
  def self.to_csv(attendances, event)
    CSV.generate do |csv|
      csv << ['Event', 'Member', 'Email', 'Committee', 'Checked In At']
      attendances.each do |attendance|
        csv << [event.name, attendance.user.full_name, attendance.user.email, attendance.user.committee,
                attendance.checked_in_at&.strftime('%Y-%m-%d %H:%M')]
      end
    end
  end
end
