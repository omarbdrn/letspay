class AdaptingDiscountModel < ActiveRecord::Migration[5.0]

  def up
    Discount.delete_all
    remove_column  :discounts, :percentage, :integer
    add_monetize   :discounts, :amount
    add_column     :discounts, :code, :string
    add_column     :discounts, :created_at, :datetime, default: nil, null: false
    add_column     :discounts, :updated_at, :datetime, default: nil, null: false
  end

  def down
    add_column        :discounts, :percentage, :integer
    remove_monetize   :discounts, :amount
    remove_column     :discounts, :code, :string
    remove_timestamps :discounts
  end

end
