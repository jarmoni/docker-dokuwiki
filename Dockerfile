FROM nginx:1.14.0-alpine

LABEL maintainer="michas <michas@jarmoni.org>"

ARG DOKUWIKI_VERSION=2018-04-22a
ARG DOKUWIKI_CSUM=18765a29508f96f9882349a304bffc03
ARG GITBACKED_PLUGIN_URL=https://github.com/jarmoni/dokuwiki-plugin-gitbacked/archive/master.zip
ARG GITBACKED_PLUGIN_CSUM=d8384ea6be82ccb626bffe512d03d8b0
ARG GITBACKED_PLUGIN_EXTRACTED_NAME=dokuwiki-plugin-gitbacked-master
#ARG DOKUWIKI_DEST=/dokuwiki
ENV DOKUWIKI_DEST=/dokuwiki

RUN apk update && \
    apk upgrade && \
    apk add --update \
    openssl \
    php7 \
    php7-xml \
    php7-xsl \
    php7-pdo \
    php7-mcrypt \
    php7-curl \
    php7-json \
    php7-fpm \
    php7-phar \
    php7-openssl \
    php7-mysqli \
    php7-ctype \
    php7-opcache \
    php7-mbstring \
    php7-session \
    php7-pcntl \
    supervisor \
    openssh-client \
    git && \
    #usermod && \
    rm -fr /var/cache/apk/*

RUN mkdir "$DOKUWIKI_DEST" && \
    wget -q -O /dokuwiki.tgz "http://download.dokuwiki.org/src/dokuwiki/dokuwiki-$DOKUWIKI_VERSION.tgz" && \
    if [ "$DOKUWIKI_CSUM" != "$(md5sum /dokuwiki.tgz | awk '{print($1)}')" ];then echo "Wrong md5sum of downloaded file!"; exit 1; fi && \
    tar -zxf dokuwiki.tgz -C "$DOKUWIKI_DEST" --strip-components 1 && \
    rm /dokuwiki.tgz

RUN wget -q -O /gitbacked.zip "$GITBACKED_PLUGIN_URL" && \
    if [ "$GITBACKED_PLUGIN_CSUM" != "$(md5sum /gitbacked.zip | awk '{print($1)}')" ];then echo "Wrong md5sum of downloaded file!"; exit 1; fi && \
    unzip gitbacked.zip -d "$DOKUWIKI_DEST/lib/plugins" && \
    mv "$DOKUWIKI_DEST/lib/plugins/$GITBACKED_PLUGIN_EXTRACTED_NAME" "$DOKUWIKI_DEST/lib/plugins/gitbacked" && \
    # we need a shell to execute git
    sed -i -e "s|nobody:x:65534:65534:nobody:/:/sbin/nologin|nobody:x:65534:65534:nobody:/:/bin/sh|g" /etc/passwd && \
    rm /gitbacked.zip

# nginx
COPY nginx/nginx.conf /etc/nginx/nginx.conf

# supervisor
COPY supervisor/supervisord.conf /etc/supervisord.conf

# PHP
RUN echo "cgi.fix_pathinfo = 0;" >> /etc/php7/php-fpm.ini && \
    sed -i -e "s|;daemonize\s*=\s*yes|daemonize = no|g" /etc/php7/php-fpm.conf && \
    sed -i -e "s|listen\s*=\s*127\.0\.0\.1:9000|listen = /var/run/php-fpm7.sock|g" /etc/php7/php-fpm.d/www.conf && \
    sed -i -e "s|;listen\.owner\s*=\s*|listen.owner = |g" /etc/php7/php-fpm.d/www.conf && \
    sed -i -e "s|;listen\.group\s*=\s*|listen.group = |g" /etc/php7/php-fpm.d/www.conf && \
    sed -i -e "s|;listen\.mode\s*=\s*|listen.mode = |g" /etc/php7/php-fpm.d/www.conf

COPY entrypoint.sh /entrypoint.sh
EXPOSE 80
ENTRYPOINT [ "/entrypoint.sh" ]
CMD [ "/usr/bin/supervisord", "-c", "/etc/supervisord.conf" ]
