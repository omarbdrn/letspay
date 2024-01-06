class MerchantMailer < ApplicationMailer

  def send_ticket(purchase_id)
    @purchase = Purchase.find(purchase_id)
    @merchant = @purchase.merchant

    return if @merchant.email_ticket.blank?

    logger.info { "Sent email ticket to #{@merchant.name} for purchase with #{@purchase.id}" }
    mail to: @merchant.email_ticket, subject: "[LETSPAY_TICKET] Ticket for #{@purchase.id}"
  end

  def payout_summary(merchant_id, related_transfers_ids)
    @merchant = Merchant.find merchant_id
    return unless @merchant.pay_out_frequency.daily? && @merchant.payout_summary_email.present?
    @transfers = Transfer.find related_transfers_ids
    logger.info { "Sent payout_summary to #{@merchant.name}" }
    mail to: @merchant.payout_summary_email, subject: t('.subject', related_date: I18n.l(Date.today - 1.day, format: :simple)) do |format|
      format.mjml
      format.text
    end
  end
end
