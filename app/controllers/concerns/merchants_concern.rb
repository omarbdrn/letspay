# frozen_string_literal: true

module MerchantsConcern
  extend ActiveSupport::Concern

  included do
    before_action :authenticate_account!
    before_action :load_merchant
    before_action :set_locale

    layout 'merchants'

    attr_reader :merchant

    def default_url_options
      { locale: I18n.locale }
    end
  end

  private

  def load_merchant
    @merchant = Merchant.friendly.find(params[:merchant_id])
  end

  def set_locale
    I18n.locale = params[:locale] || I18n.default_locale
  end
end
