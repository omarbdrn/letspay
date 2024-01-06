namespace :maintenance do
  desc 'Triggering to Rollbar an automatic download of source map'
  task sourcemap_trigger: :environment do
    include ApplicationHelper
    begin
      HTTParty.post("https://api.rollbar.com/api/1/sourcemap/download", body:
        {
          access_token: ENV['ROLLBAR_ACCESS_TOKEN'],
          version: (ENV['HEROKU_SLUG_COMMIT'] || 'unknown-code-version'),
          minified_url: "#{gulp_asset_path('js/payment.js')}"
        }
      )
    rescue
      puts 'Error while trying to trigger source map download from Rollbar'
    end
  end
end
