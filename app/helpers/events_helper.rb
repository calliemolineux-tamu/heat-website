# frozen_string_literal: true

# Helper methods for the Events controller
module EventsHelper
  def create_link_for(role)
    links = { name: 'Create New Event', path: new_event_path, class: 'btn btn--primary event__new' }
    links if role == 'admin'
  end
end
