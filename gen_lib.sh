#!/bin/bash
# gen_lib.sh — общая логика генерации.
# Используется и генератором (для студента), и проверялкой (для преподавателя).
# Данные детерминированы: одинаковый логин -> одинаковые данные и ответы.

CODEWORDS=(alpha bravo delta echo falcon gamma harbor iris kilo lima nova omega quartz raven sierra tango ultra viper wolf zebra)
IP_POOL=(10.0.0.1 10.0.0.2 10.0.0.3 172.16.5.5 172.16.5.9 192.168.1.10 192.168.1.20 8.8.8.8 203.0.113.7 198.51.100.4)
STATUSES=(200 200 200 200 301 404 404 500)

generate_data() {
    local user="$1"
    local dir="$2"

    # seed из логина -> число
    local seed
    seed=$(echo -n "$user" | md5sum | tr -dc '0-9' | head -c 8)
    seed=$((10#${seed:-1}))
    RANDOM=$seed

    rm -rf "$dir"
    mkdir -p "$dir/data" "$dir/logs" "$dir/notes"

    # --- data/: текстовые файлы с числами, часть с меткой GOLD ---
    local n=$((60 + RANDOM % 40))       # 60..99 файлов
    local i j lines val
    for ((i=1; i<=n; i++)); do
        {
            lines=$((1 + RANDOM % 4))
            for ((j=0; j<lines; j++)); do
                val=$((RANDOM % 1000))
                echo "value: $val"
            done
            # примерно каждый 5-й файл получает метку
            if (( RANDOM % 5 == 0 )); then
                echo "GOLD"
            fi
        } > "$dir/data/file_$i.txt"
    done

    # --- nums.txt: столбец чисел для суммирования ---
    local m=$((20 + RANDOM % 30))       # 20..49 чисел
    : > "$dir/nums.txt"
    for ((i=0; i<m; i++)); do
        echo $((RANDOM % 500)) >> "$dir/nums.txt"
    done

    # --- logs/access.log: синтетический веб-лог ---
    local k=$((200 + RANDOM % 200))     # 200..399 строк
    : > "$dir/logs/access.log"
    for ((i=0; i<k; i++)); do
        local ip=${IP_POOL[$((RANDOM % ${#IP_POOL[@]}))]}
        local st=${STATUSES[$((RANDOM % ${#STATUSES[@]}))]}
        echo "$ip - - [10/Oct/2024:13:5$((RANDOM%10)):00 +0000] \"GET /page$((RANDOM%20)) HTTP/1.1\" $st 512" >> "$dir/logs/access.log"
    done

    # --- скрытый файл с кодовым словом ---
    local word=${CODEWORDS[$((RANDOM % ${#CODEWORDS[@]}))]}
    echo "codeword=$word" > "$dir/notes/.secret"
    # немного отвлекающих обычных файлов
    echo "nothing here" > "$dir/notes/readme.txt"
    echo "just notes"   > "$dir/notes/todo.txt"
}
