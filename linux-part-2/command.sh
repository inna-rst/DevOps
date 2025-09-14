#!/bin/bash
mkdir -p "$HOME/linux_p" && cd "$HOME/linux_p" && for n in {1..20}; do base64 < /dev/urandom | head -c 2048 > "$n.txt"; done