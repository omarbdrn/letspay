# frozen_string_literal: true

namespace :maintenance do
  desc 'Execute Pre Authorizations'
  task exec_pre_auth: :environment do
    Payments::ExecutePreAuthorizations.new.run
  end
end
