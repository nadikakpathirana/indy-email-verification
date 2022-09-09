#!/bin/bash

echo ""
#NAME="email_verification_service"
#HOME_DIR=/home/nadika/work/office_projects/blockchain/indy-email-verification
#echo "$HOME_DIR"
#
#CURRENT_DIR=$PWD
#echo "$CURRENT_DIR"
#
#
#DJANGODIR="$HOME_DIR/src"
#echo "$DJANGODIR"
#


#SOCKFILE=/path/to/your_project_name/run/gunicorn.sock
#USER=nadika
#GROUP=nadika
#
#NUM_WORKERS=3

#DJANGO_SETTINGS_MODULE=email_verification_service.settings
#echo $DJANGO_SETTINGS_MODULE
#
#DJANGO_WSGI_MODULE=email_verification_service.wsgi
#echo $DJANGO_WSGI_MODULE
#
#echo "Starting $NAME as `whoami`"
#
#cd $DJANGODIR
#
#source ../../../envs/indy-email-verification-x/bin/activate
#
#export DJANGO_SETTINGS_MODULE=$DJANGO_SETTINGS_MODULE
#export PYTHONPATH=$DJANGODIR:$PYTHONPATH
#
#export STI_SCRIPTS_PATH="/usr/libexec/s2i"

#python manage.py runserver
#RUNDIR=$(dirname $SOCKFILE)
#test -d $RUNDIR || mkdir -p $RUNDIR
#exec /Env/bin/activate/gunicorn ${DJANGO_WSGI_MODULE}:application \
#  --name $NAME \
#  --workers $NUM_WORKERS \
#  --user=$USER --group=$GROUP \
#  --bind=$SOCKFILE \
#  --log-level=debug \
#  --log-file=-
#-c
#bash -c "echo waiting for aca-py ...; sleep 5; python ./manage.py migrate; $${STI_SCRIPTS_PATH}/run;"

IP4=$(/sbin/ip -o -4 addr list wlp1s0 | awk '{print $4}' | cut -d/ -f1)

AGENT_WALLET_SEED="01234567890123456789012345678901"

#SITE_URL=http://$IP4:8080
SITE_URL=http://$IP4:10000
echo $SITE_URL

export PORT=8080
#SITE_URL: http://<Server-URL>:8080
export SITE_URL=$SITE_URL
export AGENT_URL="http://email-verifier-agent:5000"
export DEBUG="true"
export DB_NAME=postgres
export DB_USER=postgres
export DB_PASSWORD=password
export DB_PORT=5432
export DB_HOST=email-verifier-postgres
export EMAIL_HOST=maildev
export EMAIL_PORT=25
export EMAIL_USE_SSL="false"
export STI_SCRIPTS_PATH="/usr/libexec/s2i"
export APP_HOME="email_verification_service"
export WEB_CONCURRENCY=1

function isInstalled () {
  rtnVal=$(type "$1" >/dev/null 2>&1)
  rtnCd=$?
  if [ ${rtnCd} -ne 0 ]; then
    return 1
  else
    return 0
  fi
}

function isJQInstalled () {
  JQ_EXE=jq
  if ! isInstalled ${JQ_EXE}; then
    echoError "The ${JQ_EXE} executable is required and was not found on your path."
    echoError "Installation instructions can be found here: https://stedolan.github.io/jq/download"
    echoError "Alternatively, a package manager such as Chocolatey (Windows) or Brew (Mac) can be used to install this dependecy."
    exit 1
  fi
}

function isCurlInstalled () {
  CURL_EXE=curl
  if ! isInstalled ${CURL_EXE}; then
    echoError "The ${CURL_EXE} executable is required and was not found on your path."
    echoError "If your shell of choice doesn't come with curl preinstalled, try installing it using either [Homebrew](https://brew.sh/) (MAC) or [Chocolatey](https://chocolatey.org/) (Windows)."
    exit 1
  fi
}

function isNgrokInstalled () {
  NGROK_EXE=ngrok
  if ! isInstalled ${NGROK_EXE}; then
    echoError "The ${NGROK_EXE} executable is needed and not on your path."
    echoError "It can be downloaded from here: https://ngrok.com/download"
    echoError "Alternatively, a package manager such as Chocolatey (Windows) or Brew (Mac) can be used to install this dependecy."
    exit 1
  fi
}

function checkNgrokTunnelActive () {
  if [ -z "${SITE_URL}" ]; then
    echoError "It appears that ngrok tunneling is not enabled."
    echoError "Please open another shell in the scripts folder and execute start-ngrok.sh before trying again."
    exit 1
  fi
}

getStartupParams() {
  CONTAINERS=""
  ARGS="--force-recreate"

  for arg in $@; do
    case "$arg" in
    *=*)
      # Skip it
      ;;
    -*)
      ARGS+=" $arg"
      ;;
    *)
      CONTAINERS+=" $arg"
      ;;
    esac
  done

  if [ -z "$CONTAINERS" ]; then
    CONTAINERS="$DEFAULT_CONTAINERS"
  fi

  echo ${ARGS} ${CONTAINERS}
}

function generateSeed(){
  (
    _prefix=${1}
    _seed=$(echo "${_prefix}$(generateKey 32)" | fold -w 32 | head -n 1 )
    _seed=$(echo -n "${_seed}")
    echo ${_seed}
  )
}

#start

if [ -z "$SITE_URL" ]; then
  isJQInstalled
  isCurlInstalled
  isNgrokInstalled
  isCurlInstalled

#  export SITE_URL=$(${CURL_EXE} http://localhost:4040/api/tunnels | ${JQ_EXE} --raw-output '.tunnels | map(select(.name | contains("(http)"))) | .[0] | .public_url')
  export SITE_URL=$(curl http://localhost:4040/api/tunnels | ${JQ_EXE} --raw-output '.tunnels | map(select(.name | contains("(http)"))) | .[0] | .public_url')
  checkNgrokTunnelActive
fi

if [ -z "${AGENT_WALLET_SEED}" ]; then
  export AGENT_WALLET_SEED=$(generateSeed indy-evs)
fi

_startupParams=$(getStartupParams $@)
echo $@

echo $_startupParams
#configureEnvironment $@
#docker-compose up -d ${_startupParams}
#docker-compose logs -f

echo waiting for aca-py
sleep 5
python ./manage.py migrate
python ./manage.py runserver