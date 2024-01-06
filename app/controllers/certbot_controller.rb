# frozen_string_literal: true

class CertbotController < ApplicationController
  layout false

  def new
    skip_authorization
    render plain: ENV['LETS_ENCRYPT_CHALLENGE']
  end
end
