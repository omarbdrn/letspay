class AddTicketEmailToMerchants < ActiveRecord::Migration[5.0]
  def change
    add_column :merchants, :email_ticket, :string
  end
end
