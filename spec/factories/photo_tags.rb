# frozen_string_literal: true

FactoryBot.define do
  factory :photo_tag do
    association :photo
    tag { :in_action }
  end
end
