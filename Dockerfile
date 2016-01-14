FROM ruby:1.9
RUN mkdir -p /tmp/shell
WORKDIR /tmp/shell
ADD Gemfile ./
ADD bot.rb ./
ADD start.sh ./

RUN bundle install
