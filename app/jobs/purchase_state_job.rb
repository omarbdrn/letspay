# frozen_string_literal: true

class PurchaseStateJob < ApplicationJob
  include ActiveJob::Retry.new(strategy: :exponential, limit: 5)
  
  queue_as :default

  def perform(purchase_id)
    purchase = ::Purchase.find(purchase_id)

    total_paid = purchase.shares.includes(:pay_in).select(&:paid?).sum(&:amount_cents)

    # Successful if all money are collected
    purchase.update(state: :SUCCESSFUL) if total_paid == purchase.amount_cents

    logger.info { "Purchase state job run: total_paid=#{total_paid} amount=#{purchase.amount_cents} new state=#{purchase.state}" }
  end
end
