FROM ubuntu:22.04

LABEL org.opencontainers.image.authors="andrew.stephanoff@gmail.com"
LABEL devcontainer.metadata='[{ \
    "customizations": { \
        "vscode": { \
            "extensions": [ \
                "bmewburn.vscode-intelephense-client", \
                "bradlc.vscode-tailwindcss", \
                "devsense.composer-php-vscode", \
                "eamodio.gitlens", \
                "editorconfig.editorconfig", \
                "esbenp.prettier-vscode", \
                "open-southeners.laravel-pint", \
                "porifa.laravel-intelephense", \
                "xdebug.php-debug", \
                "vue.volar" \
            ] \
        } \
    } \
}]'

ARG DEBIAN_FRONTEND="noninteractive"
ARG SAIL_GID=1000
ARG SAIL_UID=1000
ARG TZ="UTC"
ARG XDEBUG_PORT=9003

ENV LARAVEL_SAIL=1

ADD https://deb.nodesource.com/gpgkey/nodesource-repo.gpg.key /tmp/nodesource-repo.gpg.key

RUN ln -snf /usr/share/zoneinfo/${TZ} /etc/localtime && echo ${TZ} > /etc/timezone \
    && apt-get update \
    && apt-get install --yes \
        curl \
        gpg \
        software-properties-common \
    && cat /tmp/nodesource-repo.gpg.key | gpg --dearmor --output /usr/share/keyrings/nodesource.gpg \
    && echo "deb [signed-by=/usr/share/keyrings/nodesource.gpg] https://deb.nodesource.com/node_18.x nodistro main" > /etc/apt/sources.list.d/nodesource.list \
    && add-apt-repository ppa:ondrej/php \
    && apt-get update \
    && apt-get install --yes \
        git \
        mysql-client \
        nodejs \
        php8.3-bcmath \
        php8.3-cli \
        php8.3-curl \
        php8.3-gd \
        php8.3-imap \
        php8.3-igbinary \
        php8.3-imagick \
        php8.3-intl \
        php8.3-ldap \
        php8.3-mbstring \
        php8.3-memcached \
        php8.3-msgpack \
        php8.3-mysql \
        php8.3-pcov \
        php8.3-readline \
        php8.3-redis \
        php8.3-soap \
        php8.3-swoole \
        php8.3-xdebug \
        php8.3-xml \
        php8.3-zip \
        sudo \
        unzip \
        vim \
        zsh \
    && apt-get autoremove --yes \
    && apt-get clean \
    && rm -rf /tmp/* /var/tmp/* /usr/local/src/* \
    && npm install --global bun npm pnpm \
    && curl -sLS https://getcomposer.org/installer | php -- --install-dir=/usr/local/bin/ --filename=composer \
    && groupadd --force --gid ${SAIL_GID} sail \
    && useradd --create-home --no-user-group --shell /usr/bin/zsh --groups sudo,www-data --gid ${SAIL_GID} --uid ${SAIL_UID} sail \
    && echo sail ALL=\(root\) NOPASSWD:ALL > /etc/sudoers.d/sail \
    && chmod 0440 /etc/sudoers.d/sail \
    && mkdir -p /home/sail/.composer /home/sail/.cache /srv/www \
    && chown -R sail: /home/sail/.composer /home/sail/.cache /srv/www \
    && chsh -s /usr/bin/zsh

ADD xdebug.ini /etc/php/8.3/mods-available/xdebug.ini
ADD --chmod=775 php-xdbg /usr/local/bin/
ADD https://github.com/ohmyzsh/ohmyzsh.git#master /root/.oh-my-zsh
ADD https://github.com/zsh-users/zsh-autosuggestions.git#master /root/.oh-my-zsh/custom/plugins/zsh-autosuggestions
ADD https://github.com/zsh-users/zsh-syntax-highlighting.git#master /root/.oh-my-zsh/custom/plugins/zsh-syntax-highlighting
ADD https://github.com/romkatv/powerlevel10k.git#master /root/.oh-my-zsh/custom/themes/powerlevel10k
ADD .p10k.zsh .zshrc /root/
ADD --chown=sail:sail https://github.com/ohmyzsh/ohmyzsh.git#master /home/sail/.oh-my-zsh
ADD --chown=sail:sail https://github.com/zsh-users/zsh-autosuggestions.git#master /home/sail/.oh-my-zsh/custom/plugins/zsh-autosuggestions
ADD --chown=sail:sail https://github.com/zsh-users/zsh-syntax-highlighting.git#master /home/sail/.oh-my-zsh/custom/plugins/zsh-syntax-highlighting
ADD --chown=sail:sail https://github.com/romkatv/powerlevel10k.git#master /home/sail/.oh-my-zsh/custom/themes/powerlevel10k
ADD --chown=sail:sail .p10k.zsh .zprofile .zshrc /home/sail/

VOLUME [ "/home/sail/.composer", "/home/sail/.cache/composer" ]

EXPOSE ${XDEBUG_PORT}
USER sail
WORKDIR /srv/www

CMD [ "sleep", "infinity" ]
