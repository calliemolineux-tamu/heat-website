# frozen_string_literal: true

# Tags a Photo for one of the three fixed home-page carousels. The set of tags is
# closed (it mirrors the carousels), so it's an enum rather than a Tag table.
class PhotoTag < ApplicationRecord
  belongs_to :photo

  enum tag: { recent_activities: 0, in_action: 1, social_events: 2 }

  validates :tag, presence: true, uniqueness: { scope: :photo_id }
end
