module MangoHelper

  BASE_URL = ENV['MANGO_DASHBOARD_URL']

  def admin_link_to_mango_dashboard(operation)
    category = mango_category(operation.type)
    if category.present?
      link_to operation.mango_id, mango_url(category, operation.mango_id), target: :_blank
    else
      operation.mango_id
    end
  end

  private

  def mango_url(category, mango_id)
    raise("Environment variable missing : MANGO_DASHBOARD_URL") if BASE_URL.blank?
    "#{BASE_URL}/#{category}/#{mango_id}"
  end

  def mango_category(type)
    case type
    when 'PreAuthorization'
      'Preauthorizations'
    when 'PayIn'
      'Users/PayIn'
    when 'Transfer'
      'Users/Transfer'
    end
  end
end
