# frozen_string_literal: true

source "https://rubygems.org"

gem "bcrypt"
gem "pg"
gem "puma"
gem "rack-contrib"
gem "rake"
gem "sinatra"
gem "sinatra-activerecord"
gem "sinatra-contrib", require: false
gem "sinatra-flash"
gem 'securerandom'

group :development do
  gem 'rerun'
end

group :development, :test do
  gem 'debug'
  gem 'fabrication'
  gem 'faker'
end

group :test do
  gem 'capybara'
  gem 'capybara-screenshot'
  gem 'database_cleaner-active_record'
  gem 'rspec'
  gem 'selenium-webdriver'
end
