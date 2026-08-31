# frozen_string_literal: true

# Controller for managing events, including CRUD operations and attendance tracking.
class EventsController < ApplicationController
  helper EventsHelper
  include ActionView::RecordIdentifier

  before_action :set_event, only: %i[show edit update destroy]
  before_action :set_user, :role, :set_navbar_variables
  before_action :authenticate_admin!, only: %i[new create edit update destroy]

  # Display all events
  def index
    start_date = parse_start_date(params[:start_date])
    end_date = start_date.end_of_month

    @events = Event.where(start_time: start_date..end_date).order(:start_time)
  end

  # Show a single event
  def show
    @attendances = Attendance.where(event: @event)
    @series_events = Event.in_series(@event.series_id) if @event.series_id.present?
  end

  # Initialize a new event object, optionally prefilled from a calendar day click
  def new
    @event = Event.new(start_time: prefill_start_time)
    respond_to do |format|
      format.turbo_stream
      format.html
    end
  end

  # Edit an existing event
  def edit; end

  # Create a new event (or a recurring series of events) in the database
  def create
    if repeat_requested?
      create_series
    else
      create_single
    end
  end

  # Update an event in the database
  def update
    if @event.update(event_params)
      redirect_to @event, notice: 'Event was successfully updated.'
    else
      render :edit, status: :unprocessable_entity
    end
  end

  # Delete an event
  def destroy
    if @event.destroy
      redirect_to events_path, notice: 'Event was successfully deleted.'
    else
      redirect_to @event, alert: 'Error deleting event.'
    end
  end

  private

  # Parse the start date from parameters or default to the current month.
  def parse_start_date(start_date_param)
    if start_date_param.present?
      Time.zone.parse(start_date_param).beginning_of_month
    else
      Time.zone.today.beginning_of_month
    end
  end

  # Find event by ID for show, edit, update, and destroy actions
  def set_event
    @event = Event.find_by(id: params[:id])
  end

  # Strong parameters to prevent mass assignment issues
  def event_params
    params.require(:event).permit(:name, :passcode, :start_time, :end_time, :location, :description, :flyer_image)
  end

  # When a calendar day's "+" quick-add link is clicked, prefill the new event's start time
  # to noon on that day.
  def prefill_start_time
    return nil if params[:start_date].blank?

    Date.parse(params[:start_date]).noon
  rescue ArgumentError
    nil
  end

  def repeat_requested?
    params.dig(:event, :repeat) == '1'
  end

  # Recurrence controls (frequency/occurrence_count/recurrence_end_date) are read separately
  # from event_params so they're never mass-assigned onto Event directly.
  def recurrence_attributes
    params.require(:event).permit(:frequency, :occurrence_count, :recurrence_end_date)
  end

  def create_single
    @event = Event.new(event_params)

    respond_to do |format|
      if @event.save
        format.html { redirect_to @event, notice: 'Event was successfully created.' }
        format.turbo_stream do
          flash.now[:notice] = 'Event was successfully created.'
          load_calendar_month_for(@event)
        end
      else
        format.html { render :new, status: :unprocessable_entity }
        format.turbo_stream { render :new, status: :unprocessable_entity }
      end
    end
  end

  def create_series
    attributes = event_params.to_h
    flyer_image = attributes.delete(:flyer_image) # only attach the flyer to the first occurrence

    events = EventSeriesBuilder.new(
      base_attributes: attributes,
      frequency: recurrence_attributes[:frequency],
      count: recurrence_attributes[:occurrence_count].presence&.to_i,
      until_date: recurrence_attributes[:recurrence_end_date].presence
    ).build

    events.first.flyer_image = flyer_image if flyer_image.present?
    Event.transaction { events.each(&:save!) }
    @event = events.first

    respond_to do |format|
      format.html { redirect_to @event, notice: "#{events.size} recurring events were successfully created." }
      format.turbo_stream do
        flash.now[:notice] = "#{events.size} recurring events were successfully created."
        load_calendar_month_for(@event)
      end
    end
  rescue ActiveRecord::RecordInvalid => e
    @event = e.record
    respond_to do |format|
      format.html { render :new, status: :unprocessable_entity }
      format.turbo_stream { render :new, status: :unprocessable_entity }
    end
  end

  # Loads @events for the month containing the given event, for re-rendering the calendar
  # panel and event list after an inline create.
  def load_calendar_month_for(event)
    start_date = event.start_time.to_date.beginning_of_month
    end_date = start_date.end_of_month
    @events = Event.where(start_time: start_date..end_date).order(:start_time)
    render :create
  end
end
