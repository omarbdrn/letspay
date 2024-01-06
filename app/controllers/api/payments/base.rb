# frozen_string_literal: true

module API
  module Payments
    class Base < Grape::API
      prefix 'payments/'

      mount API::Payments::V1::Base
      mount API::Payments::V2::Base
    end
  end
end
