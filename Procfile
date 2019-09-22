web: bundle exec puma -C config/puma.rb
worker: bundle exec sidekiq -q data -q notifications
release: bundle exec rake db:migrate