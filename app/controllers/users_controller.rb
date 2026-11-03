# frozen_string_literal: true

# UsersController handles CRUD operations for users, including leaderboard management and point resets.
class UsersController < ApplicationController
  before_action :find_user, except: %i[index reset_points export]
  before_action :role, :set_navbar_variables
  before_action :authenticate_admin!

  def index
    sort_column = params[:sort] || 'full_name' # Default to sorting by full_name
    sort_direction = params[:direction] || 'asc' # Default to ascending order

    @users = User.order("#{sort_column} #{sort_direction}")
  end

  # GET /users/export.csv - member point totals for the admins' master sheet,
  # alphabetical by first name.
  def export
    users = User.where(role: %w[member admin]).order(Arel.sql('lower(full_name)'))
    send_data User.to_csv(users), filename: "member-points-#{Date.current.iso8601}.csv",
                                  type: 'text/csv', disposition: 'attachment'
  end

  def show; end

  def edit
    respond_to do |format|
      format.turbo_stream
      format.html
    end
  end

  def update
    if @user.update(user_params)
      handle_update_success
    else
      handle_update_failure
    end
  end

  def delete; end

  def destroy
    @user.destroy
    respond_to do |format|
      format.html { redirect_to users_path, notice: 'User was successfully deleted.' }
      format.turbo_stream
    end
  end

  def reset_points
    User.find_each { |user| user.update(points: 0) } # Ensures validations are respected
    redirect_to users_path
  end

  private

  def find_user
    @user = User.find(params[:id])
  end

  def user_params
    params.require(:user).permit(:full_name, :committee, :points, :role, :dues)
  end

  def handle_update_success
    respond_to do |format|
      format.turbo_stream
      format.html { redirect_to users_path, notice: 'User was successfully updated.' }
    end
  end

  def handle_update_failure
    flash[:alert] = @user.errors.full_messages.to_sentence
    respond_to do |format|
      format.html { render :edit, status: :unprocessable_entity }
      format.turbo_stream { render :edit, status: :unprocessable_entity }
    end
  end
end
