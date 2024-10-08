class UsersController < ApplicationController
  before_action :authenticate_user!, except: %i[show_otp verify_otp]

  def show_otp
    #  Render OTP verify page?
  end

  def disable_otp
    if current_user.validate_and_consume_otp!(params[:otp_attempt])
      current_user.otp_required_for_login = false
      current_user.save!
      redirect_to root_path, notice: '2FA disabled successfully'
    else
      flash[:alert] = 'Invalid OTP code.'
      redirect_back(fallback_location: root_path)
    end
  end

  def verify_otp
    verifier = Rails.application.message_verifier(:otp_session)
    user_id = verifier.verify(session[:otp_token])
    user = User.find(user_id)

    if user.validate_and_consume_otp!(params[:otp_attempt])
      sign_in(:user, user)
      redirect_to root_path, notice: 'Signed In Successfully!'
    else
      flash[:alert] = 'Invalid OTP Code'
      redirect_to new_user_session_path
    end
  end

  def enable_show_otp_qr
    if current_user.otp_required_for_login
      redirect_to edit_user_registration_path, alert: '2FA is already enabled'
    else
      current_user.otp_secret = User.generate_otp_secret
      issuer = 'My App'
      label = "#{issuer}:#{current_user.email}"

      @provisioning_uri = current_user.otp_provisioning_uri(label, issuer:)
      current_user.save!
    end
  end

  def enable_otp_verify
    if current_user.validate_and_consume_otp!(params[:otp_attempt])
      current_user.otp_required_for_login = true
      current_user.save!
      redirect_to edit_user_registration_path, notice: '2FA enabled successfully'
    else
      redirect_to enable_otp_show_qr_users_path, alert: 'Invalid OTP code'
    end
  end
end
