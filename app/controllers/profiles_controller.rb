# == Schema Information
#
# Table name: profiles
#
#  id                  :integer          not null, primary key
#  first_name          :string
#  zip_code            :string
#  user_id             :integer
#  created_at          :datetime         not null
#  updated_at          :datetime         not null
#  language_id         :integer
#  library_location_id :integer
#

class ProfilesController < ApplicationController

  before_action :authenticate_user!
  before_action :set_user
  layout "user/logged_in_with_sidebar"

  def show
    @profile = Profile.find_or_initialize_by(user: @user)
  end

  def update
    @profile = Profile.find_or_initialize_by(user: @user)
    respond_to do |format|
      if @profile.update(profile_params)
        format.html { redirect_to profile_path, notice: "Profile was successfully updated." }
        format.json { render :show, status: :ok, location: @profile }
      else
        format.html { render :show }
        format.json { render json: @profile.errors, status: :unprocessable_entity }
      end
    end
  end

  private

  def set_user
    @user = current_user
  end

  def profile_params
    params.require(:profile).permit(:first_name, :zip_code, :language_id)
  end

end
