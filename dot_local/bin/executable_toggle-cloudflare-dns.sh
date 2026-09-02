#!/usr/bin/env bash

# Metadata for Raycast
# @raycast.schemaVersion 1
# @raycast.title Toggle Cloudflare DNS
# @raycast.mode fullOutput
# @raycast.packageName dotfiles

DNS_ON="1.1.1.3 1.0.0.3"
SERVICES="$(networksetup -listallnetworkservices | grep -iE 'Wi-Fi|Ethernet|USB|Thunderbolt' | grep -iv vpn)"

on=0
services=()
while IFS= read -r svc; do
  services+=("$svc")
  [[ -n "$svc" ]] && networksetup -getdnsservers "$svc" | grep -q '1.1.1.3' && on=1
done <<<"$SERVICES"

if [[ "${#services[@]}" -eq 0 ]]; then
  echo "No matching network services found."
  exit 1
fi

if [[ "$on" -eq 1 ]]; then
  for svc in "${services[@]}"; do
    networksetup -setdnsservers "$svc" empty
    echo "DNS reset to DHCP for $svc"
  done
else
  for svc in "${services[@]}"; do
    networksetup -setdnsservers "$svc" $DNS_ON
    echo "Cloudflare DNS ($DNS_ON) set for $svc"
  done
fi
