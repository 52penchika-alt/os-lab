#!/bin/bash
# generate.sh — запускается ОДИН раз на машине студента.
# Создаёт персональный набор данных в ~/praktika (на основе логина $USER).
set -euo pipefail

DIR="$HOME/praktika"
LIB="$(dirname "$0")/gen_lib.sh"

if [[ ! -f "$LIB" ]]; then
    echo "Не найден gen_lib.sh рядом со скриптом" >&2
    exit 1
fi

# shellcheck source=/dev/null
source "$LIB"

generate_data "$USER" "$DIR"

echo "Готово! Твои данные для практики лежат в: $DIR"
echo "Загляни внутрь:  ls -la $DIR"
