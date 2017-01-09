FROM nginx:1.11

# TODO: nuke caches
RUN sed -r -i -e 's/(\.debian\.org.* main)/\1 contrib non-free/g' /etc/apt/sources.list
RUN apt-get update && apt-get -y install php5-fpm php5-pgsql imagemagick postgresql-client supervisor nano lynx

ADD https://releases.wikimedia.org/mediawiki/1.28/mediawiki-1.28.0.tar.gz /var/www/mediawiki.tar.gz
# COPY mediawiki-1.28.0.tar.gz /var/www/mediawiki.tar.gz
RUN cd /var/www && tar -xzf mediawiki.tar.gz && mv mediawiki-* mediawiki && rm /var/www/mediawiki.tar.gz

ADD nginx.conf /etc/nginx/conf.d/mediawiki.conf
ADD supervisord.conf /app/
RUN rm /etc/nginx/conf.d/default.conf
RUN usermod -a -G www-data nginx

EXPOSE 8080

CMD supervisord -c /app/supervisord.conf

