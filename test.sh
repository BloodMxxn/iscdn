#!/bin/bash
# test_cdn_correct.sh

SCRIPT="./iscdn.sh"

echo "========================================="
echo "CDN IP Checker - Correct Tests"
echo "========================================="

GREEN='\033[0;32m'
RED='\033[0;31m'
NC='\033[0m'

test_ip() {
  local ip="$1"
  local expected="$2"
  local desc="$3"

  output=$($SCRIPT "$ip" 2>/dev/null)
  exit_code=$?

  if [[ $exit_code -eq 0 && "$expected" == "valid" ]]; then
    echo -e "${GREEN}✓ PASS${NC} - $ip ($desc)"
  elif [[ $exit_code -ne 0 && "$expected" == "invalid" ]]; then
    echo -e "${GREEN}✓ PASS${NC} - $ip ($desc)"
  else
    echo -e "${RED}✗ FAIL${NC} - $ip ($desc)"
    echo "  Expected: $expected, Got exit code: $exit_code"
  fi
}

echo -e "\n--- Cloudflare Valid IPs (Should be ✅) ---\n"

# 173.245.48.0/10
test_ip "173.245.48.1" "valid" "Inside /10"

# 103.21.244.0/22
test_ip "103.21.244.1" "valid" "Inside /22"
test_ip "103.21.247.255" "valid" "End of /22"

# 141.101.64.0/18
test_ip "141.101.64.1" "valid" "Inside /18"
test_ip "141.101.127.255" "valid" "End of /18"

# 108.162.192.0/18
test_ip "108.162.192.1" "valid" "Inside /18"
test_ip "108.162.255.255" "valid" "End of /18"

# 162.158.0.0/15
test_ip "162.158.1.1" "valid" "Inside /15"
test_ip "162.159.255.255" "valid" "End of /15"

# 104.16.0.0/13
test_ip "104.16.1.1" "valid" "Inside /13"
test_ip "104.23.255.255" "valid" "End of /13"

# 172.64.0.0/13
test_ip "172.64.1.1" "valid" "Inside /13"
test_ip "172.71.255.255" "valid" "End of /13"

echo -e "\n--- ArvanCloud Valid IPs (Should be ✅) ---\n"

# 185.143.232.0/22
test_ip "185.143.232.1" "valid" "Inside /22"
test_ip "185.143.235.254" "valid" "Inside /22"
test_ip "185.143.235.255" "valid" "Broadcast (still inside)"

# 188.229.116.16/30
test_ip "188.229.116.16" "valid" "Start of /30"
test_ip "188.229.116.17" "valid" "Inside /30"
test_ip "188.229.116.18" "valid" "Inside /30"
test_ip "188.229.116.19" "valid" "End of /30"

# 94.101.182.0/27
test_ip "94.101.182.1" "valid" "Inside /27"
test_ip "94.101.182.30" "valid" "Inside /27"
test_ip "94.101.182.31" "valid" "End of /27"

# 2.144.3.128/28
test_ip "2.144.3.128" "valid" "Start of /28"
test_ip "2.144.3.129" "valid" "Inside /28"
test_ip "2.144.3.142" "valid" "Inside /28"
test_ip "2.144.3.143" "valid" "End of /28"

# 37.32.16.0/27
test_ip "37.32.16.1" "valid" "Inside /27"
test_ip "37.32.16.30" "valid" "Inside /27"
test_ip "37.32.16.31" "valid" "End of /27"

# 178.131.120.48/28
test_ip "178.131.120.48" "valid" "Start of /28"
test_ip "178.131.120.49" "valid" "Inside /28"
test_ip "178.131.120.62" "valid" "Inside /28"
test_ip "178.131.120.63" "valid" "End of /28"

# 78.157.36.112/28
test_ip "78.157.36.112" "valid" "Start of /28"
test_ip "78.157.36.113" "valid" "Inside /28"
test_ip "78.157.36.126" "valid" "Inside /28"
test_ip "78.157.36.127" "valid" "End of /28"

echo -e "\n--- Invalid IPs (Should be ❌) ---\n"

# Cloudflare
test_ip "1.1.1.1" "invalid" "Cloudflare DNS (not in CDN ranges)"
test_ip "8.8.8.8" "invalid" "Google DNS"
test_ip "173.191.255.255" "invalid" "Just before /10 start"
test_ip "173.256.0.1" "invalid" "Invalid IP"
test_ip "103.21.248.0" "invalid" "Just after /22 end"
test_ip "141.101.63.255" "invalid" "Just before /18 start"
test_ip "141.101.128.0" "invalid" "Just after /18 end"
test_ip "162.157.255.255" "invalid" "Just before /15 start"
test_ip "162.160.0.1" "invalid" "Just after /15 end"

# ArvanCloud
test_ip "185.143.231.255" "invalid" "Just before /22 start"
test_ip "185.143.236.0" "invalid" "Just after /22 end"
test_ip "188.229.116.15" "invalid" "Just before /30 start"
test_ip "188.229.116.20" "invalid" "Just after /30 end"
test_ip "94.101.182.32" "invalid" "Just after /27 end"
test_ip "2.144.3.127" "invalid" "Just before /28 start"
test_ip "2.144.3.144" "invalid" "Just after /28 end"
test_ip "37.32.16.32" "invalid" "Just after /27 end"
test_ip "178.131.120.47" "invalid" "Just before /28 start"
test_ip "178.131.120.64" "invalid" "Just after /28 end"
test_ip "78.157.36.111" "invalid" "Just before /28 start"
test_ip "78.157.36.128" "invalid" "Just after /28 end"

test_ip "192.168.1.1" "invalid" "Private IP"
test_ip "10.0.0.1" "invalid" "Private IP"
test_ip "172.16.0.1" "invalid" "Private IP"

echo -e "\n--- Invalid Format IPs (Should give error) ---\n"

test_ip "999.999.999.999" "invalid" "Invalid octet"
test_ip "256.1.1.1" "invalid" "Octet > 255"
test_ip "192.168.1" "invalid" "Incomplete IP"
test_ip "abc.def.ghi.jkl" "invalid" "Letters"
test_ip "192.168.1.1.1" "invalid" "Too many octets"

echo -e "\n========================================="
echo "Tests Completed!"
echo "========================================="