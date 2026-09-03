# frozen_string_literal: true

# spec/feature/home_spec.rb
require 'rails_helper'

RSpec.feature 'Home Page Features', type: :feature do
  let!(:admin) do
    create(:user, email: 'testuser@example.com', full_name: 'Test User', role: 'admin',
                  committee: 'Test Committee',
                  avatar_url: 'https://developers.google.com/static/workspace/chat/images/chat-product-icon.png')
  end

  let!(:member) do
    create(:user, email: 'testuser2@example.com', full_name: 'Test User 2', role: 'member',
                  committee: 'Test Committee',
                  avatar_url: 'https://developers.google.com/static/workspace/chat/images/chat-product-icon.png')
  end

  let!(:user) do
    create(:user, email: 'testuser3@example.com', full_name: 'Test User 3', role: 'user',
                  committee: 'Test Committee',
                  avatar_url: 'https://developers.google.com/static/workspace/chat/images/chat-product-icon.png')
  end

  context 'when viewing the navigation as different roles' do
    scenario 'as Admin' do
      login_as(admin, scope: :user)
      visit root_path

      expect(page).to have_content('members')
    end

    scenario 'as Member' do
      login_as(member, scope: :user)
      visit root_path

      # Expect navbar to not have 'members'
      within('header') do
        expect(page).not_to have_content('members')
      end
    end

    scenario 'as User' do
      login_as(user, scope: :user)
      visit root_path

      # Expect navbar to not have 'members'
      within('header') do
        expect(page).not_to have_content('ideas')
      end
    end
  end

  context 'when logging in and out' do
    scenario 'from non-user to admin' do
      visit root_path

      # Separate expectations
      expect_login_content_before(admin)
      expect_logout_content_after
    end
  end

  context 'with the home-page photo wheels' do
    def in_action_wheel
      find('.carousel-container', text: 'H.E.A.T. in Action')
    end

    scenario 'an untagged wheel keeps its hardcoded slides' do
      visit root_path
      within('.carousel-container', text: 'H.E.A.T. at Social Events') do
        expect(page).to have_css("img[src*='carousel3slide1']")
      end
    end

    scenario 'a tagged wheel shows the 5 most-recently-tagged photos' do
      photos = Array.new(6) { create(:photo, user: admin) }
      photos.each_with_index do |photo, i|
        travel_to((10 - i).minutes.ago) { photo.sync_tags(%w[in_action]) }
      end
      oldest_tagged = photos.first
      newest_tagged = photos.last

      visit root_path

      within in_action_wheel do
        expect(page).to have_css('img.carousel-image', count: 5)
        expect(page).to have_css("img[src='#{newest_tagged.image_url}']")
        expect(page).not_to have_css("img[src='#{oldest_tagged.image_url}']")
        # hardcoded fallback slide is gone
        expect(page).not_to have_css("img[src*='carousel2slide1']")
      end
    end

    scenario 'tagging an old photo moves it into the wheel ahead of newer photos' do
      recent = Array.new(5) { |i| create(:photo, user: admin).tap { |p| travel_to((5 - i).minutes.ago) { p.sync_tags(%w[in_action]) } } }
      latecomer = create(:photo, user: admin)
      latecomer.sync_tags(%w[in_action]) # tagged now => newest

      visit root_path
      within in_action_wheel do
        expect(page).to have_css("img[src='#{latecomer.image_url}']")
        expect(page).not_to have_css("img[src='#{recent.first.image_url}']") # oldest-tagged pushed out
      end
    end
  end

  # Helper methods
  def expect_login_content_before(user)
    expect(page).to have_content('Login')

    login_as(user, scope: :user)
    visit root_path
  end

  def expect_logout_content_after
    expect(page).to have_content('Logout')
  end
end
