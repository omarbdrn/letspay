gulp: yarn start
web: bundle exec rails s
worker: bundle exec sidekiq -c 5 -q default -q webhooks -q mailers
release: bundle exec rake db:migrate && yarn run build && bundle exec rake maintenance:sourcemap_trigger
