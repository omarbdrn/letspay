source 'https://rubygems.org'

ruby '3.0.0'

git_source(:github) do |repo_name|
  repo_name = "#{repo_name}/#{repo_name}" unless repo_name.include?('/')
  "https://github.com/#{repo_name}.git"
end

# Flexible authentication solution for Rails with Warden (https://github.com/plataformatec/devise)
gem 'devise', '~> 4.3.0'
# Devise Async provides an easy way to configure Devise to send its emails asynchronously using ActiveJob.
gem 'devise-async', '~> 1.0'
# Translations for the devise gem (http://github.com/tigrish/devise-i18n)
gem 'devise-i18n'
# A comprehensive slugging and pretty-URL plugin. (http://github.com/norman/friendly_id)
gem 'friendly_id', '~> 5.0.0'
# A pagination engine plugin for Rails 4+ and other modern frameworks (https://github.com/kaminari/kaminari)
gem 'kaminari'
# A fast JSON parser and serializer. (http://www.ohler.com/oj)
gem 'oj'
# Pg is the Ruby interface to the {PostgreSQL RDBMS}[http://www.postgresql.org/] (https://bitbucket.org/ged/ruby-pg)
gem 'pg', '~> 0.18'
# Puma is a simple, fast, threaded, and highly concurrent HTTP 1.1 server for Ruby/Rack applications (http://puma.io)
gem 'puma', '~> 3.0'
# OO authorization for Rails (https://github.com/elabs/pundit)
gem 'pundit'
# Full-stack web application framework. (http://rubyonrails.org)
gem 'rails', '~> 5.0.4'
# Common locale data and translations for Rails i18n. (http://github.com/svenfuchs/rails-i18n)
gem 'rails-i18n', '~> 5.0.0'
# A Ruby client library for Redis (https://github.com/redis/redis-rb)
gem 'redis'
# Sass adapter for the Rails asset pipeline. (https://github.com/rails/sass-rails)
gem 'sass-rails', '~> 5.0'
# Ruby wrapper for UglifyJS JavaScript compressor (http://github.com/lautis/uglifier)
gem 'uglifier', '>= 1.3.0'

# Official Rails Liana for Forest
gem 'forest_liana'
# A simple Ruby framework for building REST-like APIs. (https://github.com/ruby-grape/grape)
gem 'grape'
# Use active_model_serializer in grape (https://github.com/ruby-grape/grape-active_model_serializers)
gem 'grape-active_model_serializers'
# Grape API routes (https://github.com/syedmusamah/grape_on_rails_routes)
gem 'grape_on_rails_routes'
# Automatic strong parameter detection with Hashie and Forbidden Attributes. Formerly known as hashie_rails (https://github.com/Maxim-Filimonov/hashie-forbidden_attributes)
gem 'hashie-forbidden_attributes'
# Makes http fun! Also, makes consuming restful web services dead easy. (http://jnunemaker.github.com/httparty)
gem 'httparty', '~> 0.15.5'
# Ruby bindings for the version 2 of the MANGOPAY API (http://docs.mangopay.com/)
gem 'mangopay', '~> 3.0', '>= 3.0.28'
# Money gem integration with Rails (https://github.com/RubyMoney/money-rails)
gem 'money-rails'
# Logentries plugin (https://github.com/rapid7/le_ruby)
gem 'le', '~> 2.7', '>= 2.7.6'
# Reports exceptions to Rollbar (https://rollbar.com)
gem 'rollbar', '~> 2.15', '>= 2.15.5'
# Simple, efficient background processing for Ruby (http://sidekiq.org)
gem 'sidekiq'
# Library for validating urls in Rails. (http://github.com/perfectline/validates_url/tree/master)
gem 'validate_url'
# Object-based searching for Active Record and Mongoid (currently). (https://github.com/activerecord-hackery/ransack)
gem 'ransack'
# Middleware for enabling Cross-Origin Resource Sharing in Rack apps (https://github.com/cyu/rack-cors)
gem 'rack-cors', '~> 1.0.2', :require => 'rack/cors'
# Roo provides an interface to spreadsheets of several sorts (https://github.com/roo-rb/roo)
gem "roo", "~> 2.7.0"
# Country Select Plugin (https://github.com/stefanpenner/country_select)
gem 'country_select', '~> 3.1', '>= 3.1.1'
# Enumerated attributes with I18n and ActiveRecord/Mongoid/MongoMapper support (https://github.com/brainspec/enumerize)
gem 'enumerize', '~> 2.1', '>= 2.1.2'
# IBAN validator (https://github.com/alphasights/iban-tools)
gem 'iban-tools', '~> 1.1'
# Render MJML + ERb template views in Rails
gem 'mjml-rails', '~> 2.4', '>= 2.4.3'
# activejob-retry provides automatic retry functionality for failed ActiveJobs, with exponential backoff
gem 'activejob-retry', '~> 0.6.3'

group :development, :test do
  # Pretty print Ruby objects with proper indentation and colors (https://github.com/awesome-print/awesome_print)
  gem 'awesome_print'
  # help to kill N+1 queries and unused eager loading. (http://github.com/flyerhzm/bullet)
  gem 'bullet'
  # Ruby 2.0 fast debugger - base + CLI (http://github.com/deivid-rodriguez/byebug)
  gem 'byebug', platform: :mri
  # Autoload dotenv in Rails. (https://github.com/bkeepers/dotenv)
  gem 'dotenv-rails'
  # Simple Rails app configuration (https://github.com/laserlemon/figaro)
  gem 'figaro', '~> 1.1', '>= 1.1.1'
  # Manage localization and translation with the awesome power of static analysis (https://github.com/glebm/i18n-tasks)
  gem 'i18n-tasks'
  # Fast debugging with Pry. (https://github.com/deivid-rodriguez/pry-byebug)
  gem 'pry-byebug'
  # Use Pry as your rails console (https://github.com/rweng/pry-rails)
  gem 'pry-rails'
  # RSpec for Rails (https://github.com/rspec/rspec-rails)
  gem 'rspec-rails', '~> 3.6.0'
  # Extends Rails seeds to split out complex seeds into their own file and have different seeds for each environment. (http://github.com/james2m/seedbank)
  gem 'seedbank'
end

group :development, :test, :staging do
  # factory_girl_rails provides integration between factory_girl and rails 3 or newer (http://github.com/thoughtbot/factory_girl_rails)
  gem 'factory_girl_rails'
  # Easily generate fake data (https://github.com/stympy/faker)
  gem 'faker', '~> 1.8', '>= 1.8.7'
end

group :development do
  # Access an IRB console on exception pages or by using <%= console %> anywhere in the code.
  # Listen to file modifications (https://github.com/guard/listen)
  gem 'listen', '~> 3.0.5'
  # A debugging tool for your Ruby on Rails applications. (https://github.com/rails/web-console)
  gem 'web-console', '>= 3.3.0'
  # Spring speeds up development by keeping your application running in the background. Read more: https://github.com/rails/spring
  # Rails application preloader (https://github.com/rails/spring)
  gem 'spring'
  # rspec command for spring (https://github.com/jonleighton/spring-commands-rspec)
  gem 'spring-commands-rspec'
  # Makes spring watch files using the listen gem. (https://github.com/jonleighton/spring-watcher-listen)
  gem 'spring-watcher-listen', '~> 2.0.0'

  # Annotates Rails Models, routes, fixtures, and others based on the database schema. (http://github.com/ctran/annotate_models)
  gem 'annotate'
  # Guard keeps an eye on your file modifications (http://guardgem.org)
  gem 'guard'
  # Guard gem for Brakeman (https://github.com/guard/guard-brakeman)
  gem 'guard-brakeman', require: false
  # Guard gem for Bundler (https://rubygems.org/gems/guard-bundler)
  gem 'guard-bundler', require: false
  # guard + bundler-audit = security (https://github.com/christianhellsten/guard-bundler-audit)
  gem 'guard-bundler-audit', require: false
  # Guard plugin for Reek (https://github.com/grantspeelman/guard-reek)
  gem 'guard-reek', require: false
  # Guard gem for RSpec (https://github.com/guard/guard-rspec)
  gem 'guard-rspec', require: false
  # Guard plugin for RuboCop (https://github.com/yujinakayama/guard-rubocop)
  gem 'guard-rubocop', require: false
  # Preview mail in browser instead of sending. (http://github.com/ryanb/letter_opener)
  gem 'letter_opener'
  # Entity-relationship diagram for your Rails models. (https://github.com/voormedia/rails-erd)
  gem 'rails-erd'
end

group :test do
  # Capybara aims to simplify the process of integration testing Rack applications, such as Rails, Sinatra or Merb (https://github.com/teamcapybara/capybara)
  gem 'capybara'
  # Uploads Ruby test coverage data to Code Climate. (https://github.com/codeclimate/ruby-test-reporter)
  gem 'codeclimate-test-reporter', '~> 1.0.0'
  # Strategies for cleaning databases.  Can be used to ensure a clean state for testing. (http://github.com/DatabaseCleaner/database_cleaner)
  gem 'database_cleaner'
  # Ruby JSON Schema Validator (http://github.com/ruby-json-schema/json-schema/tree/master)
  gem 'json-schema'
  # Making tests easy on the fingers and eyes (http://thoughtbot.com/community/)
  gem 'shoulda-matchers'
  # Code coverage for Ruby 1.9+ with a powerful configuration library and automatic merging of coverage across test suites (http://github.com/colszowka/simplecov)
  gem 'simplecov'
  # Record your test suite's HTTP interactions and replay them during future test runs for fast, deterministic, accurate tests. (http://vcr.github.io/vcr)
  gem 'vcr'
  # Library for stubbing HTTP requests in Ruby. (http://github.com/bblimke/webmock)
  gem 'webmock'
  # Extracting `assigns` and `assert_template` from ActionDispatch. (https://github.com/rails/rails-controller-testing)
  gem 'rails-controller-testing'
end
