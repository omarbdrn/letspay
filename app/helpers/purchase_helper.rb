module PurchaseHelper

  def state_label(purchase)
    state_classes = {
      'CANCELLED'           => 'status--cancelled',
      'FAILED'              => 'status--cancelled',
      'LEADER_PROCESSED'    => 'status--successful',
      'SUCCESSFUL'          => 'status--successful',
      'PARTIALLY_REFUNDED'  => 'status--refunded',
      'REFUNDED'            => 'status--refunded',
      'WAITING_MERCHANT_VALIDATION' => 'status--waiting_merchant_validation'
    }
    content_tag :div, purchase.state, class: "status #{state_classes[purchase.state]}"
  end

  def scope_filter_button(merchant, scope)
    is_active = params[:scope].nil? ? (scope == "successful") : (params[:scope] == scope)
    status_div = scope == "all" ? content_tag(:div, '') : content_tag(:div, '', class: "status status--#{scope}")

    link_to merchant_purchases_path(merchant, scope: scope), class: "listTab-item-link #{'is-active' if is_active}" do
      status_div +
      I18n.t("merchants.purchases.index.filter_buttons.#{scope}") +
      content_tag(:span, merchant.purchases.try(scope).count, class: 'listTab-item-link-number')
    end
  end
end
