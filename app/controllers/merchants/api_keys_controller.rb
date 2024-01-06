# frozen_string_literal: true

module Merchants
  class ApiKeysController < ApplicationController
    include MerchantsConcern

    def show
      authorize merchant

      respond_to do |format|
        format.html
      end
    end
  end
end
