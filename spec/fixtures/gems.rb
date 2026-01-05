source "https://rubygems.org"
ruby "2.2.1"

gem "oj"
gem "rails", "4.2.0"
gem "leveldb-ruby","0.15", require: "leveldb"
gem "nokogiri", "~> 1.6"
gem "rack", ">= 2.0"
gem "json", "< 3.0"

group :development do
  gem "spring"
  gem "thin"
end

group :production do
  gem "puma"
  gem "rails_12factor"
  gem "bugsnag"
end
