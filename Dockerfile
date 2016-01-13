FROM ruby:1.9
RUN mkdir -p /tmp/shell
WORKDIR /tmp/shell
ADD Gemfile ./
ADD hoge.rb ./
ADD id2name ./

RUN bundle install
