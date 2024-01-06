# frozen_string_literal: true

namespace :maintenance do
  desc 'Close multicard purchase leader last chance rounds'
  task close_leader_last_chance_round: :environment do
    Payments::Multicard::CloseLeaderLastChanceRound.new.run
  end
end
