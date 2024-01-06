require_relative 'boot'

require 'rails/all'

# Require the gems listed in Gemfile, including any gems
# you've limited to :test, :development, or :production.
Bundler.require(*Rails.groups)

module LetsPay
  class Application < Rails::Application
    # Settings in config/environments/* take precedence over those specified here.
    # Application configuration should go into files in config/initializers
    # -- all .rb files in that directory are automatically loaded.
    config.i18n.available_locales = [:en, :fr]
    config.i18n.default_locale = :fr

    config.to_prepare do
      Devise::SessionsController.layout "fullscreen"
      Devise::RegistrationsController.layout proc{ |controller| account_signed_in? ? "application" : "fullscreen" }
      Devise::ConfirmationsController.layout "fullscreen"
      Devise::UnlocksController.layout "fullscreen"
      Devise::PasswordsController.layout "fullscreen"
    end

    config.generators do |generator|
      generator.orm :active_record, primary_key_type: :uuid
    end

    config.active_job.queue_adapter = :sidekiq
    config.app_host = ENV['APP_HOST'] ? ENV['APP_HOST'] : (ENV['HEROKU_APP_NAME'] ? "https://#{ENV['HEROKU_APP_NAME']}.herokuapp.com" : "https://app.service.letspay.internal")

    config.action_mailer.default_url_options = { host: 'service.letspay.internal' }

    ActionMailer::Base.smtp_settings = {
      user_name: ENV['SMTP_USERNAME'],
      password: ENV['SMTP_PASSWORD'],
      address: ENV['SMTP_ADDRESS'],
      port: ENV['SMTP_PORT'],
      authentication: :plain,
      enable_starttls_auto: true
    }

    config.middleware.insert_before 0, Rack::Cors, :logger => Rails.logger do

      allow do
        origins(Rails.application.config.app_host)
        resource '/api/payments/*', :headers => :any, :methods => [:get, :post, :put]
      end

      allow do
        origins '*'
        resource '/api/merchants/*', :headers => :any, :methods => [:get, :post, :head]
      end

      allow do
        origins 'app.forestadmin.com'
        resource '*', :headers => :any, :methods => :any
      end
    end
  end
end
