FROM nginx:1.14.0-alpine

LABEL maintainer="michas <michas@jarmoni.org>"

ARG DOKUWIKI_VERSION=2018-04-22a
ARG DOKUWIKI_CSUM=18765a29508f96f9882349a304bffc03

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
    rm -fr /var/cache/apk/*

RUN mkdir /dokuwiki && \
    wget -q -O /dokuwiki.tgz "http://download.dokuwiki.org/src/dokuwiki/dokuwiki-$DOKUWIKI_VERSION.tgz" && \
    if [ "$DOKUWIKI_CSUM" != "$(md5sum /dokuwiki.tgz | awk '{print($1)}')" ];then echo "Wrong md5sum of downloaded file!"; exit 1; fi && \
    tar -zxf dokuwiki.tgz -C /dokuwiki --strip-components 1 && \
    rm /dokuwiki.tgz

COPY nginx.conf /etc/nginx/conf.d/default.conf
COPY entrypoint.sh /entrypoint.sh

ENTRYPOINT [ "/entrypoint.sh" ]
CMD [ "/usr/bin/supervisord", "-c", "/etc/supervisord.conf" ]