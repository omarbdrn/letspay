# frozen_string_literal: true

namespace :maintenance do
  desc 'Execute PayOut'
  task exec_pay_out: :environment do
    Payments::ExecutePayOuts.new.run
  end
end
