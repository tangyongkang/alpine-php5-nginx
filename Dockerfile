#se Image
FROM alpine:3.4

#RUN sed -i 's/dl-cdn.alpinelinux.org/mirrors.tuna.tsinghua.edu.cn/g' /etc/apk/repositories
# ensure www-data user exists
#RUN set -x \
#	&& addgroup -g 82  -S www-data \
#	&& adduser -u 82 -D -S -G www-data www-data

# Environments
ENV TIMEZONE            PRC
ENV PHP_MEMORY_LIMIT    1280M
ENV MAX_UPLOAD          64M
ENV PHP_MAX_FILE_UPLOAD 20
ENV PHP_MAX_POST        64M
ENV COMPOSER_ALLOW_SUPERUSER 1

#2.ADD-PHP-FPM
# Mirror mirror switch to Alpine Linux - http://dl-4.alpinelinux.org/alpine/
RUN apk --update add --no-cache --update \
		curl \
		tzdata \
		php5-cli\
	    php5-common \
	    php5-fpm \
	    php5-bcmath \
	    php5-calendar \
	    php5-ftp \
	    php5-gettext \
	    php5-iconv \
	    php5-pdo_sqlite \
	    php5-posix \
	    php5-soap \
	    php5-dev \
	    php5-sockets \
	    php5-sqlite3 \
	    php5-wddx \
	    php5-xmlreader \
	    php5-xmlrpc \
	    php5-memcache \
	    php5-dev \
	    php5-pear \
	    php5-ctype \
	    php5-curl \
	    php5-json \
	    php5-mysql \
	    php5-openssl \
	    php5-pdo \
	    php5-mysqli \
	    php5-pdo_mysql \
	    php5-phar \
	    php5-xml \
	    php5-mcrypt \
		php5-zip \
	    php5-zlib \
	    php5-dom \
	    php5-gd \
 	&& cp /usr/share/zoneinfo/${TIMEZONE} /etc/localtime \
	&& echo "${TIMEZONE}" > /etc/timezone \
	&& apk del tzdata \
 	&& rm -rf /var/cache/apk/*

## 添加redis 扩展
#RUN apk add --no-cache --update libmemcached-libs zlib
#RUN apk add --no-cache --update --virtual .phpize-deps  autoconf file g++ gcc libc-dev make pkgconf re2c
#
#RUN curl -L -o /tmp/redis.tar.gz https://github.com/phpredis/phpredis/archive/4.0.2.tar.gz \
#    && tar xfz /tmp/redis.tar.gz \
#    && rm -r /tmp/redis.tar.gz \
#    && chmod +x phpredis-4.0.2 \
#    && cd  phpredis-4.0.2 \
#    && /usr/bin/phpize \
#    && ./configure --with-php-config=/usr/bin/php-config\
#    && make && make install \
#    && cd /  && rm -rf /phpredis-4.0.2


## 安装redis 服务器
#RUN apk --update add --no-cache --update redis
#COPY ./redis/redis.conf /etc/


# 安装 wkhtmltopdf 服务
#RUN curl -L -o /tmp/wkhtmltox.tar.xz https://github.com/wkhtmltopdf/wkhtmltopdf/releases/download/0.12.4/wkhtmltox-0.12.4_linux-generic-amd64.tar.xz
#apk --update add --no-cache --update ttf-wqy-zenhei fonts-wqy-microhei

# 安装 php-wkhtmltox 扩展
#RUN curl -L -o /tmp/wkhtmltox.zip https://github.com//mreiferson/php-wkhtmltox/archive/master.zip \
#   && unzip wkhtmltox.zip \
#   && rm wkhtmltox.zip \
#   && cd php-wkhtmltox-master \
#   && /usr/bin/phpize
#   && ./configure --with-php-config=/usr/bin/php-config
#   && make && make install \
#   && cd /tmp && rm -rf /tmp/php-wkhtmltox-master



RUN mkdir -p /usr/local/var/log/php5/
RUN mkdir -p /usr/local/var/run/
COPY php/php-fpm.conf /etc/php5/
COPY php/www.conf /etc/php5/php-fpm.d/


# Set environments
RUN sed -i "s|;*date.timezone =.*|date.timezone = ${TIMEZONE}|i" /etc/php5/php.ini && \
	sed -i "s|;*memory_limit =.*|memory_limit = ${PHP_MEMORY_LIMIT}|i" /etc/php5/php.ini && \
	sed -i "s|;*upload_max_filesize =.*|upload_max_filesize = ${MAX_UPLOAD}|i" /etc/php5/php.ini && \
	sed -i "s|;*max_file_uploads =.*|max_file_uploads = ${PHP_MAX_FILE_UPLOAD}|i" /etc/php5/php.ini && \
	sed -i "s|;*post_max_size =.*|post_max_size = ${PHP_MAX_POST}|i" /etc/php5/php.ini && \
	sed -i "s|;*cgi.fix_pathinfo=.*|cgi.fix_pathinfo= 0|i" /etc/php5/php.ini   && \
	sed -i 's,;session.save_path = "/tmp",session.save_path = "/tmp",g' /etc/php5/php.ini


#3.Install-Composer
RUN curl -sS https://getcomposer.org/installer |  \
    php -- --install-dir=/usr/local/bin --filename=composer

#4.ADD-NGINX
RUN apk --update add --no-cache --update nginx
COPY nginx/conf.d/default.conf /etc/nginx/conf.d/
COPY nginx/nginx.conf /etc/nginx/
#COPY nginx/rewrite.conf /etc/nginx/
COPY nginx/cert /etc/nginx/cert/

RUN mkdir -p /usr/share/nginx/html/public/
COPY php/index.php /usr/share/nginx/html/public/


VOLUME ["/usr/share/nginx/html", "/usr/local/var/log/php5", "/var/run/"]
WORKDIR /usr/share/nginx/html

#5.ADD-SUPERVISOR
RUN apk --update add --no-cache --update supervisor \
 && rm -rf /var/cache/apk/*


# Define mountable directories.
VOLUME ["/etc/supervisor/conf.d", "/var/log/supervisor/"]
COPY supervisor/conf.d /etc/supervisor/conf.d/

#6.ADD-CRONTABS
COPY crontabs/default /var/spool/cron/crontabs/
RUN cat /var/spool/cron/crontabs/default >> /var/spool/cron/crontabs/root
RUN mkdir -p /var/log/cron \
 && touch /var/log/cron/cron.log

VOLUME /var/log/cron

#8.ADD-MARIADB
#RUN apk add mariadb=10.3.12-r2
#VOLUME /var/lib/mysql

#设置环境变量，便于管理
#ENV MARIADB_USER root
#ENV MARIADB_PASS 123456
##初始化数据库
#COPY ./mariadb/db_init.sh /etc/
#RUN chmod 775 /etc/db_init.sh
#RUN /etc/db_init.sh

#导出端口
#EXPOSE 3306

#添加启动文件
#ADD ./mariadb/run.sh /root/run.sh
#RUN chmod 775 /root/run.sh
#设置默认启动命令
#CMD ["/root/run.sh"]

#9.添加启动脚本
# Define working directory.
WORKDIR /usr/share/nginx/html
COPY entrypoint.sh /usr/share/nginx/html/
RUN chmod +x /usr/share/nginx/html/entrypoint.sh

#CMD ["supervisord", "--nodaemon", "--configuration", "/etc/supervisor/conf.d/supervisord.conf"]
ENTRYPOINT ["./entrypoint.sh"]

