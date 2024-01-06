class LetsPayerMerchantOptin < ApplicationRecord
  belongs_to :payor_info
  belongs_to :merchant
end
