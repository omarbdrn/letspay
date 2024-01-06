# frozen_string_literal: true

class PaymentsChannel < ApplicationCable::Channel
  def subscribed
    share = Share.find(params[:id])
    stream_for share
  end
end
