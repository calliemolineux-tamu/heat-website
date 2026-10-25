# frozen_string_literal: true

# HomeController
class HomeController < ApplicationController
  before_action :set_user, :role, :set_navbar_variables

  # Each home-page wheel is driven by a photo tag. Until at least one photo is
  # tagged for a wheel it falls back to these hardcoded slides.
  CAROUSELS = [
    {
      tag: 'recent_activities',
      title: 'Recent H.E.A.T. Activities',
      images: %w[carousel1slide1.jpg carousel1slide2.jpg carousel1slide3.jpg carousel1slide4.jpg],
      descriptions: [
        'H.E.A.T. at Texas Wolfdog Project & Shelter',
        'H.E.A.T. members receiving a grant from Aggie Green Fund and kicking off The Period Project',
        'Unbound Now presenting human trafficking bystander training to H.E.A.T. members',
        'Period Project presenting their work at SGA Open Forum'
      ]
    },
    {
      tag: 'in_action',
      title: 'H.E.A.T. in Action',
      images: %w[carousel2slide1.jpg carousel2slide2.jpg carousel2slide3.jpg carousel2slide4.jpg],
      descriptions: [
        'H.E.A.T. members helping to build medical facilities for underserved communities with TAMU BUILD',
        'H.E.A.T. chapters from TAMU and TXST collaborating on cleaning a local stream in San Marcos, TX',
        'H.E.A.T. members collaborating with Texas Ramp Project to build a ramp for a local family needing ' \
        'wheelchair accessibility to their home',
        'H.E.A.T. members helping TMR Rescue staff with fixing and cleaning equine enclosures'
      ]
    },
    {
      tag: 'social_events',
      title: 'H.E.A.T. at Social Events',
      images: %w[carousel3slide1.jpg carousel3slide2.jpg carousel3slide3.jpg],
      descriptions: [
        'Painting social at Aggie Park to meet prospective members!',
        'H.E.A.T. members participating in our quarterly street cleanups at our adopted street',
        'H.E.A.T. members watching the total solar eclipse together'
      ]
    }
  ].freeze

  WHEEL_SIZE = 5

  def index
    @carousels = CAROUSELS.map do |carousel|
      photos = Photo.for_carousel(carousel[:tag]).limit(WHEEL_SIZE).to_a
      next carousel if photos.empty?

      carousel.merge(
        images: photos.map(&:image_url),
        descriptions: photos.map { |photo| photo.description.presence || photo.title }
      )
    end
  end
end
