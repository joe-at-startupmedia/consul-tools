VERBOSE=false
CAPTURE_FILE="/tmp/capture.out"

fn_verbose() {
  if [ "${DEBUG}" == "true" ]; then
    echo "${1}"
  fi
}

# capture the output of a command so it can be retrieved with ret
cap () {
  if [ ! -f "${CAPTURE_FILE}" ]; then
    chmod 0666 "${CAPTURE_FILE}"
  fi
  cat > "${CAPTURE_FILE}"; 
}

# return the output of the most recent command that was captured by cap
ret () { 
 cat "${CAPTURE_FILE}";
 truncate -s 0 "${CAPTURE_FILE}";
}

pipe_to_jq_if_json() {
  if [ -n "$1" ]; then
    local json_string="$1"
  else
    local json_string="$(cat)"
  fi

  if jq -e . >/dev/null 2>&1 <<< "$json_string"; then
    jq . <<< "$json_string"
  else
    echo "$json_string"
  fi
}

include_env() {
  DIR="${1}"
  FILE="${DIR}/.env" && test -f $FILE && source $FILE
}

require_deps() {
  DEPS=("$@")
  for name in "${DEPS[@]}"
  do
    [[ $(which $name 2>/dev/null) ]] || { echo -en "\n$name needs to be installed";deps=1; }
  done
  [[ $deps -eq 1 ]] && echo -en "\nInstall the above and rerun this script\n" && exit 1;
  if [[ ${#} -eq 0 ]]; then
    about
  fi
}
