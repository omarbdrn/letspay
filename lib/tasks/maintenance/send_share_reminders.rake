namespace :maintenance do
  desc 'Send reminders to unpaid share letspayers'
  task send_shares_reminders: :environment do
    SendSharesRemindersJob.perform_later
  end
end
