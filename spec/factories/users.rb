# frozen_string_literal: true

# spec/factory/users.rb
FactoryBot.define do
  factory :user do
    sequence(:email) { |n| "testuser#{n}@example.com" }
    full_name { 'Test User' }
    role { 'admin' }
    committee { 'Test Committee' }
  end
end
