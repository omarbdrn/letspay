module Payments
  class ExecutePreAuthorizations

    def run
      ::PreAuthorization.where(mango_status: Mango::SUCCEEDED_OPERATION_STATUS, pay_in_executed_at: nil).find_each do |pre_auth|
        execute(pre_auth) if pre_auth.should_be_executed_now?
        if pre_auth.manual_multicard_should_be_executed_now?
          share = pre_auth.traceable
          MulticardPurchaseSucceededJob.perform_later(share.purchase.id)
        end
      end
    end

    def force_execution_for_purchase(purchase)
      execute(purchase.leader_share.pre_authorization) if can_execute_pre_auth_for_purchase?(purchase)
    end

    def force_execution_for_share(share)
      execute_for_multicard_share(share.pre_authorization) if can_execute_pre_auth_for_share?(share)
    end

    def execute(pre_auth)
      request = ::Mango::PayIn.new
      operation = request.create_from_pre_authorization(pre_auth.id)
      if request.success? && operation.mango_status == Mango::SUCCEEDED_OPERATION_STATUS
        pre_auth.pay_in_executed_at = Time.zone.now
        pre_auth.pay_in_mango_id = operation.id
        pre_auth.save
        pre_auth.purchase.update(state: :SUCCESSFUL)
        PurchaseMailer.confirmation(pre_auth.purchase.id).deliver_later
      end
    end

    def execute_for_multicard_share(pre_auth)
      request = ::Mango::PayIn.new
      operation = request.create_from_share_pre_authorization(pre_auth.id)
      if request.success? && operation.mango_status == Mango::SUCCEEDED_OPERATION_STATUS
        pre_auth.pay_in_executed_at = Time.zone.now
        pre_auth.pay_in_mango_id = operation.id
        pre_auth.save
      end
    end

    private
    def can_execute_pre_auth_for_purchase?(purchase)
      pre_auth = purchase.try(:leader_share).try(:pre_authorization)
      pre_auth.present? && pre_auth.can_be_executed_now?
    end
    def can_execute_pre_auth_for_share?(share)
      pre_auth = share.try(:pre_authorization)
      pre_auth.present? && pre_auth.can_be_executed_now?
    end
  end
end
