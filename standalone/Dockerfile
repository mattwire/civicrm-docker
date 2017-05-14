FROM debian:jessie

# packages
RUN \
  echo "mysql-server-5.5 mysql-server/root_password password root" | debconf-set-selections \
  && echo "mysql-server-5.5 mysql-server/root_password_again password root" | debconf-set-selections \
  && apt-get update \
  && apt-get install -y \
    php5 \
    man-db \
    mysql-server \
    git \
    vim \
    bzip2 \
    zip \
    unzip \
    php5-curl \
    mcrypt \
    php5-mcrypt \
    php5-mysql \
    curl \
    wget \
    php5-gd \
    php5-imap \
    php5-intl \
    php5-xdebug

# mysql config
RUN sed -i -e"s/^bind-address\s*=\s*127.0.0.1/bind-address = 0.0.0.0/" /etc/mysql/my.cnf

# php config
ADD xdebug.ini /etc/php5/mods-available/xdebug.ini
ADD php.ini /etc/php5/apache2
ADD php.ini /etc/php5/cli

# nodejs
RUN curl -sL https://deb.nodesource.com/setup_5.x | bash - \
  && apt-get -y install nodejs \
  && npm install npm -g

# buildkit
RUN git clone https://github.com/civicrm/civicrm-buildkit.git /opt/buildkit \
  && ./opt/buildkit/bin/civi-download-tools \
  && echo export PATH="/opt/buildkit/bin:\$PATH" >> /root/.bashrc \
  && echo "Include /root/.amp/apache.d/*" | tee -a /etc/apache2/apache2.conf \
  && a2enmod rewrite

RUN echo '{ "allow_root": true }' >> /root/.bowerrc
ADD amp_config.yml /root/.amp/services.yml
RUN mkdir -p /root/.amp/apache.d/ && touch /root/.amp/apache.d/null.conf

RUN rm -rf /etc/supervisor && apt-get install -y supervisor
ADD supervisord.conf /etc/supervisor/supervisord.conf

# create civicrm build
RUN /opt/buildkit/bin/civibuild download "test-build" --civi-ver "master" --type "drupal-clean"
RUN service mysql start && /opt/buildkit/bin/civibuild install "test-build" --url "http://localhost:8000" --admin-pass "admin"
RUN chmod -R 777 /opt/buildkit/build/test-build/sites/default/files/

ENV TERM xterm

EXPOSE 80 3306

ADD entrypoint.sh /root/
RUN chmod +x /root/entrypoint.sh
ENTRYPOINT /root/entrypoint.sh
