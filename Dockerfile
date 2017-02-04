## -*- docker-image-name: "scaleway/torrents-0.9.6:latest" -*-
FROM scaleway/ubuntu:amd64-xenial
# following 'FROM' lines are used dynamically thanks do the image-builder
# which dynamically update the Dockerfile if needed.
#FROM scaleway/ubuntu:armhf-xenial       # arch=armv7l
#FROM scaleway/ubuntu:arm64-xenial       # arch=arm64
#FROM scaleway/ubuntu:i386-xenial        # arch=i386
#FROM scaleway/ubuntu:mips-xenial        # arch=mips


MAINTAINER Scaleway <opensource@scaleway.com> (@scaleway)


# Prepare rootfs for image-builder
RUN /usr/local/sbin/builder-enter


# Enable multiverse packages
RUN sed -i 's/universe/universe multiverse/' /etc/apt/sources.list


# Install packages
RUN apt-get -q update \
  && apt-get --force-yes -y -qq upgrade \
  && apt-get install -y \
    supervisor \
    rtorrent \
    nginx \
    php7.0-cli php7.0-fpm \
    mediainfo unzip unrar \
    libav-tools \
    vsftpd libpam-pwdfile


#
# Rtorrent configuration
#
RUN adduser rtorrent --disabled-password --gecos '' \
  && mkdir -p /home/rtorrent/downloads/public \
  && mkdir -p /home/rtorrent/sessions \
  && mkdir -p /home/rtorrent/watch \
  && chown -R rtorrent:rtorrent /home/rtorrent/


COPY ./patches/home/rtorrent/dot.rtorrent.rc /home/rtorrent/.rtorrent.rc


# Supervisord configuration
COPY ./patches/etc/supervisor/conf.d/rtorrent.conf /etc/supervisor/conf.d/


#
# ruTorrent configuration
#

# v3.7
ENV RUTORRENT_COMMIT ac2db1536302bdc5b27aff6b15d54b0e9837fa59

# Extract ruTorrent, edit config and remove useless plugins
RUN mkdir -p /var/www/rutorrent/ \
  && curl -sNL https://github.com/Novik/ruTorrent/archive/${RUTORRENT_COMMIT}.tar.gz | tar xzv --strip 1 -C /var/www/rutorrent/ \
  && mv /var/www/rutorrent/conf/config.php /var/www/rutorrent/conf/config_base.php \
  && rm -fr /var/www/rutorrent/plugins/httprpc /var/www/rutorrent/plugins/rpc \
  && mv /var/www/rutorrent/plugins/screenshots/conf.php /var/www/rutorrent/plugins/screenshots/conf_base.php


COPY ./patches/var/www/rutorrent/conf/config.php /var/www/rutorrent/conf/
COPY ./patches/var/www/rutorrent/plugins/screenshots/conf.php /var/www/rutorrent/plugins/screenshots/


# Install h5ai
ENV H5AI_VERSION 0.27.0

RUN curl -L http://release.larsjung.de/h5ai/h5ai-$H5AI_VERSION.zip -o /tmp/h5ai.zip \
  && unzip /tmp/h5ai.zip -d /var/www/ \
  && rm -f /tmp/h5ai.zip \
  && ln -s /home/rtorrent/downloads /var/www/


# Configure nginx
RUN unlink /etc/nginx/sites-enabled/default
COPY ./patches/etc/nginx/sites-available/rutorrent /etc/nginx/sites-available/
RUN ln -s /etc/nginx/sites-available/rutorrent /etc/nginx/sites-enabled/


# Permissions
RUN chown -R www-data:www-data /var/www/


# Index page and installer
COPY ./patches/var/www/index.html /var/www/
COPY ./patches/var/www/credentials.php /var/www/


# Update rtorrent configuration on boot
COPY ./patches/etc/init/update-rtorrent-ip.conf /etc/init/


# Add symlink to downloads folder in /root
RUN ln -s /home/rtorrent/downloads /root/downloads


#
# vsftpd configuration
#

# PAM to make authentication using /var/www/credentials
COPY ./patches/etc/pam.d/vsftpd /etc/pam.d/vsftpd
COPY ./patches/etc/vsftpd.conf /etc/vsftpd.conf
COPY ./patches/etc/init/vsftpd-keys.conf /etc/init/vsftpd-keys.conf

#
# php-fpm configuration
#
COPY ./patches/etc/php7.0/fpm/conf.d/50-scaleway.ini /etc/php7.0/fpm/conf.d/50-scaleway.ini


# Clean rootfs from image-builder
RUN /usr/local/sbin/builder-leave
