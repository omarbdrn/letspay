# frozen_string_literal: true

class PingController < ApplicationController
  def new
    skip_authorization
    head :ok
  end
end
