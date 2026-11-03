# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Attendance, type: :model do
  describe '.to_csv' do
    let(:event) { create(:event, name: 'Fall Kickoff') }

    it 'has a header row and one row per attendance' do
      alice = create(:user, full_name: 'Alice', committee: 'Env')
      attendance = create(:attendance, event:, user: alice, checked_in_at: Time.zone.local(2026, 9, 1, 14, 30))

      rows = CSV.parse(described_class.to_csv([attendance], event))

      expect(rows[0]).to eq(['Event', 'Member', 'Email', 'Committee', 'Checked In At'])
      expect(rows[1]).to eq(['Fall Kickoff', 'Alice', alice.email, 'Env', '2026-09-01 14:30'])
    end

    it 'renders a blank Checked In At when checked_in_at is nil' do
      attendance = create(:attendance, event:, user: create(:user), checked_in_at: nil)
      row = CSV.parse(described_class.to_csv([attendance], event))[1]
      expect(row[4]).to be_nil.or eq('')
    end
  end
end
