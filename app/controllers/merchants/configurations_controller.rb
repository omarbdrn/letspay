# frozen_string_literal: true

module Merchants
  class ConfigurationsController < ApplicationController
    include MerchantsConcern

    def edit
      authorize merchant
      respond_to do |format|
        format.html
      end
    end

    def update
      authorize merchant

      respond_to do |format|
        format.html do
          update_and_direct
        end
      end
    end

    private

    def update_and_direct
      if merchant.update(configuration_params)
        flash[:notice] = t('.success')
        redirect_to edit_merchant_configuration_path(merchant)
      else
        logger_letspay(self.class.name).warn { "merchant=id update=false reason=#{merchant.errors.full_messages.join(', ')}" }
        flash[:alert] = t('.failure')
        render :edit
      end
    end

    def configuration_params
      params.require(:merchant).permit(:name, :site_url, :email_ticket, :webhooks_url, :terms_url, :picture_url, :auto_redirect_to_merchant_url, :multicard_letspayer_participation_round_in_hours, :multicard_leader_last_chance_round_in_hours, :payout_summary_email)
    end
  end
end
