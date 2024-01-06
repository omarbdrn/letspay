# frozen_string_literal: true

module API
  module Helpers
    extend ActiveSupport::Concern

    included do
      # formatter :json, Grape::Formatter::ActiveModelSerializers

      helpers do
        def permitted_params
          @permitted_params ||= declared(params, include_missing: false)
        end

        def api_error(err_code, err_msg = nil)
          messages_mapping = {
            404 => 'Record not found',
            403 => 'Access forbidden',
            409 => 'Record invalid'
          }

          unless err_msg.present?
            err_msg = messages_mapping.fetch(err_code, 'An error occured')
          end
          error!({ error: err_msg, status: err_code }, err_code)
        end

        def logger
          API::Base.logger
        end
      end
    end
  end
end
