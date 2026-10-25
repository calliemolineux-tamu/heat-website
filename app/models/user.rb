# frozen_string_literal: true

require 'csv'

# The User class represents users of the application.
# Users can have different roles (admin, member, user) and can have associated photos, attendances, and ideas.
class User < ApplicationRecord
  ROLES = %w[admin member user].freeze

  # Point-totals export for the admins' master spreadsheet. Rows come out in
  # whatever order `users` is already in.
  def self.to_csv(users = all)
    CSV.generate do |csv|
      csv << ['Full Name', 'Email', 'Committee', 'Role', 'Points', 'Dues']
      users.each { |user| csv << [user.full_name, user.email, user.committee, user.role, user.points.to_i, user.dues] }
    end
  end

  validates :role, inclusion: { in: ROLES }
  validates :full_name, presence: true
  validates :email, presence: true, uniqueness: true

  has_many :photos, dependent: :destroy
  has_many :attendances, dependent: :destroy
  has_many :ideas, foreign_key: 'created_by', dependent: :destroy, inverse_of: :user
  # has_many :ideas, dependent: :destroy

  # Ensure devise works with omniauth-google_oauth2
  devise :omniauthable, omniauth_providers: [:google_oauth2]

  # Create or find a user from Google OAuth data
  def self.from_google(email:, full_name:, uid:, avatar_url:)
    create_with(uid:, full_name:, avatar_url:, role: 'user', points: 0).find_or_create_by!(email:)
  end
end
