#!/bin/sh
set -x
GUEST_PORT="${GUEST_PORT:-${1-9000}}"
HOST_PORT="${HOST_PORT:-${2-8080}}"
HYPERVISOR="${HYPERVISOR:-qemu}"
# php has a heap limit of 128M by default, provide some code/stack space on top of that
MEM_LIMIT="${MEM_LIMIT:-192}"
rumprun ${1+"$@"} "$HYPERVISOR" -i -M "$MEM_LIMIT" \
	-I 'qnet0,vioif,-net user' \
	-g "-redir tcp:${HOST_PORT}::${GUEST_PORT}" \
	-W qnet0,inet,dhcp \
	-b ../images/data.iso,/data \
	-e PHP_FCGI_MAX_REQUESTS=0 \
	-- ../bin/php-cgi.bin -c /data/conf/php.ini -b "$GUEST_PORT"
