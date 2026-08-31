# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Event, type: :model do
  subject(:event) do
    described_class.new(
      name: 'Sample Event',
      location: 'Sample Location',
      start_time: Time.zone.parse('2026-08-10 18:00'),
      end_time: Time.zone.parse('2026-08-10 19:00')
    )
  end

  describe 'validations' do
    it 'is valid with a start_time and end_time' do
      expect(event).to be_valid
    end

    it 'is valid with only a start_time and no end_time' do
      event.end_time = nil
      expect(event).to be_valid
    end

    it 'is not valid without a name' do
      event.name = nil
      expect(event).not_to be_valid
      expect(event.errors[:name]).to include("can't be blank")
    end

    it 'is not valid without a start_time' do
      event.start_time = nil
      expect(event).not_to be_valid
      expect(event.errors[:start_time]).to include("can't be blank")
    end

    it 'is not valid when end_time is before start_time' do
      event.end_time = event.start_time - 1.hour
      expect(event).not_to be_valid
      expect(event.errors[:end_time]).to include('must be after the start time')
    end
  end

  describe 'saving without an end_time' do
    it 'persists with a nil end_time' do
      event.end_time = nil
      event.save!
      expect(event.reload.end_time).to be_nil
    end
  end
end
