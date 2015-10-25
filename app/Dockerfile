FROM ruby:2.2-onbuild
MAINTAINER Felix Seidel <felix@seidel.me>

ENV RACK_ENV production
RUN useradd -u 500 core
USER core
CMD ["bundle", "exec", "ruby", "app.rb"]
EXPOSE 4567
