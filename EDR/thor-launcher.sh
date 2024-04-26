#!/bin/bash

set -u

# abort() prints a message to stderr and exits the script with a non-zero status.
# Parameters:
#   $1: The message to print.
abort() {
  printf "%s\n" "$@" >&2
  exit 1
}

# string formatters
if [[ -t 1 ]]
then
  tty_escape() { printf "\033[%sm" "$1"; }
else
  tty_escape() { :; }
fi
tty_mkbold() { tty_escape "1;$1"; }
tty_underline="$(tty_escape "4;39")"
tty_blue="$(tty_mkbold 34)"
tty_red="$(tty_mkbold 31)"
tty_bold="$(tty_mkbold 39)"
tty_reset="$(tty_escape 0)"

shell_join() {
  local arg
  printf "%s" "$1"
  shift
  for arg in "$@"
  do
    printf " "
    printf "%s" "${arg// /\ }"
  done
}

chomp() {
  printf "%s" "${1/"$'\n'"/}"
}

ohai() {
  printf "${tty_blue}==>${tty_bold} %s${tty_reset}\n" "$(shell_join "$@")"
}

warn() {
  printf "${tty_red}Warning${tty_reset}: %s\n" "$(chomp "$1")"
}

# Check if both `INTERACTIVE` and `NONINTERACTIVE` are set
if [[ -n "${INTERACTIVE-}" && -n "${NONINTERACTIVE-}" ]]
then
  abort 'Both `$INTERACTIVE` and `$NONINTERACTIVE` are set. Please unset at least one variable and try again.'
fi

# Check if script is run non-interactively (e.g. CI)
# If it is run non-interactively we should not prompt for passwords.
if [[ -z "${NONINTERACTIVE-}" ]]
then
  if [[ ! -t 0 ]]
  then
    if [[ -z "${INTERACTIVE-}" ]]
    then
      warn 'Running in non-interactive mode because `stdin` is not a TTY.'
      NONINTERACTIVE=1
    else
      warn 'Running in interactive mode despite `stdin` not being a TTY because `$INTERACTIVE` is set.'
    fi
  fi
else
  ohai 'Running in non-interactive mode because `$NONINTERACTIVE` is set.'
fi

have_sudo_access() {
  if [[ ! -x "/usr/bin/sudo" ]]
  then
    return 1
  fi

  local -a SUDO=("/usr/bin/sudo")
  if [[ -n "${SUDO_ASKPASS-}" ]]
  then
    SUDO+=("-A")
  elif [[ -n "${NONINTERACTIVE-}" ]]
  then
    SUDO+=("-n")
  fi

  if [[ -z "${HAVE_SUDO_ACCESS-}" ]]
  then
    if [[ -n "${NONINTERACTIVE-}" ]]
    then
      "${SUDO[@]}" -l mkdir &>/dev/null
    else
      "${SUDO[@]}" -v && "${SUDO[@]}" -l mkdir &>/dev/null
    fi
    HAVE_SUDO_ACCESS="$?"
  fi

  return "${HAVE_SUDO_ACCESS}"
}

execute() {
  if ! "$@"
  then
    abort "$(printf "Failed during: %s" "$(shell_join "$@")")"
  fi
}

execute_sudo() {
  local -a args=("$@")
  ohai "Please enter your user password, if you are asked for it"
  if have_sudo_access
  then
    if [[ -n "${SUDO_ASKPASS-}" ]]
    then
      args=("-A" "${args[@]}")
    fi
    ohai "/usr/bin/sudo" "${args[@]}"
    execute "/usr/bin/sudo" --preserve-env=NO_PROXY "${args[@]}"
  else
    ohai "${args[@]}"
    execute "${args[@]}"
  fi
}

execute_with_retry() {
  counter=0
  while ! "$@"; do
    if [[ $counter -ge 5 ]]; then
      abort "$(printf "Failed repeatedly during: %s" "$(shell_join "$@")")"
    fi
    ((counter=counter+1))
    sleep 5
  done
}

if ! command -v curl >/dev/null
then
  abort "You must install cURL before running THOR Cloud Launcher."
fi

mdatp=$([[ "$(pwd)" == "/opt/microsoft/mdatp"* ]] && echo 1 || echo 0)

cd $(mktemp -d)

ohai "Downloading the launcher binary"
execute_with_retry "curl" -fsSL -o ./thor-cloud-launcher "https://thorcloud-lite.nextron-systems.com/dl?type=linux-binary&token=lrtlzqshzDC0&origin=script"

ohai "Executing the launcher binary"
execute "chmod" u+x ./thor-cloud-launcher
if [[ $mdatp -eq 1 ]]; then
  set -m # This activates monitor mode, meaning that background jobs (like THOR cloud launcher) get their own pgid and aren't terminated by MDATP at the end of the script.
  ./thor-cloud-launcher --output-file launcher.log >/dev/null 2>&1 &
  disown
  # Wait for the progress tracking page link
  for i in {1..10}; do
    sleep 5
    if grep "Progress tracking page" launcher.log >/dev/null; then
      break
    fi
  done
  cat launcher.log # Print launcher log (as far as it is now available)
else
  execute_sudo ./thor-cloud-launcher
fi
