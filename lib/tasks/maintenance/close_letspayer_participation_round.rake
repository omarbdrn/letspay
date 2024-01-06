# frozen_string_literal: true

namespace :maintenance do
  desc 'Close multicard purchase letspayer participation round'
  task close_letspayer_participation_round: :environment do
    Payments::Multicard::CloseLetsPayerParticipationRound.new.run_for_multicard
    Payments::Multicard::CloseLetsPayerParticipationRound.new.run_for_manual_multicard
  end
end
