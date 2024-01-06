# frozen_string_literal: true

class PreAuthorizationPolicy < ApplicationPolicy

  def force_execution?
    pre_authorization = record
    pre_authorization.can_be_executed_now? && account.admin?
  end

end
