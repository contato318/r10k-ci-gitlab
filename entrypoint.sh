#!/usr/bin/env bash
# R10K Entry Point


# Original source code (based): https://raw.githubusercontent.com/vladgh/docker_base_images/master/r10k/entrypoint.sh



# Bash strict mode
set -euo pipefail
IFS=$'\n\t'

# VARs
#CACHEDIR=${CACHEDIR:-/var/cache/r10k}
CACHEDIR='/var/cache/r10k'
CFG='/etc/puppetlabs/r10k/r10k.yaml'

file_env() {
	local var="$1"
	local fileVar="${var}_FILE"
	local def="${2:-}"
	if [ "${!var:-}" ] && [ "${!fileVar:-}" ]; then
		echo >&2 "error: both $var and $fileVar are set (but are exclusive)"
		exit 1
	fi
	local val="$def"
	if [ "${!var:-}" ]; then
		val="${!var}"
	elif [ "${!fileVar:-}" ]; then
		val="$(< "${!fileVar}")"
	fi
	export "$var"="$val"
	unset "$fileVar"
}


# Log message
log(){
  echo "[$(date "+%Y-%m-%dT%H:%M:%S%z") - $(hostname)] ${*}"
}

# Generate R10K configuration
generate_configuration(){
  # Make sure R10K configuration directory exists
  mkdir -p "$(dirname ${CFG})"

  # Create R10K configuration
  if [[ ! -s "$CFG" ]]; then
    log 'Save R10K configuration'
    cat << EOF > "$CFG"
# The location to use for storing cached Git repos
:cachedir: '${CACHEDIR}'
EOF
  fi
}







make_ssh_config(){
  mkdir /root/.ssh || true
  echo "Host $HOST_GIT
      StrictHostKeyChecking no
      IdentityFile /root/.ssh/private.$HOST_GIT" > /root/.ssh/config
  chmod 600 -R /root/.ssh
}

make_ssh_public_key(){
    echo $SSH_PUBLIC_GIT | base64 -d > /root/.ssh/public.$HOST_GIT
    chmod 600 /root/.ssh/public.$HOST_GIT
}

make_ssh_private_key(){
    echo $SSH_PRIVATE_GIT | base64 -d > /root/.ssh/private.$HOST_GIT
    chmod 600 /root/.ssh/private.$HOST_GIT
}

main(){
  file_env 'HOST_GIT'
  if [ -n "$HOST_GIT" ]; then
      make_ssh_config
  fi

  file_env 'SSH_PRIVATE_GIT'
  if [ -n "$SSH_PRIVATE_GIT" ]; then
      make_ssh_private_key
  fi

  file_env 'SSH_PUBLIC_GIT'
  if [ -n "$SSH_PUBLIC_GIT" ]; then
      make_ssh_public_key
  fi

  generate_configuration
}

#main "${@:-}"
main
exec "$@"
