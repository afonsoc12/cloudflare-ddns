#!/bin/sh

# Cloudflare API Token. Must have permission `Zone - Zone - Read` and `Zone - DNS - Edit`. Zone Resources can be `Include - Specific zone - mydomain.xyz`.
api_token="${CLOUDFLARE_API_TOKEN:?Variable not set or empty}" #"YRCgGjqfX6gjlm4npWQx9XQVoGg1lqlPUquBCOU7"

# Cloudflare Zone ID. Can be found in the "Overview" tab of your domain.
zone_id="${CLOUDFLARE_ZONE_ID:?Variable not set or empty}" #"d7127dbf18c7d0995a8db4a2ddb3bb81"

# Cloudflare record to be updated with new IP.
record_name="${CLOUDFLARE_RECORD_NAME:?Variable not set or empty}" #"uk.ip.serveris.online"

# Set the DNS TTL (seconds).
ttl="${TTL:=1}"

# Enable cloudflare proxy (true or false).
proxy="${PROXY:=false}"


###########################################
## Check if we have a public IP
###########################################
ipv4_regex='([01]?[0-9]?[0-9]|2[0-4][0-9]|25[0-5])\.([01]?[0-9]?[0-9]|2[0-4][0-9]|25[0-5])\.([01]?[0-9]?[0-9]|2[0-4][0-9]|25[0-5])\.([01]?[0-9]?[0-9]|2[0-4][0-9]|25[0-5])'
ip=$(curl -s -4 https://cloudflare.com/cdn-cgi/trace | grep -E '^ip'); ret=$?
if [[ ! $ret == 0 ]]; then # In the case that cloudflare failed to return an ip.
    # Attempt to get the ip from other websites.
    ip=$(curl -s https://ipinfo.io/ip || curl -s https://api.ipify.org)
else
    # Extract just the ip from the ip line from cloudflare.
    ip=$(echo $ip | sed -E "s/^ip=($ipv4_regex)$/\1/")
fi

# Use regex to check for proper IPv4 format.
if [[ ! $ip =~ ^$ipv4_regex$ ]]; then
    echo "DDNS Updater: Failed to find a valid IP."
    exit 2
fi

###########################################
## Seek for the A record
###########################################
echo "DDNS Updater: Check Initiated"
record=$(curl -s -X GET "https://api.cloudflare.com/client/v4/zones/$zone_id/dns_records?type=A&name=$record_name" \
                      -H "Authorization: Bearer $api_token" \
                      -H "Content-Type: application/json")

###########################################
## Check if the domain has an A record
###########################################
if [[ $record == *"\"count\":0"* ]]; then
  echo "DDNS Updater: Record does not exist, perhaps create one first? (${ip} for ${record_name})"
  exit 1
fi

###########################################
## Get existing IP
###########################################
old_ip=$(echo "$record" | jq -r '.result[0].content')
# Compare if they're the same
if [[ $ip == $old_ip ]]; then
  echo "DDNS Updater: IP ($ip) for ${record_name} has not changed."
  exit 0
fi

###########################################
## Set the record identifier from result
###########################################
record_identifier=$(echo "$record" | jq -r '.result[0].id')

###########################################
## Change the IP@Cloudflare using the API
###########################################
update=$(curl -s -X PATCH https://api.cloudflare.com/client/v4/zones/$zone_id/dns_records/$record_identifier \
                 -H "Authorization: Bearer $api_token" \
                 -H "Content-Type: application/json" \
                 --data-raw "{\"type\":\"A\", \"name\":\"$record_name\", \"content\":\"$ip\", \"ttl\": $ttl, \"proxied\": $proxy}")

###########################################
## Report the status
###########################################
case "$update" in
*"\"success\":false"*)
  echo "DDNS Updater: $ip $record_name DDNS failed for $record_identifier ($ip). DUMPING RESULTS:\n$update" | logger -s

  exit 1;;
*)
  echo "DDNS Updater: $ip $record_name DDNS updated."
  exit 0;;
esac
