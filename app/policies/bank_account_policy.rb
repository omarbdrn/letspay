# frozen_string_literal: true

class BankAccountPolicy < ApplicationPolicy

  def show?
    account && authorized_related_merchant_if_present?
  end

  def edit?
    show?
  end

  def update?
    show?
  end

  def create?
    show?
  end

  private

  def authorized_related_merchant_if_present?
    record.merchant.blank? || (account.merchants.exists?(record.merchant.id))
  end
end
