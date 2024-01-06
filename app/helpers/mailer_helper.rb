# frozen_string_literal: true

module MailerHelper
  def confirmation_share_status(share, timezone)
    share.paid? ? I18n.t('mailer.share.status.paid', paid_at: I18n.l(share.paid_at.in_time_zone(timezone), format: :simple)) : I18n.t('mailer.share.status.unpaid')
  end

  def confirmation_multicard_share_status(share, timezone)
    share.pre_authorized? ? I18n.t('mailer.share.status.paid', paid_at: I18n.l(share.pre_authorization.created_at.in_time_zone(timezone), format: :simple)) : I18n.t('mailer.share.status.unpaid')
  end

  def apply_button_custom_background(share)
    share.merchant_white_label && share.merchant_white_label_button_color.present? ? share.merchant_white_label_button_color : '#0073EE'
  end

  def date_with_timezone(date, timezone)
    hour = I18n.l(date.in_time_zone(timezone), format: :simple)
    timezone_city = ActiveSupport::TimeZone::MAPPING.key(timezone)
    "#{hour} (#{I18n.t('time.time_of', city: timezone_city)})"
  end

  def logo_url
    image_url('logo_blue.png', host: Rails.configuration.app_host)
  end

  def with_locale(locale)
    I18n.with_locale(locale.to_sym) do
      yield if block_given?
    end
  end

  def cta_url(share)
    if share.leader?
      payment_url(share.merchant_slug, share.purchase_id, api_key: share.api_key)
    else
      payment_url(share.merchant_slug, share.purchase_id, share.id, api_key: share.api_key)
    end
  end
end
