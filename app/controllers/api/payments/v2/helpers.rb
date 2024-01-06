# frozen_string_literal: true

module API
  module Payments
    module V2
      module Helpers
        extend ActiveSupport::Concern

        included do
          helpers Pundit
          helpers do
            def pundit_user
              current_payor_info
            end

            def current_payor_info
              @current_payor_info ||= PayorInfo.find_by_api_key(env['API_KEY'])
            end

            def logger
              API::Payments::V2::Base.logger
            end
          end
        end
      end
    end
  end
end
