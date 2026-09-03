# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Photo, type: :model do
  subject(:photo) do
    described_class.new(
      title: 'Sample Photo',
      description: 'This is a sample photo description',
      image:,
      user:
    )
  end

  let(:user) { create(:user) }
  let(:image) { File.open(Rails.root.join('spec/fixtures/sample.jpg')) }

  describe 'validations' do
    context 'with valid attributes' do
      it 'is valid' do
        expect(photo).to be_valid
      end
    end

    context 'without a title' do
      before do
        photo.title = nil
      end

      it 'is not valid' do
        expect(photo).not_to be_valid
      end

      it 'adds an error for title' do
        photo.validate
        expect(photo.errors[:title]).to include("can't be blank")
      end
    end

    context 'without a description' do
      before do
        photo.description = nil
      end

      it 'is not valid' do
        expect(photo).not_to be_valid
      end

      it 'adds an error for description' do
        photo.validate
        expect(photo.errors[:description]).to include("can't be blank")
      end
    end

    context 'without an image' do
      before do
        photo.image = nil
      end

      it 'is not valid' do
        expect(photo).not_to be_valid
      end

      it 'adds an error for image' do
        photo.validate
        expect(photo.errors[:image]).to include("can't be blank")
      end
    end

    context 'without a user' do
      before do
        photo.user = nil
      end

      it 'is not valid' do
        expect(photo).not_to be_valid
      end

      it 'adds an error for user' do
        photo.validate
        expect(photo.errors[:user]).to include('must exist')
      end
    end
  end

  describe 'tagging' do
    subject(:saved_photo) { create(:photo) }

    describe '#sync_tags' do
      it 'adds rows for newly checked tags' do
        saved_photo.sync_tags(%w[in_action social_events])
        expect(saved_photo.photo_tags.reload.map(&:tag)).to contain_exactly('in_action', 'social_events')
      end

      it 'removes rows for unchecked tags' do
        saved_photo.sync_tags(%w[in_action social_events])
        saved_photo.sync_tags(%w[in_action])
        expect(saved_photo.photo_tags.reload.map(&:tag)).to contain_exactly('in_action')
      end

      it 'clears all tags when given an empty list' do
        saved_photo.sync_tags(%w[in_action])
        saved_photo.sync_tags([])
        expect(saved_photo.photo_tags.reload).to be_empty
      end

      it 'ignores unknown tag keys' do
        saved_photo.sync_tags(%w[in_action bogus])
        expect(saved_photo.photo_tags.reload.map(&:tag)).to contain_exactly('in_action')
      end

      it 'leaves the created_at of a tag that stays checked untouched' do
        saved_photo.sync_tags(%w[in_action])
        original = saved_photo.photo_tags.find_by(tag: :in_action).created_at

        travel_to(1.hour.from_now) { saved_photo.sync_tags(%w[in_action social_events]) }

        expect(saved_photo.photo_tags.find_by(tag: :in_action).created_at).to eq(original)
      end

      it 're-tags with a fresh timestamp when a removed tag is checked again' do
        saved_photo.sync_tags(%w[in_action])
        original = saved_photo.photo_tags.find_by(tag: :in_action).created_at
        saved_photo.sync_tags([])

        travel_to(1.hour.from_now) { saved_photo.sync_tags(%w[in_action]) }

        expect(saved_photo.photo_tags.find_by(tag: :in_action).created_at).to be > original
      end
    end

    describe '.for_carousel' do
      it 'returns only photos carrying the tag' do
        tagged = create(:photo)
        tagged.sync_tags(%w[in_action])
        create(:photo).sync_tags(%w[social_events])

        expect(Photo.for_carousel('in_action')).to contain_exactly(tagged)
      end

      it 'orders by when the tag was applied, newest first' do
        old_photo = create(:photo)
        new_photo = create(:photo)
        travel_to(2.hours.ago) { new_photo.sync_tags(%w[in_action]) }
        travel_to(1.hour.ago)  { old_photo.sync_tags(%w[in_action]) }

        expect(Photo.for_carousel('in_action').to_a).to eq([old_photo, new_photo])
      end
    end
  end
end
