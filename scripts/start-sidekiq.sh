#!/bin/bash

bundle check || bundle install

bundle exec sidekiq -q default -q mailers