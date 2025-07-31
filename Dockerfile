# Use official PHP base image
FROM php:8.2-fpm

# Set env
ARG NEW_RELIC_LICENSE_KEY
ARG NEW_RELIC_APP_NAME
ARG NEW_RELIC_DAEMON_ADDRESS

# Set working directory inside the container
WORKDIR /var/www/html

# Install system dependencies
RUN apt-get update && apt-get install -y \
    build-essential \
    libpng-dev \
    libjpeg-dev \
    libonig-dev \
    libxml2-dev \
    zip \
    unzip \
    curl \
    git \
    libzip-dev \
    unzip \
    gnupg \
    wget \
    libcurl4-openssl-dev \
    pkg-config \
    libssl-dev \
    libmcrypt-dev

# Install PHP extensions
RUN docker-php-ext-install pdo pdo_mysql mbstring zip exif pcntl bcmath gd

# Install Composer
COPY --from=composer:latest /usr/bin/composer /usr/bin/composer

# Copy Laravel app files
COPY . .

# Install Laravel PHP dependencies
RUN composer install --no-dev --optimize-autoloader

# Set permissions for Laravel
RUN chown -R www-data:www-data /var/www/html/storage /var/www/html/bootstrap/cache

# Install New Relic (replace with your actual values)

RUN curl -L https://download.newrelic.com/php_agent/archive/${NEW_RELIC_AGENT_VERSION}/newrelic-php5-${NEW_RELIC_AGENT_VERSION}-linux.tar.gz | tar -C /tmp -zx \
    && export NR_INSTALL_USE_CP_NOT_LN=1 \
    && export NR_INSTALL_SILENT=1 \
    && /tmp/newrelic-php5-${NEW_RELIC_AGENT_VERSION}-linux/newrelic-install install \
    && rm -rf /tmp/newrelic-php5-* /tmp/nrinstall*

RUN sed -i \
  -e "s/newrelic.license[[:space:]]*=[[:space:]]*.*/newrelic.license = ${NEW_RELIC_LICENSE_KEY}/" \
  -e "s/newrelic.appname[[:space:]]*=[[:space:]]*.*/newrelic.appname = ${NEW_RELIC_APPNAME}/" \
  -e "\$a newrelic.daemon.address=${NEW_RELIC_DAEMON_ADDRESS}" \
  /usr/local/etc/php/conf.d/newrelic.iniLIC_API_KEY=<your_api_key> NEW_RELIC_ACCOUNT_ID=<your_account_id> /usr/local/bin/newrelic install

# Optional: Enable New Relic in CLI scripts too
ENV PHP_INI_SCAN_DIR="/usr/local/etc/php/conf.d"

# Expose port for PHP-FPM (not HTTP directly)
EXPOSE 9000

CMD ["php-fpm"]
