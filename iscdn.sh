#!/usr/bin/bash

# ============================================
# ISCDN - CDN IP Range Checker
# Check if an IP address belongs to Cloudflare or ArvanCloud CDN
# ============================================

# 
readonly NAME="iscdn" # My name :/

# Color definitions for beautiful output
readonly RED='\033[0;31m'
readonly GREEN='\033[0;32m'
readonly YELLOW='\033[1;33m'
readonly BLUE='\033[0;34m'
readonly PURPLE='\033[0;35m'
readonly CYAN='\033[0;36m'
readonly WHITE='\033[1;37m'
readonly DARK_GRAY='\033[1;30m'
readonly NC='\033[0m'
readonly BOLD='\033[1m'
readonly DIM='\033[2m'

# Precomputed subnet masks for CIDR notation (0-32)
declare MASKS=(
  0x00000000  # /0
  0x80000000  # /1
  0xc0000000  # /2
  0xe0000000  # /3
  0xf0000000  # /4
  0xf8000000  # /5
  0xfc000000  # /6
  0xfe000000  # /7
  0xff000000  # /8
  0xff800000  # /9
  0xffc00000  # /10
  0xffe00000  # /11
  0xfff00000  # /12
  0xfff80000  # /13
  0xfffc0000  # /14
  0xfffe0000  # /15
  0xffff0000  # /16
  0xffff8000  # /17
  0xffffc000  # /18
  0xffffe000  # /19
  0xfffff000  # /20
  0xfffff800  # /21
  0xfffffc00  # /22
  0xfffffe00  # /23
  0xffffff00  # /24
  0xffffff80  # /25
  0xffffffc0  # /26
  0xffffffe0  # /27
  0xfffffff0  # /28
  0xfffffff8  # /29
  0xfffffffc  # /30
  0xfffffffe  # /31
  0xffffffff  # /32
)

readonly FILE="ranges.txt"
readonly NOW=$(date "+%m/%d/%Y")
readonly SOURCES=(
  "https://www.cloudflare.com/ips-v4"
  "https://www.arvancloud.ir/fa/ips.txt"
)

# ============================================
# Utility Functions
# ============================================

print_header() {
  echo -e "${BLUE}${BOLD}╔══════════════════════════════════════════╗${NC}"
  echo -e "${BLUE}${BOLD}║         ISCDN - CDN IP Checker           ║${NC}"
  echo -e "${BLUE}${BOLD}╚══════════════════════════════════════════╝${NC}"
}

print_success() {
  echo -e "${GREEN}✅${NC} $1"
}

print_error() {
  echo -e "${RED}❌${NC} $1" >&2
}

print_warning() {
  echo -e "${YELLOW}⚠️${NC} $1" >&2
}

print_info() {
  echo -e "${CYAN}ℹ️${NC}  $1"
}

print_refresh() {
  echo -e "${PURPLE}🔄${NC} $1"
}

# ============================================
# Core Functions
# ============================================

refresh() {
  echo "# $NOW" > $FILE
  print_refresh "Refreshing CDN IP ranges... ${DIM}[$NOW]${NC}"

  for url in "${SOURCES[@]}"; do
    print_info "Fetching: ${DIM}$url${NC}"
    content=$(curl -s -f --connect-timeout 10 "$url")
    if [[ $? -eq 0 && -n "$content" ]]; then
      echo "$content" >> "$FILE"
    else
      print_warning "Failed to fetch from $url"
    fi
  done

  print_success "Refresh completed! Ranges saved to ${BOLD}$FILE${NC}"
}

help() {
  print_header
  echo ""
  echo -e "${WHITE}${BOLD}📖 USAGE:${NC}"
  echo -e "  ${CYAN}$NAME${NC} ${GREEN}<IP_ADDRESS>${NC}      Check if IP belongs to CDN"
  echo -e "  ${CYAN}$NAME${NC} ${YELLOW}--refresh${NC} ${DIM}(-r)${NC}    Manually refresh CDN IP ranges"
  echo -e "  ${CYAN}$NAME${NC} ${YELLOW}--help${NC} ${DIM}(-h)${NC}       Show this help message"
  echo ""
  echo -e "${WHITE}${BOLD}📋 EXAMPLES:${NC}"
  echo -e "  ${CYAN}$NAME${NC} 173.245.48.1 \t${GREEN}✅ IP 173.245.48.1 belongs to CDN${NC}"
  echo -e "  ${CYAN}$NAME${NC} 1.2.3.4 \t${RED}❌ IP 1.2.3.4 does NOT belong to CDN${NC}"
  echo ""
  echo -e "${WHITE}${BOLD}📦 SOURCES:${NC}"
  for url in "${SOURCES[@]}"; do
    echo -e "  ${CYAN}•${NC} $url"
  done
  echo ""
}

ipv4_to_int() {
  local ip="$1"
  local a b c d
  IFS=. read -r a b c d <<< "$ip"
  echo $(( a * 16777216 + b * 65536 + c * 256 + d ))
}

ip_in_cdn_ranges() {
  local ip="$1"
  local ip_int=$(ipv4_to_int "$ip")
  local ranges=$(tail -n +2 "$FILE")
  local found=0

  local cidr_regex='^((25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)\.){3}(25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)/([0-9]|[1-2][0-9]|3[0-2])$'

  while IFS= read -r cidr; do
    cidr="${cidr//[[:space:]]/}"
    [[ -z "$cidr" || "$cidr" =~ ^# ]] && continue

    if [[ ! "$cidr" =~ $cidr_regex ]]; then
      return 2
    fi

    local network="${cidr%/*}"
    local mask="${cidr#*/}"
    local network_int=$(ipv4_to_int "$network")
    local mask_int=${MASKS[$mask]}

    if (( (ip_int & mask_int) == (network_int & mask_int) )); then
      found=1
      break
    fi
  done <<< "$ranges"

  [[ $found -eq 1 ]]
}

# ============================================
# Main Function
# ============================================

main() {
  local ip="$1"
  local last_refresh=$(head -n 1 "$FILE" 2>/dev/null | cut -d" " -f2)
  if [[ -z "$last_refresh" || "$NOW" != "$last_refresh" ]]; then
    echo ""
    refresh
    echo ""
  fi

  if ip_in_cdn_ranges "$ip"; then
    print_success "IP ${BOLD}$ip${NC} belongs to CDN"
    return 0
  else
    local exit_code=$?
    if [[ $exit_code -eq 2 ]]; then
      print_error "Configuration file '${BOLD}$FILE${NC}' is corrupted"
      print_info "Please run ${CYAN}$NAME --refresh${NC} to fix the file"
      return 2
    else
      echo -e "${RED}❌${NC} IP ${BOLD}$ip${NC} does ${RED}NOT${NC} belong to CDN"
      return 1
    fi
  fi

}

if [[ $# -eq 0 ]]; then
  help
  exit 0
fi

case "$1" in
  "--refresh" | "-r")
    refresh ;;
  "--help" | "-h")
    help ;;
  *)
    if [[ "$1" =~ ^(25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)(\.(25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)){3}$ ]]; then
      main "$1"
      exit $?
    else
      print_error "Invalid IP address format: ${BOLD}$1${NC}"
      print_info "Usage: $NAME <IP_ADDRESS> | --refresh | --help"
      exit 1
    fi
esac

