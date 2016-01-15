FROM ruby:2.3
RUN mkdir -p /tmp/shell
WORKDIR /tmp/shell

ADD Gemfile ./
RUN bundle install

ADD start.sh ./
RUN chmod +x start.sh
:
ADD bot.rb ./
