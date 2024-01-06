require 'open-uri'

HEROKU_REVIEW_APP_ASSETS = ENV['HEROKU_APP_NAME'] ? "/#{ENV['HEROKU_APP_NAME']}" : "/#{Rails.env}"

remote_url = "#{ENV['CDN_URL']}#{HEROKU_REVIEW_APP_ASSETS}/assets/rev-manifest.json" if ENV['CDN_URL']

REV_MANIFEST = begin
                 JSON.parse(open(remote_url || 'public/assets/rev-manifest.json').read)
               rescue
                 nil
               end
