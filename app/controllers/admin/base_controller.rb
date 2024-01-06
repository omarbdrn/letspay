class Admin::BaseController < ActionController::Base
  layout 'admin'
  before_action :authenticate_account!, :ensure_current_account_is_admin!

  private

  def ensure_current_account_is_admin!
    redirect_to root_path unless current_account.present? && current_account.admin
  end
end
