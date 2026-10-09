# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'CSV exports', type: :controller do
  include Devise::Test::ControllerHelpers

  let(:admin) { create(:user, full_name: 'Admin', role: 'admin') }
  let(:member) { create(:user, full_name: 'Zed Member', role: 'member', committee: 'Env', points: 5) }

  describe UsersController do
    describe 'GET #export' do
      before do
        member # ensure created
        create(:user, full_name: 'Bea Admin', role: 'admin', points: 9)
        create(:user, full_name: 'Randy Rando', role: 'user', points: 2)
      end

      context 'as an admin' do
        before { sign_in admin }

        it 'returns a CSV attachment of members and admins only, first-name sorted' do
          get :export, format: :csv

          expect(response).to have_http_status(:ok)
          expect(response.media_type).to eq('text/csv')
          expect(response.headers['Content-Disposition']).to include('attachment', 'member-points-')

          names = CSV.parse(response.body).drop(1).map(&:first)
          expect(names).to eq(['Admin', 'Bea Admin', 'Zed Member'])
          expect(names).not_to include('Randy Rando')
        end
      end

      context 'as a member' do
        before { sign_in member }

        it 'redirects to root' do
          get :export, format: :csv
          expect(response).to redirect_to(root_path)
        end
      end
    end
  end

  describe AttendancesController do
    describe 'GET #export' do
      let(:event) { create(:event, name: 'Fall Kickoff') }

      before do
        create(:attendance, event:, user: create(:user, full_name: 'Cara'), checked_in_at: 1.hour.ago)
        create(:attendance, event:, user: create(:user, full_name: 'Abe'), checked_in_at: 2.hours.ago)
      end

      context 'as an admin' do
        before { sign_in admin }

        it 'returns a CSV of the sign-ins sorted by member name' do
          get :export, params: { event_id: event.id }, format: :csv

          expect(response).to have_http_status(:ok)
          expect(response.media_type).to eq('text/csv')
          rows = CSV.parse(response.body)
          expect(rows[0]).to eq(['Event', 'Member', 'Email', 'Committee', 'Checked In At'])
          expect(rows.drop(1).map { |r| r[1] }).to eq(%w[Abe Cara])
          expect(rows[1][0]).to eq('Fall Kickoff')
        end
      end

      context 'as a member' do
        before { sign_in member }

        it 'redirects to root' do
          get :export, params: { event_id: event.id }, format: :csv
          expect(response).to redirect_to(root_path)
        end
      end
    end
  end
end
