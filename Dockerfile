FROM nginx:1.13

# TODO: nuke caches
RUN sed -r -i -e 's/(\.debian\.org.* main)/\1 contrib non-free/g' /etc/apt/sources.list
# The postgresql-client-9.6 postinstall script fails if /usr/share/man and friends are missing, so recreate them
RUN mkdir -p /usr/share/man/man1 /usr/share/man/man7
RUN apt-get update && apt-get -y install php7.0-fpm php7.0-pgsql imagemagick postgresql-client supervisor nano lynx unzip

ADD https://releases.wikimedia.org/mediawiki/1.30/mediawiki-1.30.0.tar.gz /var/www/mediawiki.tar.gz
# COPY mediawiki-1.30.0.tar.gz /var/www/mediawiki.tar.gz
RUN cd /var/www && tar -xzf mediawiki.tar.gz && mv mediawiki-* mediawiki && rm /var/www/mediawiki.tar.gz

ADD https://github.com/kulttuuri/slack_mediawiki/archive/1.10.zip /app/slack_mediawiki.zip
RUN unzip /app/slack_mediawiki.zip -d /app/ && mv /app/slack_mediawiki-*/SlackNotifications /var/www/mediawiki/extensions/ && rm -rf /app/slack_mediawiki.zip /app/slack_mediawiki-*

ADD nginx.conf /etc/nginx/conf.d/mediawiki.conf
ADD supervisord.conf /app/
RUN rm /etc/nginx/conf.d/default.conf
RUN usermod -a -G www-data nginx
RUN mkdir -p /run/php

EXPOSE 8080

CMD supervisord -c /app/supervisord.conf
