# frozen_string_literal: true

# Photo
class Photo < ApplicationRecord
  include ImageUploader::Attachment(:image) # Include Shrine uploader

  belongs_to :user
  has_many :photo_tags, dependent: :destroy

  validates :title, presence: true
  validates :description, presence: true
  validates :image, presence: true

  # Tag key => human label. Fixed set, mirrors the three home-page carousels.
  TAG_OPTIONS = {
    'recent_activities' => 'Recent Activities',
    'in_action' => 'In Action',
    'social_events' => 'Social Events'
  }.freeze

  # Photos carrying `tag`, most recently tagged first - ordered by when the tag
  # was applied (photo_tags.created_at), not when the photo was uploaded.
  scope :for_carousel, lambda { |tag|
    joins(:photo_tags)
      .where(photo_tags: { tag: PhotoTag.tags.fetch(tag.to_s) })
      .order('photo_tags.created_at DESC')
  }

  # Current tag keys - used to pre-check the form checkboxes.
  def tag_names
    photo_tags.map(&:tag)
  end

  # Reconcile this photo's tags with `names` (tag keys). Rows for tags that stay
  # checked are left untouched, so their created_at - their position in the
  # carousel ordering - survives unrelated edits. Re-checking a removed tag makes
  # a fresh row, which correctly moves it to the front of the wheel.
  def sync_tags(names)
    wanted = Array(names).map(&:to_s) & PhotoTag.tags.keys
    photo_tags.each { |photo_tag| photo_tag.destroy unless wanted.include?(photo_tag.tag) }
    (wanted - photo_tags.reload.map(&:tag)).each { |name| photo_tags.create!(tag: name) }
  end
end
