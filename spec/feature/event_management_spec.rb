# frozen_string_literal: true

require 'rails_helper'
require 'capybara/rspec'
require 'selenium/webdriver'

RSpec.feature 'Event Management', type: :feature do
  let!(:admin_user) do
    create(:user, email: 'admin@example.com', full_name: 'Admin User', role: 'admin')
  end
  let!(:event) { create(:event, name: 'Test Event', location: 'Test Location') }

  before do
    Capybara.current_driver = :selenium_chrome_headless
  end

  context 'when managing events' do
    before do
      login_as(admin_user, scope: :user)
      visit events_path
    end

    # Split 'view events page' scenario into two separate scenarios

    scenario 'displays the EVENTS heading' do
      expect(page).to have_content('EVENTS')
    end

    scenario 'displays existing events' do
      expect(page).to have_content('Test Event')
    end

    scenario 'create a new event with valid data' do
      click_on 'Create New Event'
      create_event('New Event', '2024-10-28 10:00', '2024-10-28 12:00', 'New Location', 'This is a description.')
      expect_event_creation_success('New Event')
    end

    scenario 'fail to create a new event with blank name' do
      click_on 'Create New Event'
      create_event('', '2024-10-28 10:00', '2024-10-28 12:00', 'Location', 'Description')
      expect_blank_event_name_error
    end

    scenario 'edit an existing event with valid data' do
      visit event_path(event)
      click_on 'Edit Event'
      update_event('Updated Event', 'Updated Location', 'Updated Description')
      expect_event_update_success('Updated Event')
    end

    scenario 'delete an event', :js do
      visit event_path(event)
      accept_confirm do
        click_on 'Delete Event'
      end
      expect_event_deletion_success('Test Event')
    end
  end

  # Helper methods

  # "Create New Event" now opens the quick-add form inline (in a modal on the events
  # index, via a Turbo Frame) instead of navigating to a separate page, and the
  # start/end time fields are a single flatpickr-enhanced text input rather than
  # Rails' multi-select datetime_select widgets.
  def create_event(name, start_time, end_time, location, description)
    fill_in 'Name', with: name
    fill_in_datetime('event_start_time', start_time)
    fill_in_datetime('event_end_time', end_time)
    fill_in 'Location', with: location
    fill_in 'Description', with: description
    click_button 'Submit'
  end

  # Sets a flatpickr-enhanced field's value via flatpickr's own JS API rather than
  # driving the calendar popup through the UI, which is the standard reliable way
  # to fill these fields in a Capybara/Selenium test.
  def fill_in_datetime(field_id, value)
    formatted = DateTime.parse(value).strftime('%Y-%m-%d %H:%M')
    page.execute_script(<<~JS)
      (function() {
        var el = document.getElementById('#{field_id}');
        if (el && el._flatpickr) {
          el._flatpickr.setDate('#{formatted}', true);
        } else if (el) {
          el.value = '#{formatted}';
          el.dispatchEvent(new Event('input'));
          el.dispatchEvent(new Event('change'));
        }
      })();
    JS
  end

  def update_event(name, location, description)
    fill_in 'Name', with: name
    fill_in 'Location', with: location
    fill_in 'Description', with: description
    expect(page).to have_button('Submit', disabled: false, wait: 5)
    click_button 'Submit'
  end

  # Successful creation now stays on the events index (created inline via Turbo
  # Stream) instead of redirecting to the new event's show page.
  def expect_event_creation_success(event_name)
    expect(page).to have_content('Event created')
    expect(page).to have_content(event_name)
  end

  def expect_blank_event_name_error
    expect(page).to have_content("Name can't be blank")
  end

  def expect_event_update_success(event_name)
    expect(page).to have_content(event_name.upcase)
  end

  def expect_event_deletion_success(event_name)
    expect(page).not_to have_content(event_name)
    expect(page).to have_content('Event was successfully deleted.')
  end
end
