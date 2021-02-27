#!/bin/bash

init() {
  check_env
  DO_COMPILE=0
  DO_UPLOAD=0
}

check_env() {
  echo "=========="
  echo "Checking environment..."
  which arduino-cli > /dev/null
  if [ $? != 0 ]; then
    echo "Please install 'arduino-cli'"
    exit 1
  fi
  arduino-cli board list | grep -i arduino > /dev/null
  if [ $? != 0 ]; then
    echo "Please connect Arduino to your PC"
    exit 1
  fi
  board_info=$(arduino-cli board list | grep -i arduino)
  CORE_NAME=$(echo $board_info | awk '{print $(NF)}')
  PORT=$(echo $board_info | awk '{print $(1)}')
  FQBN=$(echo $board_info | awk '{print $(NF-1)}')
  arduino-cli core list | grep "$CORE_NAME" > /dev/null
  if [ $? != 0 ]; then
    arduino-cli core update-index
    arduino-cli core install "$CORE_NAME"
  fi
  echo "Your environment is supported!"
}

usage_exit() {
  echo "Usage: $0 [-c] [-u] -f FILE" 1>&2
  exit 1
}

init

while (( $# > 0 ))
do
  case $1 in
    -*)
      if [[ "$1" =~ 'c' ]]; then
       DO_COMPILE=1
      fi
      if [[ "$1" =~ 'u' ]]; then
        DO_UPLOAD=1
      fi
      if [[ "$1" =~ 'f' ]]; then
        INO_FILE="$2"
      fi
      shift
      ;;
    *)
      shift
      ;;
  esac
done

if [ $DO_COMPILE == 1 ]; then
  echo "=========="
  echo "Compiling..."
  arduino-cli compile --fqbn $FQBN $INO_FILE
  if [ $? == 0 ]; then
    echo "compile successed!"
  else
    exit 1
  fi
fi

if [ $DO_UPLOAD == 1 ]; then
  echo ""
  echo "=========="
  echo "Uploading..."
  arduino-cli upload -p $PORT --fqbn $FQBN $INO_FILE
  if [ $? == 0 ]; then
    echo "upload successed!"
  fi
fi
