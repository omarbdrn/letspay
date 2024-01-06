# frozen_string_literal: true

class StaticController < ApplicationController
  def show
    skip_authorization
  end
end
