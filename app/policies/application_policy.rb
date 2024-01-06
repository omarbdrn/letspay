# frozen_string_literal: true

class ApplicationPolicy
  attr_reader :account, :record, :payor_info

  def initialize(account, record)
    @account = account
    @payor_info = account
    @record = record
  end

  def index?
    false
  end

  def show?
    scope.where(id: record.id).exists?
  end

  def create?
    false
  end

  def new?
    create?
  end

  def update?
    false
  end

  def edit?
    update?
  end

  def destroy?
    false
  end

  def scope
    Pundit.policy_scope!(account, record.class)
  end

  class Scope
    attr_reader :account, :scope

    def initialize(account, scope)
      @account = account
      @scope = scope
    end

    def resolve
      scope
    end
  end
end
