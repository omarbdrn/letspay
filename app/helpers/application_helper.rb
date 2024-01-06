# frozen_string_literal: true

module ApplicationHelper
  def gulp_asset_path(path)
    if defined?(REV_MANIFEST) && !REV_MANIFEST.blank? # && !Rails.env.development?
      "#{ENV['CDN_URL']}#{HEROKU_REVIEW_APP_ASSETS}/assets/#{REV_MANIFEST[path] || path}"
    else
      "/assets/#{path}"
    end
  end

  def window_cdn_url
    cdn_url = ENV['CDN_URL']
    if !cdn_url.blank?
      "window.cdnUrl = '#{cdn_url}#{HEROKU_REVIEW_APP_ASSETS}/assets/';"
    else
      'window.cdnUrl   = "/assets/";'
    end
  end

  def window_tiny_url_token
    "window.tinyUrlToken = '#{ENV['TINY_URL_TOKEN']}';"
  end

  def window_tiny_url_group_guid
    "window.tinyUrlGroupGuid = '#{ENV['TINY_URL_GROUP_GUID']}';"
  end

  def time_with_merchant_timezone(time, merchant)
    I18n.l(time.in_time_zone(merchant.merchant_timezone), format: :long)
  end
end
