# frozen_string_literal: true

# PhotosController manages photo uploads, updates, deletions, and galleries.
# It ensures that photos are associated with users and handles validations during photo creation and updates.
class PhotosController < ApplicationController
  before_action :set_photo, except: %i[index new create gallery]
  include ActionView::RecordIdentifier

  # GET /photos
  def index
    @photos = Photo.order(id: :desc).includes(:photo_tags)
  end

  # GET /photos/1
  def show; end

  # GET /photos/new
  def new
    @photo = Photo.new
    respond_to do |format|
      format.turbo_stream
      format.html
    end
  end

  # GET /photos/1/edit
  def edit
    respond_to do |format|
      format.turbo_stream
      format.html
    end
  end

  # POST /photos
  def create
    handle_blank_photo and return if photo_params_blank?

    @photo = current_user.photos.build(photo_params)

    if @photo.save
      @photo.sync_tags(tag_names_param)
      handle_create_success
    else
      handle_create_failure
    end
  end

  # PATCH/PUT /photos/1
  def update
    if @photo.update(photo_params)
      @photo.sync_tags(tag_names_param)
      handle_update_success
    else
      handle_update_failure
    end
  end

  # DELETE /photos/1
  def destroy
    @photo.destroy
    flash.now[:notice] = 'Photo was successfully deleted.'
    respond_to do |format|
      format.turbo_stream
      format.html { redirect_to photos_path, notice: 'Photo was successfully deleted.' }
    end
  end

  # GET /photos/gallery
  def gallery
    @photos = Photo.all
  end

  private

  # Use callbacks to share common setup or constraints between actions.
  def set_photo
    @photo = Photo.find(params[:id])
  end

  # Only allow a list of trusted parameters through.
  def photo_params
    params.require(:photo).permit(:title, :description, :image)
  end

  # Home-page carousel tag keys the form submitted (checkbox values), filtered to
  # the known set. Read separately from photo_params since it isn't a column.
  def tag_names_param
    Array(params.dig(:photo, :tag_names)).map(&:to_s) & PhotoTag.tags.keys
  end

  # The photo form always posts a hidden tag_names field, so params[:photo] is
  # never truly blank - check the real content fields instead.
  def photo_params_blank?
    photo = params[:photo]
    photo.blank? || photo.except(:tag_names).values.all?(&:blank?)
  end

  # Handle the scenario when params[:photo] is blank.
  def handle_blank_photo
    respond_to do |format|
      format.turbo_stream { render turbo_stream: turbo_stream.replace(dom_id(Photo.new), '') }
      format.html { redirect_to photos_path, alert: 'Photo creation was canceled.' }
    end
  end

  # Handle successful creation of a photo.
  def handle_create_success
    flash.now[:notice] = 'Photo Created'
    respond_to do |format|
      format.html { redirect_to photos_path, notice: 'Photo Created' }
      format.turbo_stream
    end
  end

  # Handle failed creation of a photo.
  def handle_create_failure
    flash.now[:alert] = @photo.errors.full_messages.to_sentence
    respond_to do |format|
      format.html { render :new, status: :unprocessable_entity }
      format.turbo_stream { render :new, status: :unprocessable_entity }
    end
  end

  # Handle successful update of a photo.
  def handle_update_success
    flash.now[:notice] = 'Photo was successfully updated.'
    respond_to do |format|
      format.html { redirect_to photos_path, notice: 'Photo was successfully updated.' }
      format.turbo_stream
    end
  end

  # Handle failed update of a photo.
  def handle_update_failure
    flash[:alert] = @photo.errors.full_messages.to_sentence
    respond_to do |format|
      format.html { render :edit, status: :unprocessable_entity }
      format.turbo_stream { render :edit, status: :unprocessable_entity }
    end
  end
end
