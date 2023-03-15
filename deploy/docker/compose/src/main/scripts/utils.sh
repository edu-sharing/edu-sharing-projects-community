#!/bin/bash
set -e
set -o pipefail

export COMPOSE_PROJECT_NAME="${COMPOSE_PROJECT_NAME:-$(basename $(pwd))}"

case "$(uname)" in
MINGW*)
	COMPOSE_EXEC="winpty docker compose"
	;;
*)
	COMPOSE_EXEC="docker compose"
	;;
esac

export COMPOSE_EXEC

export CLI_CMD="$0"
export CLI_OPT1="$1"
shift || true

ROOT_PATH="$(
	cd "$(dirname ".")"
	pwd -P
)"
export ROOT_PATH

pushd "$(cd "$(dirname "${BASH_SOURCE[0]}")" >/dev/null && pwd)" >/dev/null || exit

COMPOSE_DIR="."

[[ -f ".env" ]] && [[ ! "${COMPOSE_DIR}/.env" -ef "./.env" ]] && {
  cp -f ".env" "${COMPOSE_DIR}"
}

pushd "${COMPOSE_DIR}" >/dev/null || exit

if [[ -f ".env" ]] ; then
	source .env
else
	REPOSITORY_SERVICE_HOST="127.0.0.1"
	SERVICES_RENDERING_SERVICE_HOST="127.0.0.1"
fi

info() {
	echo ""
	echo "#########################################################################"
	echo ""
	echo "  edu-sharing repository:"
	echo ""
	echo "    ${REPOSITORY_SERVICE_PROT:-http}://${REPOSITORY_SERVICE_HOST:-repository.127.0.0.1.nip.io}:${REPOSITORY_SERVICE_PORT:-8100}${REPOSITORY_SERVICE_PATH:-/edu-sharing}/"
	echo ""
	echo "    username: admin"
	echo "    password: ${REPOSITORY_SERVICE_ADMIN_PASS:-admin}"
	echo ""
	echo "  edu-sharing services:"
	echo ""
	echo "    rendering:"
	echo ""
	echo "      ${SERVICES_RENDERING_SERVICE_PROT:-http}://${SERVICES_RENDERING_SERVICE_HOST:-rendering.services.127.0.0.1.nip.io}:${SERVICES_RENDERING_SERVICE_PORT:-9100}${SERVICES_RENDERING_SERVICE_PATH:-/esrender}/admin/"
	echo ""
	echo "      username: ${SERVICES_RENDERING_DATABASE_USER:-rendering}"
	echo "      password: ${SERVICES_RENDERING_DATABASE_PASS:-rendering}"
	echo ""
	echo "#########################################################################"
	echo ""
	echo "  All exposed ports are bound to network address: ${COMMON_BIND_HOST:-127.0.0.1}."
	echo ""
	echo "#########################################################################"
	echo ""
	echo "  If you need to customize the installation, then:"
	echo ""
	echo "    - make a copy of \".env.sample\" to \".env\""
	echo "    - comment out and update relevant entities inside \".env\""
	echo ""
	echo "#########################################################################"
	echo ""
	echo ""
}

logs() {
	$COMPOSE_EXEC \
		logs -f $@ || exit
}

terminal() {
	$COMPOSE_EXEC \
		exec -u root -it  $1 /bin/bash || exit
}

ps() {
	$COMPOSE_EXEC \
		ps || exit
}

start() {
	$COMPOSE_EXEC \
		pull || exit

	$COMPOSE_EXEC \
		up -d $@ || exit
}

stop() {
	$COMPOSE_EXEC \
		stop $@ || exit
}

remove() {
	read -p "Are you sure you want to continue? [y/N] " answer
	case ${answer:0:1} in
	y | Y)
		$COMPOSE_EXEC \
			down || exit
		;;
	*)
		echo Canceled.
		;;
	esac
}

purge() {
	read -p "Are you sure you want to continue? [y/N] " answer
	case ${answer:0:1} in
	y | Y)
		$COMPOSE_EXEC \
			down -v || exit
		;;
	*)
		echo Canceled.
		;;
	esac
}

case "${CLI_OPT1}" in
start)
	start $@ && info
	;;
info)
	info
	;;
logs)
	logs $@
	;;
ps)
	ps
	;;
stop)
	stop $@
	;;
remove)
	remove
	;;
purge)
	purge
	;;
restart)
	stop $@ && start $@ && info
	;;
terminal)
  terminal $@
  ;;
*)
	echo ""
	echo "Usage: ${CLI_CMD} [option]"
	echo ""
	echo "options:"
	echo ""
	echo "  - start [Service...]   startup containers"
	echo "  - restart [Service...] stops and starts containers"
	echo ""
	echo "  - info                 show information"
	echo "  - logs [Service...]    show logs"
	echo "  - ps                   show containers"
	echo ""
	echo "  - stop [Service...]    stop all containers"
	echo "  - remove               remove all containers"
	echo "  - purge                remove all containers and volumes"
	echo ""
	echo "  - terminal [service]   open container bash as root"
	echo ""
	;;
esac

popd >/dev/null || exit
popd >/dev/null || exit
