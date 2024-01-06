class ShareMailer < ApplicationMailer

  def invitation(share_id)
    @share = Share.find(share_id)
    logger.info { "Share invitation email sent to #{share.email} for purchase with share with id #{share.id} related to purchase with id #{share.purchase.id}" }
    with_locale(@share.language) do
      mail to: share.email, subject: t('.subject', merchant_name: share.merchant_name) do |format|
        format.mjml
        format.text
      end
    end
  end

  def invitation_multicard(share_id)
    @share = Share.find(share_id)
    logger.info { "Share invitation_multicard email sent to #{share.email} for purchase with share with id #{share.id} related to purchase with id #{share.purchase.id}" }
    with_locale(@share.language) do
      mail to: share.email, subject: t('.subject', merchant_name: share.merchant_name) do |format|
        format.mjml do
          if @share.is_manual_multicard?
            render 'invitation_manual_multicard'
          else render 'invitation_multicard'
          end
        end
        format.text do
          if @share.is_manual_multicard?
            render 'invitation_manual_multicard'
          else render 'invitation_multicard'
          end
        end
      end
    end
  end

  def reminder(share_id)
    @share = Share.find(share_id)
    logger.info { "Share reminder email sent to #{share.email} for purchase with share with id #{share.id} related to purchase with id #{share.purchase.id}" }
    with_locale(@share.language) do
      mail to: share.email do |format|
        format.mjml
        format.text
      end
    end
  end

  def reminder_multicard(share_id)
    @share = Share.find(share_id)
    logger.info { "Share reminder_multicard email sent to #{share.email} for purchase with share with id #{share.id} related to purchase with id #{share.purchase.id}" }
    with_locale(@share.language) do
      mail to: share.email do |format|
        format.mjml do
          if @share.is_manual_multicard?
            render 'reminder_manual_multicard'
          else render 'reminder_multicard'
          end
        end
        format.text do
          if @share.is_manual_multicard?
            render 'reminder_manual_multicard'
          else render 'reminder_multicard'
          end
        end
      end
    end
  end

  def validation(share_id)
    @share = Share.find(share_id)
    logger.info { "Share payment validation email sent to #{share.email} for purchase with share with id #{share.id} related to purchase with id #{share.purchase.id}" }
    with_locale(@share.language) do
      mail to: share.email do |format|
        format.mjml
        format.text
      end
    end
  end

  def validation_multicard(share_id)
    @share = Share.find(share_id)
    logger.info { "Share payment validation_multicard email sent to #{share.email} for purchase with share with id #{share.id} related to purchase with id #{share.purchase.id}" }
    with_locale(@share.language) do
      mail from: sender, to: share.email do |format|
        format.mjml do
          if @share.is_manual_multicard?
            render 'validation_manual_multicard'
          else render 'validation_multicard'
          end
        end
        format.text do
          if @share.is_manual_multicard?
            render 'validation_manual_multicard'
          else render 'validation_multicard'
          end
        end
      end
    end
  end

  def leader_paid_for_you(share_id)
    @share = Share.find(share_id)
    logger.info { "ShareMailer leader_paid_for_you email sent to #{share.email} for purchase with share with id #{share.id} related to purchase with id #{share.purchase.id}" }
    with_locale(@share.language) do
      mail to: share.email, subject: t('.subject', first_name: share.purchase.leader_share.first_name) do |format|
        format.mjml
        format.text
      end
    end
  end

  def multicard_failed(share_id)
    @share = Share.find(share_id)
    logger.info { "ShareMailer multicard_failed sent to #{share.email} for purchase with share with id #{share.id} related to purchase with id #{share.purchase.id}" }
    with_locale(@share.language) do
      mail to: share.email, subject: t('.subject', merchant_name: share.purchase.merchant.name) do |format|
        format.mjml do
          if @share.is_manual_multicard?
            render 'manual_multicard_failed'
          else render 'multicard_failed'
          end
        end
        format.text do
          if @share.is_manual_multicard?
            render 'manual_multicard_failed'
          else render 'multicard_failed'
          end
        end
      end
    end
  end

  def manual_multicard_succeeded(share_id)
    @share = Share.find(share_id)
    logger.info { "ShareMailer multicard_succeeded sent to #{share.email} for purchase with share with id #{share.id} related to purchase with id #{share.purchase.id}" }
    with_locale(@share.language) do
      mail to: share.email, subject: t('.subject', merchant_name: share.purchase.merchant.name) do |format|
        format.mjml
        format.text
      end
    end
  end

  private

  attr_reader :share

  def sender
    share.merchant.white_label && share.merchant.sender.present? ? share.merchant.sender : 'LetsPay <noreply@service.letspay.internal>'
  end
end
