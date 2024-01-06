class PurchaseMailer < ApplicationMailer

  include ActionView::Helpers::TextHelper
  include ActionView::Helpers::NumberHelper

  def confirmation(purchase_id)
    @purchase = Purchase.find(purchase_id)
    paid_shares_count = purchase.letspayer_shares.select(&:paid?).size
    subject = purchase.all_friends_have_paid? ? t('.all_friends_paid', merchant_name: purchase.merchant_name) : t('.some_fiends_paid', count: paid_shares_count, letspayers_count: purchase.letspayer_shares.size, merchant_name: purchase.merchant_name)
    with_locale(@purchase.language) do
      mail(to: purchase.leader_email, subject: subject) do |format|
        format.mjml
        format.text
      end
    end
  end

  def confirmation_multicard(purchase_id)
    @purchase = Purchase.find(purchase_id)
    subject = purchase.all_friends_have_preauthorized? ? t('.all_friends_paid', merchant_name: purchase.merchant_name) : t('.some_fiends_did_not_pay', remaining_amount: number_to_currency(@purchase.multicard_remaining_amount), merchant_name: purchase.merchant_name)
    with_locale(@purchase.language) do
      mail(to: recipient_emails, subject: subject) do |format|
        format.mjml do
          if @purchase.merchant_manual_multicard_mode
            render 'confirmation_manual_multicard'
          else render 'confirmation_multicard'
          end
        end
        format.text do
          if @purchase.merchant_manual_multicard_mode
            render 'confirmation_manual_multicard'
          else render 'confirmation_multicard'
          end
        end
      end
    end
  end

  def leader_confirmation_multicard(purchase_id)
    @purchase = Purchase.find(purchase_id)
    with_locale(@purchase.language) do
      mail to: purchase.leader_email, subject: t('.subject', merchant_name: purchase.merchant_name) do |format|
        format.mjml
        format.text
      end
    end
  end

  def validation(purchase_id)
    @purchase = Purchase.find(purchase_id)
    logger.info { "Purchase validation email sent to #{purchase.leader_email} for purchase with #{purchase.id}" }
    with_locale(@purchase.language) do
      mail to: purchase.leader_email, subject: t('.subject', merchant_name: purchase.merchant_name) do |format|
        format.mjml
        format.text
      end
    end
  end

  def validation_multicard(purchase_id)
    @purchase = Purchase.find(purchase_id)
    logger.info { "Purchase validation_multicard email sent to #{purchase.leader_email} for purchase with #{purchase.id}" }
    with_locale(@purchase.language) do
      mail to: recipient_emails, subject: t('.subject', merchant_name: purchase.merchant_name) do |format|
        format.mjml do
          if @purchase.merchant_manual_multicard_mode
            render 'validation_manual_multicard'
          else render 'validation_multicard'
          end
        end
        format.text do
          if @purchase.merchant_manual_multicard_mode
            render 'validation_manual_multicard'
          else render 'validation_multicard'
          end
        end
      end
    end
  end

  def reminder_multicard(purchase_id)
    @purchase = Purchase.find(purchase_id)
    subject = t('.some_fiends_did_not_pay', remaining_amount: number_to_currency(@purchase.multicard_remaining_amount), merchant_name: purchase.merchant_name)
    logger.info { "Purchase reminder_multicard email sent to #{purchase.leader_email} for purchase with #{purchase.id}" }
    with_locale(@purchase.language) do
      mail to: recipient_emails, subject: subject do |format|
        format.mjml do
          if @purchase.merchant_manual_multicard_mode
            render 'reminder_manual_multicard'
          else render 'reminder_multicard'
          end
        end
        format.text do
          if @purchase.merchant_manual_multicard_mode
            render 'reminder_manual_multicard'
          else render 'reminder_multicard'
          end
        end
      end
    end
  end

  private
  attr_reader :purchase

  def notified_emails
    purchase.notifications.map { |n| n.account.email }
  end

  def recipient_emails
    notified_emails.push(purchase.leader_email)
  end
end
