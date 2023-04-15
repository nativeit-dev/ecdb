#!/bin/bash
if [[ "$1" == apache2* ]] || [ "$1" == php-fpm ]; then

    if [ ! -f /etc/ecdb/config.secret.inc.php ]; then
        cat > /etc/ecdb/config.secret.inc.php <<EOT
<?php
\$cfg['blowfish_secret'] = '$(tr -dc 'a-zA-Z0-9~!@#$%^&*_()+}{?></";.,[]=-' < /dev/urandom | fold -w 32 | head -n 1)';
EOT
    fi

    if [ ! -f /etc/ecdb/config.user.inc.php ]; then
        touch /etc/ecdb/config.user.inc.php
    fi
fi

if [ ! -z "${HIDE_PHP_VERSION}" ]; then
    echo "PHP version is now hidden."
    echo -e 'expose_php = Off\n' > $PHP_INI_DIR/conf.d/ecdb-hide-php-version.ini
fi

# start: Apache specific settings
if [ -n "${APACHE_PORT+x}" ]; then
    echo "Setting apache port to ${APACHE_PORT}."
    sed -i "/VirtualHost \*:80/c\\<VirtualHost \*:${APACHE_PORT}\>" /etc/apache2/sites-enabled/000-default.conf
    sed -i "/Listen 80/c\Listen ${APACHE_PORT}" /etc/apache2/ports.conf
    apachectl configtest
fi
# end: Apache specific settings

get_docker_secret() {
    local env_var="${1}"
    local env_var_file="${env_var}_FILE"

    # Check if the variable with name $env_var_file (which is $ECDB_PASSWORD_FILE for example)
    # is not empty and export $ECDB_PASSWORD as the password in the Docker secrets file

    if [[ -n "${!env_var_file}" ]]; then
        export "${env_var}"="$(cat "${!env_var_file}")"
    fi
}

get_docker_secret MYSQL_ROOT_PASSWORD
get_docker_secret MYSQL_PASSWORD
get_docker_secret ECDB_HOST

exec "$@"