# frozen_string_literal: true

class MerchantPolicy < ApplicationPolicy

  def show?
    account && account.merchants.exists?(record.id)
  end

  def edit?
    show?
  end

  def update?
    show?
  end

  def cart?
    show?
  end

  def show_transactions?
    show?
  end

  def export_transactions?
    show?
  end
end
