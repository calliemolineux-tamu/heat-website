# frozen_string_literal: true

# Event
class Event < ApplicationRecord
  include ImageUploader::Attachment(:flyer_image) # Optional event flyer, via Shrine (same pattern as Photo)

  enum committee: {
    animal: 'animal',
    environmental: 'environmental',
    human: 'human',
    general: 'general'
  }, _prefix: true

  has_many :attendances, dependent: :destroy
  has_many :users, through: :attendances
  validates :name, presence: true
  validates :start_time, presence: true
  validates :points, numericality: { only_integer: true, greater_than: 0 }
  scope :in_series, ->(series_id) { where(series_id:).order(:series_position) }
  before_validation :set_default_points
  before_save :align_end_time_with_start_time
  validate :end_time_after_start_time

  private

  # Only fills in points when blank, so an explicit manual value (including one
  # re-entered on edit) is never overwritten. General-committee events default to
  # 1 point regardless of duration; others default to 1 point per hour between
  # start_time and end_time, rounded to the nearest hour.
  def set_default_points
    return if points.present?

    self.points = committee_general? ? 1 : duration_based_points
  end

  def duration_based_points
    return 1 unless start_time.present? && end_time.present?

    hours = (end_time - start_time) / 3600.0
    [hours.round, 1].max
  end

  def align_end_time_with_start_time
    return unless start_time.present? && end_time.present?

    self.end_time = end_time.change(
      year: start_time.year,
      month: start_time.month,
      day: start_time.day
    )
  end

  # end_time is optional - only validated relative to start_time when both are present.
  def end_time_after_start_time
    return unless start_time.present? && end_time.present?
    return unless end_time < start_time

    errors.add(:end_time, 'must be after the start time')
  end
end
