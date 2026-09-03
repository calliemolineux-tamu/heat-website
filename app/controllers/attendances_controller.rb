# frozen_string_literal: true

# Handles attendance-related actions such as checking in to events.
class AttendancesController < ApplicationController
  before_action :set_event
  before_action :authenticate_admin!, only: :export

  # Creates an attendance record for the current user if the conditions are met.
  def create
    if valid_attendance?
      handle_attendance_creation
    else
      redirect_to @event, alert: 'Invalid passcode or the event is not happening today.'
    end
  end

  # GET /events/:event_id/attendances/export.csv - who signed in to this event.
  def export
    attendances = @event.attendances.includes(:user).sort_by { |attendance| attendance.user.full_name.to_s.downcase }
    send_data Attendance.to_csv(attendances, @event),
              filename: "#{@event.name.parameterize}-signins-#{@event.start_time.to_date.iso8601}.csv",
              type: 'text/csv', disposition: 'attachment'
  end

  private

  # Finds and sets the event instance variable based on the provided event ID.
  def set_event
    @event = Event.find(params[:event_id])
  end

  # Validates the passcode and ensures the event is happening today. Admins can check
  # in without a passcode.
  def valid_attendance?
    (admin_user? || valid_passcode?(params[:passcode])) && event_happening_today?
  end

  # Checks if the entered passcode matches the event's passcode.
  def valid_passcode?(entered_passcode)
    entered_passcode == @event.passcode
  end

  # Checks if the current user is an admin.
  def admin_user?
    current_user&.role == 'admin'
  end

  # Checks if the event is happening on the current date. end_time is optional -
  # an event with no end_time is treated as having no defined upper bound.
  def event_happening_today?
    return false if @event.start_time.to_date > Date.current

    @event.end_time.blank? || @event.end_time.to_date >= Date.current
  end

  # Handles the logic for creating or updating an attendance record.
  def handle_attendance_creation
    attendance = find_or_initialize_attendance

    if attendance.persisted?
      redirect_to @event, alert: 'You have already checked in.'
    elsif save_attendance(attendance)
      update_user_points
      redirect_to @event, notice: 'You have successfully checked in.'
    else
      redirect_to @event, alert: 'Unable to check in.'
    end
  end

  # Finds or initializes an attendance record for the current user.
  def find_or_initialize_attendance
    @event.attendances.find_or_initialize_by(user: current_user).tap do |attendance|
      attendance.assign_attributes(present: true, checked_in_at: Time.current) unless attendance.persisted?
    end
  end

  # Saves the attendance record and returns whether the save was successful.
  def save_attendance(attendance)
    attendance.save
  end

  # Updates the current user's points by incrementing by one.
  def update_user_points
    current_user.update(points: current_user.points.to_i + 1)
  end
end
