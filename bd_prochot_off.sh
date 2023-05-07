#!/bin/sh

mem="0x1FC"

now_value="$(rdmsr $mem)"
last_value="$(echo "$now_value" | cut -b 5-6)"
off_value="$((0x$last_value & 0xFE))"
set_value="0x$(echo "$now_value" | cut -b 1-4)$(printf '%02x' "$off_value")"

wrmsr $mem "$set_value"
echo "$set_value write to reg $mem"
echo "BD PROCHOT off."
