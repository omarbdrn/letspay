# frozen_string_literal: true

module Merchants
  class BankAccountsController < ApplicationController
    include MerchantsConcern

    def edit
      @bank_account = merchant.bank_account || merchant.build_bank_account
      authorize @bank_account
    end

    def create
      @bank_account = merchant.build_bank_account(bank_account_params)
      authorize @bank_account
      if @bank_account.save
        flash[:notice] = t('.successful_update')
        redirect_to edit_merchant_bank_account_path(merchant)
      else
        logger_letspay(self.class.name).warn { "merchant=#{merchant.id} create=false reason=#{@bank_account.errors.messages}" }
        flash[:alert] = t('.failed_update')
        render :edit
      end
    end

    def update
      @bank_account = merchant.bank_account
      authorize @bank_account
      if @bank_account.update(bank_account_params)
        flash[:notice] = t('.successful_update')
        redirect_to edit_merchant_bank_account_path(merchant)
      else
        logger_letspay(self.class.name).warn { "bank_account=#{@bank_account.id} update=false reason=#{@bank_account.errors.messages}" }
        flash[:alert] = t('.failed_update')
        render :edit
      end
    end

    private

    def bank_account_params
      params.require(:bank_account).permit(:iban, :bic, :owner_name, :owner_street, :owner_city, :owner_region, :owner_zipcode, :owner_country, merchant_attributes: [ :id, :name, :pay_out_frequency, :next_pay_out_date ])
    end

  end
end
