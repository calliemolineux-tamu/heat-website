# frozen_string_literal: true

require 'rails_helper'

RSpec.describe EventSeriesBuilder do
  let(:base_attributes) do
    {
      name: 'Weekly Meeting',
      location: 'MSC',
      description: 'General body meeting',
      start_time: Time.zone.parse('2026-08-10 18:00'),
      end_time: Time.zone.parse('2026-08-10 19:00')
    }
  end

  describe '#build' do
    it 'builds the requested number of weekly occurrences' do
      events = described_class.new(base_attributes:, frequency: 'weekly', count: 3).build

      expect(events.size).to eq(3)
      expect(events.map { |e| e.start_time.to_date }).to eq(
        [Date.new(2026, 8, 10), Date.new(2026, 8, 17), Date.new(2026, 8, 24)]
      )
    end

    it 'builds monthly occurrences' do
      events = described_class.new(base_attributes:, frequency: 'monthly', count: 3).build

      expect(events.map { |e| e.start_time.to_date }).to eq(
        [Date.new(2026, 8, 10), Date.new(2026, 9, 10), Date.new(2026, 10, 10)]
      )
    end

    it 'shares a single series_id across all occurrences and increments series_position' do
      events = described_class.new(base_attributes:, frequency: 'weekly', count: 4).build

      expect(events.map(&:series_id).uniq.size).to eq(1)
      expect(events.map(&:series_position)).to eq([1, 2, 3, 4])
    end

    it 'stops at an explicit until_date instead of the requested count' do
      events = described_class.new(
        base_attributes:, frequency: 'weekly', count: 52, until_date: '2026-08-20'
      ).build

      expect(events.size).to eq(2) # Aug 10 and Aug 17; Aug 24 is past the until_date
    end

    it 'defaults to 4 occurrences when neither count nor until_date is given' do
      events = described_class.new(base_attributes:, frequency: 'weekly').build

      expect(events.size).to eq(4)
    end

    it 'caps occurrences at 52 even if a larger count is requested' do
      events = described_class.new(base_attributes:, frequency: 'weekly', count: 200).build

      expect(events.size).to eq(52)
    end

    it 'preserves each occurrence\'s duration' do
      events = described_class.new(base_attributes:, frequency: 'weekly', count: 2).build

      expect(events.map { |e| e.end_time - e.start_time }).to all(eq(1.hour))
    end

    it 'builds valid, independent Event records' do
      events = described_class.new(base_attributes:, frequency: 'weekly', count: 3).build

      expect(events).to all(be_a(Event))
      expect(events).to all(be_valid)
    end
  end
end
