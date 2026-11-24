#!/usr/bin/env bash
# Генератор варіантів до лабораторної роботи 1 «Контейнеризація».
# Використання:
#   bash variant.sh <github-login>            # один варіант
#   bash variant.sh login1 login2 login3 ...  # кілька варіантів (для викладача)
# Варіант визначається логіном GitHub однозначно: повторний запуск дає той самий результат.

set -euo pipefail

SALT="kpz-2026-lab1"

if [ "$#" -eq 0 ]; then
  echo "Використання: bash variant.sh <github-login> [ще логіни...]" >&2
  exit 1
fi

hash_of() {
  if command -v sha256sum >/dev/null 2>&1; then
    printf '%s' "$1" | sha256sum | cut -c1-64
  else
    printf '%s' "$1" | shasum -a 256 | cut -c1-64
  fi
}

STACKS=(python node go)
WORDS=(ALPHA BRAVO CHARLIE DELTA ECHO FOXTROT GOLF HOTEL INDIA JULIET KILO LIMA MIKE NOVEMBER OSCAR PAPA)
FIELDS=(amber cobalt coral jade ivory lime olive plum rust sand slate teal umber violet wheat zinc)
MEMS=(48 56 64 72 80 96 112 128)

for raw in "$@"; do
  login=$(printf '%s' "$raw" | tr '[:upper:]' '[:lower:]')
  h=$(hash_of "$SALT:$login")
  num() { echo $((16#${h:$1:$2})); }

  stack=${STACKS[$(( $(num 0 4) % 3 ))]}
  port=$(( 5000 + $(num 4 4) % 1000 ))
  env_name="KPZ_${WORDS[$(( $(num 8 2) % 16 ))]}"
  token=${h:12:8}
  field=${FIELDS[$(( $(num 20 2) % 16 ))]}
  mem=${MEMS[$(( $(num 22 2) % 8 ))]}
  pick=$(( $(num 24 2) % 2 ))

  case "$stack" in
    python) dep="flask";                         full="python:3.12"; finals=("python:3.12-slim" "python:3.12-alpine") ;;
    node)   dep="express";                       full="node:22";     finals=("node:22-slim" "node:22-alpine") ;;
    go)     dep="github.com/go-chi/chi/v5";      full="golang:1.27"; finals=("alpine:3.20" "gcr.io/distroless/static-debian12") ;;
  esac
  final=${finals[$pick]}

  cat <<EOF
LOGIN=$login
STACK=$stack
DEPENDENCY=$dep
SINGLE_BASE=$full
FINAL_BASE=$final
APP_PORT=$port
ENV_NAME=$env_name
TOKEN=$token
CHANGE_FIELD=$field
MEM_LIMIT_MB=$mem
EOF
  if [ "$#" -gt 1 ]; then echo; fi
done
