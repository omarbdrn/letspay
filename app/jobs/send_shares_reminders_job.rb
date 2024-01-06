class SendSharesRemindersJob < ApplicationJob
  include ActiveJob::Retry.new(strategy: :exponential, limit: 5)

  queue_as :default

  def perform(*_args)
    logger.info { 'SendSharesRemindersJob is now running' }
    Share.unreminded.soon_to_expire.reject(&:paid?).reject(&:purchase_initialize?).reject(&:purchase_waiting_merchant_validation?).reject(&:pre_authorized?).reject(&:is_multicard?).each do |share|
      ShareMailer.reminder(share.id).deliver_now
      share.reminded_at = Time.current
      share.save!
    end

    Merchant.find_each do |merchant|
      Share.unreminded.multicard_soon_to_expire_for(merchant).reject(&:paid?).reject(&:purchase_initialize?).reject(&:purchase_waiting_merchant_validation?).reject(&:pre_authorized?).reject(&:purchase_cancelled?).select(&:is_multicard?).reject(&:is_manual_multicard?).each do |share|
        ShareMailer.reminder_multicard(share.id).deliver_now
        share.reminded_at = Time.current
        share.save!
      end
    end
  end
end
