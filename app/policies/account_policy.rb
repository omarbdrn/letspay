# frozen_string_literal: true

class AccountPolicy < ApplicationPolicy

  def index?
    account.admin?
  end

  def show?
    account.admin? || account == record
  end

  def update?
    account.admin?
  end

  def destroy?
    return false if account == record
    account.admin?
  end
end
