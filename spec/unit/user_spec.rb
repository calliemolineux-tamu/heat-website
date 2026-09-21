# frozen_string_literal: true

# location: spec/unit/users/unit_spec.rb
require 'rails_helper'

RSpec.describe User, type: :model do
  subject(:user) do
    described_class.new(email: 'testemail@test.com', full_name: 'Test Name')
  end

  context 'with valid attributes' do
    it 'is valid' do
      user.full_name = 'Test Name'
      user.role = 'admin'
      expect(user).to be_valid
    end

    it 'has the correct full name' do
      user.full_name = 'Test Name'
      expect(user.full_name).to eq('Test Name')
    end
  end

  it 'is not valid without a name' do
    user.full_name = nil
    expect(user).not_to be_valid
  end

  describe '.to_csv' do
    it 'has a header row followed by one row per user, in the given order' do
      bob = create(:user, full_name: 'Bob', committee: 'Env', role: 'member', points: 7, dues: '$25')
      ann = create(:user, full_name: 'Ann', committee: 'Animal', role: 'admin', points: 3)

      rows = CSV.parse(described_class.to_csv([bob, ann]))

      expect(rows[0]).to eq(['Full Name', 'Email', 'Committee', 'Role', 'Points', 'Dues'])
      expect(rows[1]).to eq([bob.full_name, bob.email, 'Env', 'member', '7', '$25'])
      expect(rows[2][0]).to eq('Ann')
    end

    it 'renders a nil points value as 0' do
      user = create(:user, full_name: 'Nopoints', points: nil)
      row = CSV.parse(described_class.to_csv([user]))[1]
      expect(row[4]).to eq('0')
    end
  end
end
