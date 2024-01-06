# frozen_string_literal: true

module Ext
  module Grape
    module Middleware
      class PaymentsApiAuth < Rack::Auth::AbstractHandler

        def initialize(*args)
          super
          @logger = LetsPay::Logger.new(%w(API Payments))
        end

        def call(env)
          @auth = Request.new(env)
          Rails.logger.info "\n\nHEYYY#{@auth}\n\n"
          return no_auth_provided unless auth.provided?
          return bad_request unless auth.bearer?
          return invalid_credentials unless valid?(auth)

          @app.call(auth.augmented)
        end

        private

        attr_reader :auth, :logger

        def request
          auth.request
        end

        def no_auth_provided
          logger.warn { "unauthorized: cause=auth_not_provided method=#{request.request_method} path=#{request.path}" }
          unauthorized
        end

        def bad_request
          logger.warn { "unauthorized: cause=wrong_auth_scheme scheme=#{auth.scheme} method=#{request.request_method} path=#{request.path}" }
          super
        end

        def invalid_credentials
          logger.warn { "unauthorized: cause=invalid_credentials method=#{request.request_method} path=#{request.path}" }
          unauthorized
        end

        def challenge
          'Bearer'
        end

        def valid?(auth)
          @authenticator.call(auth.api_key)
        end

        class Request < Rack::Auth::AbstractRequest
          def initialize(env)
            @env = env
          end

          def augmented
            env['API_KEY'] = params
            env
          end

          def bearer?
            scheme == 'bearer'
          end

          def api_key
            params
          end

          private

          attr_reader :env
        end
      end
    end
  end
end
