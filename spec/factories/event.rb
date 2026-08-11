# frozen_string_literal: true

# spec/factories/events.rb
FactoryBot.define do
  factory :event do
    name { 'Sample Event' }
    location { 'Sample Location' }
    start_time { DateTime.now + 1.day }
    end_time { DateTime.now + 2.days }
    description { 'This is a sample event description.' }
    passcode { '1234' } # Include this if your Event model requires a passcode
  end
end
