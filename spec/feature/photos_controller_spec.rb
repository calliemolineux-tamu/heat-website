# frozen_string_literal: true

require 'rails_helper'

RSpec.describe PhotosController, type: :controller do
  include Devise::Test::ControllerHelpers

  let(:user) do
    create(
      :user,
      email: 'testuser@example.com',
      full_name: 'Test User',
      role: 'admin',
      committee: 'Test Committee',
      avatar_url: 'https://developers.google.com/static/workspace/chat/images/chat-product-icon.png'
    )
  end

  let(:photo) { create(:photo, user:) }

  before do
    sign_in user # Ensure user is signed in for all tests
  end

  describe 'GET #index' do
    before do
      get :index
    end

    it 'assigns @photos' do
      expect(assigns(:photos)).to eq([photo])
    end

    it 'renders the index template' do
      expect(response).to render_template(:index)
    end
  end

  describe 'GET #show' do
    before do
      get :show, params: { id: photo.id }
    end

    it 'assigns the requested photo' do
      expect(assigns(:photo)).to eq(photo)
    end

    it 'renders the show template' do
      expect(response).to render_template(:show)
    end
  end

  describe 'GET #new' do
    before do
      get :new
    end

    it 'assigns a new photo' do
      expect(assigns(:photo)).to be_a_new(Photo)
    end

    it 'renders the new template' do
      expect(response).to render_template(:new)
    end
  end

  describe 'GET #edit' do
    before do
      get :edit, params: { id: photo.id }
    end

    it 'assigns the requested photo' do
      expect(assigns(:photo)).to eq(photo)
    end

    it 'renders the edit template' do
      expect(response).to render_template(:edit)
    end
  end

  describe 'POST #create' do
    context 'when params[:photo] is blank' do
      it 'redirects to photos path' do
        post :create, params: { photo: nil }
        expect(response).to redirect_to(photos_path)
      end

      it 'sets a cancellation alert' do
        post :create, params: { photo: nil }
        expect(flash[:alert]).to eq('Photo creation was canceled.')
      end

      it 'renders a Turbo Stream response with an empty replacement' do
        post :create, params: { photo: nil, format: :turbo_stream }
        expect(response.media_type).to eq(Mime[:turbo_stream])
        # Add additional expectations for Turbo Stream content if necessary
      end
    end

    context 'with valid attributes' do
      let(:valid_attributes) { attributes_for(:photo) }

      it 'creates a new photo' do
        expect do
          post :create, params: { photo: valid_attributes }
        end.to change(Photo, :count).by(1)
      end

      it 'redirects to the photos path' do
        post :create, params: { photo: valid_attributes }
        expect(response).to redirect_to(photos_path)
      end

      it 'sets a notice message' do
        post :create, params: { photo: valid_attributes }
        expect(flash[:notice]).to eq('Photo Created')
      end

      it 'responds to Turbo Stream format' do
        post :create, params: { photo: valid_attributes, format: :turbo_stream }
        expect(response.media_type).to eq(Mime[:turbo_stream])
      end

      it 'applies checked home-page tags' do
        post :create, params: { photo: valid_attributes.merge(tag_names: ['', 'in_action', 'social_events']) }
        expect(Photo.last.photo_tags.map(&:tag)).to contain_exactly('in_action', 'social_events')
      end

      it 'creates no tags when none are checked' do
        post :create, params: { photo: valid_attributes.merge(tag_names: ['']) }
        expect(Photo.last.photo_tags).to be_empty
      end
    end

    context 'with invalid attributes' do
      let(:invalid_attributes) { attributes_for(:photo, title: nil) }

      before do
        post :create, params: { photo: invalid_attributes }
      end

      it 'does not create a new photo' do
        expect(Photo.count).to eq(0) # Assuming only one photo exists initially
      end

      it 're-renders the new template' do
        expect(response).to render_template(:new)
      end

      it 'sets an alert message' do
        expect(flash.now[:alert]).to be_present
      end
    end
  end

  describe 'PATCH #update' do
    context 'with valid attributes' do
      let(:valid_update_attributes) { { title: 'Updated Title' } }

      before do
        patch :update, params: { id: photo.id, photo: valid_update_attributes }
      end

      it 'updates the requested photo' do
        photo.reload
        expect(photo.title).to eq('Updated Title')
      end

      it 'redirects to photos path' do
        expect(response).to redirect_to(photos_path)
      end

      it 'sets a notice message' do
        expect(flash[:notice]).to eq('Photo was successfully updated.')
      end
    end

    context 'when toggling home-page tags' do
      before { photo.sync_tags(%w[in_action]) }

      it 'adds newly checked tags and drops unchecked ones' do
        patch :update, params: { id: photo.id, photo: { tag_names: ['', 'social_events'] } }
        expect(photo.photo_tags.reload.map(&:tag)).to contain_exactly('social_events')
      end

      it 'leaves an unchanged tag row (and its recency) alone' do
        original = photo.photo_tags.find_by(tag: :in_action).created_at
        travel_to(1.hour.from_now) do
          patch :update, params: { id: photo.id, photo: { title: 'New', tag_names: ['', 'in_action'] } }
        end
        expect(photo.photo_tags.reload.find_by(tag: :in_action).created_at).to eq(original)
      end
    end

    context 'with invalid attributes' do
      let(:invalid_update_attributes) { { title: nil } }

      before do
        patch :update, params: { id: photo.id, photo: invalid_update_attributes }
      end

      it 'does not update the photo' do
        photo.reload
        expect(photo.title).not_to be_nil
      end

      it 're-renders the edit template' do
        expect(response).to render_template(:edit)
      end

      it 'sets an alert message' do
        expect(flash.now[:alert]).to be_present
      end
    end
  end

  describe 'DELETE #destroy' do
    let!(:photo_to_delete) { create(:photo, user:) }

    it 'deletes the photo' do
      expect do
        delete :destroy, params: { id: photo_to_delete.id }
      end.to change(Photo, :count).by(-1)
    end

    it 'redirects to photos path' do
      delete :destroy, params: { id: photo_to_delete.id }
      expect(response).to redirect_to(photos_path)
    end

    it 'sets a notice message' do
      delete :destroy, params: { id: photo_to_delete.id }
      expect(flash[:notice]).to eq('Photo was successfully deleted.')
    end
  end

  describe 'GET #gallery' do
    before do
      get :gallery
    end

    it 'assigns @photos' do
      expect(assigns(:photos)).to eq([photo])
    end

    it 'renders the gallery template' do
      expect(response).to render_template(:gallery)
    end
  end
end
