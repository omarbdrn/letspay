# frozen_string_literal: true

class ApplicationMailer < ActionMailer::Base
  default from: 'LetsPay <noreply@service.letspay.internal>'
  layout 'mailer'

  helper MailerHelper
  include MailerHelper

  def logger
    @logger ||= LetsPay::Logger.new(self.class.name)
  end
end
