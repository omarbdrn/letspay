require 'ext/grape/middleware/merchants_api_auth'
require 'ext/grape/middleware/payments_api_auth'

Grape::Middleware::Auth::Strategies.add(:merchants_api_auth, Ext::Grape::Middleware::MerchantsApiAuth, ->(options) { [] } )
Grape::Middleware::Auth::Strategies.add(:payments_api_auth, Ext::Grape::Middleware::PaymentsApiAuth, ->(options) { [] } )
