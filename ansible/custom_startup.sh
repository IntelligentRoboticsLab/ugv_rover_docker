#!/bin/bash

# Get IP For connection

CONN="vislab_wifi"

if [ -z "$CONN" ]; then
  echo "Usage: $0 <ssid name>"
  exit 1
fi

while ! nmcli -t -f NAME connection show --active | grep -Fxq "$CONN"; do
  sleep 1
done

echo "connection active"

#get the device for that connection
DEV=$(nmcli -t -f NAME,DEVICE connection show --active | grep "^${CONN}:" | cut -d: -f2)

while ! ip -4 addr show dev "$DEV" | grep -q "inet "; do
  sleep 1
done

echo "device connected"

# Extract IP (remove CIDR)
IP=$(ip -4 addr show dev "$DEV" | awk '/inet / {print $2}' | cut -d/ -f1)
# Low-pitch beeps
espeak --stdout -p 50 -s 30 "Beep. Beep." | paplay
# Normal voice for IP
espeak --stdout -p 50 -s 80 "My IP is $IP" | paplay

if (( RANDOM % 100 == 0 )); then
espeak --stdout -p 30 -s 100 "hoo hoo" | paplay
fi

if (( RANDOM % 200 == 0)); then
espeak --stdout -p 20 -s 120 "Ready to destroy humanity" | paplay
fi
