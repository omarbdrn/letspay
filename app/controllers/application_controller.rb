# frozen_string_literal: true

class ApplicationController < ActionController::Base
  include Pundit
  after_action :verify_authorized, except: %i(index select_merchant), unless: :devise_controller?
  after_action :verify_policy_scoped, only: :index

  protect_from_forgery with: :exception, prepend: true

  rescue_from Pundit::NotAuthorizedError, with: :user_not_authorized

  private

  def after_sign_in_path_for(_resource)
    if current_account.merchants.count >= 2
      merchants_dispatch_path
    elsif current_account.merchants.count == 1
      merchant_purchases_path(current_account.merchants.first.slug)
    else
      session['account_return_to'] || root_path
    end
  end

  def user_not_authorized
    flash[:alert] = t('global.unauthorized')
    redirect_to(request.referrer || root_path)
  end

  def pundit_user
    current_account
  end

  def logger_letspay(class_name = 'ApplicationController')
    LOGGER_LETSPAY[class_name] ||= LetsPay::Logger.new(class_name)
  end

end
