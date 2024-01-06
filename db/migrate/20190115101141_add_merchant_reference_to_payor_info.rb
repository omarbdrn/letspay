class AddMerchantReferenceToPayorInfo < ActiveRecord::Migration[5.0]
  def change
    add_column :payor_infos, :merchant_reference, :string
  end
end
