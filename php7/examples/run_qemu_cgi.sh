#!/bin/sh
set -x
GUEST_PORT="${GUEST_PORT:-${1-9000}}"
HOST_PORT="${HOST_PORT:-${2-8080}}"
rumprun ${1+"$@"} qemu -i -M 512 \
	-I 'qnet0,vioif,-net user' \
	-g "-redir tcp:${HOST_PORT}::${GUEST_PORT}" \
	-W qnet0,inet,dhcp \
	-b ../images/data.iso,/data \
	-e PHP_FCGI_MAX_REQUESTS=0 \
	-- ../bin/php-cgi.bin -c /conf/php.ini -b "$GUEST_PORT"
