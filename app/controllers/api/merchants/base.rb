# frozen_string_literal: true

module API
  module Merchants
    class Base < Grape::API
      prefix 'merchants/'

      mount API::Merchants::V1::Base
    end
  end
end
