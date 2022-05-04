#!/bin/bash
set -eo pipefail
shopt -s nullglob

# logging functions
mysql_log() {
	local type="$1"; shift
	printf '%s [%s] [Entrypoint]: %s\n' "$(date --rfc-3339=seconds)" "$type" "$*"
}
mysql_note() {
	mysql_log Note "$@"
}
mysql_warn() {
	mysql_log Warn "$@" >&2
}
mysql_error() {
	mysql_log ERROR "$@" >&2
	exit 1
}

# check to see if this file is being run or sourced from another script
_is_sourced() {
	# https://unix.stackexchange.com/a/215279
	[ "${#FUNCNAME[@]}" -ge 2 ] \
		&& [ "${FUNCNAME[0]}" = '_is_sourced' ] \
		&& [ "${FUNCNAME[1]}" = 'source' ]
}


# Do a temporary startup of the MariaDB server, for init purposes
docker_temp_server_start() {
	"$@" --skip-networking --default-time-zone=SYSTEM --socket=/run/mysqld/mysqld.sock --wsrep_on=OFF \
		--expire-logs-days=0 \
		--loose-innodb_buffer_pool_load_at_startup=0
		#&

	mysql_note "Waiting for server startup"

	local i
	for i in {3..0}; do

		echo $i
		sleep 1
	done

}

# Stop the server. When using a local socket file mysqladmin will block until
# the shutdown is complete.
docker_temp_server_stop() {
	if ! MYSQL_PWD=$MARIADB_ROOT_PASSWORD mysqladmin shutdown -uroot --socket=/run/mysqld/mysqld.sock; then
		mysql_error "Unable to shut down server."
	fi
}



# Loads various settings that are used elsewhere in the script
# This should be called after mysql_check_config, but before any other functions
docker_setup_env() {

	declare -g DATADIR SOCKET
	# DATADIR="$(mysql_get_config 'datadir' "$@")"
	SOCKET="$(mysql_get_config 'socket' "$@")"
	echo $SOCKET



}



_main() {

		mysql_note "Entrypoint script for MariaDB Server ${MARIADB_VERSION} started."

		# mysql_check_config "$@"

		# docker_setup_env "$@"
		# docker_create_db_directories


		mysql_note "Starting temporary server"
		echo $@
		docker_temp_server_start "$@"
		mysql_note "Temporary server started."

		mysql_note "Stopping temporary server"
		docker_temp_server_stop
		mysql_note "Temporary server stopped"


	exec "$@"
}

# If we are sourced from elsewhere, don't perform any further actions
if ! _is_sourced; then
	_main "$@"
fi
