#!/bin/sh

set -xume

alpine_install() {
	if [[ $(id -u) != 0 ]]; then
		printf "Run alpine_install as root.\n" 1>&2
	fi
	local php
	php=php81
	apk add \
		${php}-fpm \
		${php}-session \
		${php}-ldap \
		${php}-gettext \
		${php}-openssl \
		${php}-xml \
		${php}-xmlreader \
		${php}-xmlwriter \
		${php}-mbstring \
		${php}-gd \
		${php}-gmp \
		${php}-zip

	/etc/init.d/php-fpm81 restart
	sleep 1
	chown root:www-data /var/run/php8-fpm.sock
	/etc/init.d/nginx restart
}

check() {
	if ! which $1 >/dev/null 2>&1; then
		printf "Install %s.\n" "$1" 1>&2
	fi
}

prerequisites() {
	check python3
	check pip3
}

venv_activate() {
	. .venv/bin/activate
}

venv_deactivate() {
	# VIRTUAL_ENV
	deactivate || true
}

setup() {
	prerequisites
	rm -rf .venv
	python3 -m venv --system-site-packages --prompt lam --upgrade-deps .venv	
	venv_activate
	pip install codespell
}


cmd=${1-setup}
shift || true
$cmd "$@"
