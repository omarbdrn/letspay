# frozen_string_literal: true

module API
  module Merchants
    module V1
      module Helpers
        extend ActiveSupport::Concern

        included do
          helpers Pundit
          helpers do
            def pundit_user
              current_merchant
            end

            def current_merchant
              @current_merchant ||= Merchant.find_by_api_key(env['API_KEY'])
            end

            def logger
              API::Merchants::V1::Base.logger
            end
          end
        end
      end
    end
  end
end
