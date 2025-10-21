#!/usr/bin/env sh
set -eu

# List all vars you want to export into /etc/environment
VARS="UGV_MODEL ROS_DOMAIN_ID LDLIDAR_MODEL"

for VAR in $VARS; do
  # Indirect expansion to get the current value of $VAR
  VAL=$(eval "printf '%s' \"\${$VAR:-}\"")

  # Only write if it has a value
  if [ -n "$VAL" ]; then
    if grep -q "^$VAR=" /etc/environment 2>/dev/null; then
      sed -i "s|^$VAR=.*$|$VAR=$VAL|" /etc/environment
    else
      printf '\n%s=%s\n' "$VAR" "$VAL" >> /etc/environment
    fi
  fi
done

# chain to the original NVIDIA entrypoint, preserving CMD/command
exec /opt/nvidia/nvidia_entrypoint.sh "$@"
