# frozen_string_literal: true

# ApplicationController provides the base functionality for all controllers,
# including authentication handling, user role management, and dynamic navbar creation.
class ApplicationController < ActionController::Base
  before_action :set_user, :role, :set_navbar_variables, :set_links

  def authenticate_admin!
    return if @role == 'admin'

    redirect_to root_path, alert: 'You are not authorized.'
  end

  def authenticate_member!
    return if %w[member admin].include?(@role)

    redirect_to root_path, alert: 'You are not authorized, tell your higher-ups to make you a member'
  end

  private

  # Set the current user
  def set_user
    @user = current_user
    role if @user
  end

  # Set the role for the current user
  def role
    @role ||= current_user&.role || 'guest'
  end

  # Set navbar variables dynamically based on user role
  def set_navbar_variables
    @nav_links = default_nav_links
    reject_links_based_on_role
    set_auth_link
  end

  # Set all links
  def set_links
    @links = Link.all
  end

  # Helper methods
  def default_nav_links
    [
      { name: 'events', path: events_path },
      { name: 'photos', path: photos_path },
      { name: 'leaderboard', path: leaderboard_categories_url },
      { name: 'merch', path: merchandises_path },
      { name: 'ideas', path: ideas_path },
      { name: 'members', path: users_path },
      { name: 'links', path: links_path }
    ]
  end

  def reject_links_based_on_role
    links_to_reject = case @role
                      when 'admin'
                        []
                      when 'member'
                        ['members']
                      else
                        # Guests (and freshly-signed-in 'user' role) can browse events and
                        # photos read-only; the rest still require at least member.
                        %w[leaderboard merch ideas members links]
                      end

    @nav_links.reject! { |link| links_to_reject.include?(link[:name]) }
  end

  def set_auth_link
    @auth_link = if current_user
                   { name: 'Logout', path: destroy_user_session_path, method: :get }
                 else
                   { name: 'Login', path: user_google_oauth2_omniauth_authorize_path, method: :post }
                 end
  end
end
