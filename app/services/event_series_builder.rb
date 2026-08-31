# frozen_string_literal: true

# Builds a set of unsaved, independent Event records that make up a simple
# recurring series (weekly or monthly), sharing a series_id. Deliberately avoids
# a full RRULE/iCal recurrence model - each occurrence is a plain, independently
# editable Event row.
class EventSeriesBuilder
  FREQUENCIES = %w[weekly monthly].freeze
  DEFAULT_COUNT = 4
  MAX_OCCURRENCES = 52

  def initialize(base_attributes:, frequency:, count: nil, until_date: nil)
    @base_attributes = base_attributes.symbolize_keys
    @frequency = FREQUENCIES.include?(frequency) ? frequency : 'weekly'
    @count = count if count.to_i.positive?
    @until_date = parse_date(until_date)
  end

  # Returns an array of unsaved Event instances sharing a new series_id.
  def build
    series_id = SecureRandom.uuid

    occurrence_start_times.each_with_index.map do |occurrence_start, index|
      Event.new(
        base_attributes.merge(
          start_time: occurrence_start,
          end_time: shifted_end_time(occurrence_start),
          series_id:,
          series_position: index + 1
        )
      )
    end
  end

  private

  attr_reader :base_attributes, :frequency, :count, :until_date

  def parse_date(value)
    return nil if value.blank?

    value.is_a?(Date) ? value : Date.parse(value.to_s)
  rescue ArgumentError
    nil
  end

  def base_start_time
    @base_start_time ||= as_time(base_attributes[:start_time])
  end

  def base_end_time
    @base_end_time ||= as_time(base_attributes[:end_time])
  end

  def as_time(value)
    return value if value.is_a?(Time) || value.is_a?(ActiveSupport::TimeWithZone)
    return nil if value.blank?

    Time.zone.parse(value.to_s)
  end

  def duration
    return 0 unless base_start_time && base_end_time

    base_end_time - base_start_time
  end

  def step
    frequency == 'monthly' ? 1.month : 1.week
  end

  def occurrence_start_times
    return [base_start_time] unless base_start_time

    effective_count = count || (until_date ? MAX_OCCURRENCES : DEFAULT_COUNT)
    times = [base_start_time]

    while times.size < [effective_count, MAX_OCCURRENCES].min
      next_time = times.last + step
      break if until_date && next_time.to_date > until_date

      times << next_time
    end

    times
  end

  def shifted_end_time(occurrence_start)
    return nil unless base_end_time

    occurrence_start + duration
  end
end
