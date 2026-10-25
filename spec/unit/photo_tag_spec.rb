# frozen_string_literal: true

require 'rails_helper'

RSpec.describe PhotoTag, type: :model do
  let(:photo) { create(:photo) }

  it 'defines the three fixed carousel tags' do
    expect(described_class.tags.keys).to contain_exactly('recent_activities', 'in_action', 'social_events')
  end

  it 'requires a tag' do
    expect(described_class.new(photo:, tag: nil)).not_to be_valid
  end

  it 'is unique per photo + tag' do
    create(:photo_tag, photo:, tag: :in_action)
    dup = described_class.new(photo:, tag: :in_action)
    expect(dup).not_to be_valid
  end

  it 'allows the same tag on different photos' do
    create(:photo_tag, photo:, tag: :in_action)
    expect(build(:photo_tag, photo: create(:photo), tag: :in_action)).to be_valid
  end

  it 'allows different tags on the same photo' do
    create(:photo_tag, photo:, tag: :in_action)
    expect(build(:photo_tag, photo:, tag: :social_events)).to be_valid
  end
end
