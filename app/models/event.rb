# frozen_string_literal: true

# Event
class Event < ApplicationRecord
  include ImageUploader::Attachment(:flyer_image) # Optional event flyer, via Shrine (same pattern as Photo)

  has_many :attendances, dependent: :destroy
  has_many :users, through: :attendances
  validates :name, presence: true
  validates :start_time, presence: true
  scope :in_series, ->(series_id) { where(series_id:).order(:series_position) }
  before_save :align_end_time_with_start_time
  validate :end_time_after_start_time

  private

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
