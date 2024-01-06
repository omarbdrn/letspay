class AddPayoutSummaryEmailToMerchant < ActiveRecord::Migration[5.0]
  def change
    add_column :merchants, :payout_summary_email, :string
  end
end
