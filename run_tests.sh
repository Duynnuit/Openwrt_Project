#!/bin/bash
# ============================================================
# run_tests.sh - Script chạy nhanh các bài kiểm thử
# NT131.Q22 - Nhóm 18 | OpenWRT Firewall Test Suite
# ============================================================

set -e

INVENTORY="inventory/hosts.ini"
PLAYBOOK_DIR="playbooks"
LOG_FILE="ansible.log"
RESULTS_DIR="test-results"

# Màu sắc output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
CYAN='\033[0;36m'
BOLD='\033[1m'
NC='\033[0m' # No Color

banner() {
  echo -e "${CYAN}"
  echo "╔══════════════════════════════════════════════════════╗"
  echo "║    OpenWRT Firewall Test Suite - Nhóm 18 NT131.Q22   ║"
  echo "║    Xây dựng Soft-Router với Firewall Zone-Based       ║"
  echo "╚══════════════════════════════════════════════════════╝"
  echo -e "${NC}"
}

check_deps() {
  echo -e "${YELLOW}[*] Kiểm tra dependencies...${NC}"
  command -v ansible-playbook >/dev/null 2>&1 || {
    echo -e "${RED}[!] ansible-playbook chưa được cài. Chạy: pip install ansible${NC}"
    exit 1
  }
  echo -e "${GREEN}[✓] Ansible OK${NC}"
}

show_menu() {
  echo ""
  echo -e "${BOLD}Chọn test cần chạy:${NC}"
  echo "  [1] Chạy TOÀN BỘ tests (site.yml)"
  echo "  [2] T1 - Router Health Check"
  echo "  [3] T2 - LAN Internet (NAT)"
  echo "  [4] T3 - GUEST Internet (NAT Forward)"
  echo "  [5] T4 - GUEST↛LAN Isolation ⚠️ CRITICAL"
  echo "  [6] T5 - WAN Admin Port Block ⚠️ CRITICAL"
  echo "  [7] T6 - GUEST Admin Port Block"
  echo "  [8] T7 - Nmap từ WAN"
  echo "  [9] T8 - Nmap từ GUEST"
  echo "  [0] Thoát"
  echo ""
}

run_playbook() {
  local pb=$1
  local name=$2
  echo -e "\n${CYAN}[▶] Chạy: ${name}${NC}"
  echo "---"
  ansible-playbook -i "$INVENTORY" "$PLAYBOOK_DIR/$pb" -v
  local rc=$?
  if [ $rc -eq 0 ]; then
    echo -e "\n${GREEN}[✓] ${name} - HOÀN THÀNH${NC}"
  else
    echo -e "\n${RED}[✗] ${name} - CÓ LỖI (xem ansible.log)${NC}"
  fi
  return $rc
}

mkdir -p "$RESULTS_DIR"

banner
check_deps

# Nếu có argument, chạy trực tiếp
if [ "$1" == "all" ]; then
  run_playbook "site.yml" "TOÀN BỘ KIỂM THỬ"
  exit $?
fi

if [ "$1" == "critical" ]; then
  echo -e "${RED}[!] Chạy các CRITICAL security tests...${NC}"
  run_playbook "04_test_guest_lan_isolation.yml" "T4 - GUEST↛LAN"
  run_playbook "05_test_wan_admin_block.yml" "T5 - WAN Admin Block"
  exit $?
fi

# Interactive menu
show_menu
read -rp "Lựa chọn: " choice

case $choice in
  1) run_playbook "site.yml" "TOÀN BỘ KIỂM THỬ" ;;
  2) run_playbook "01_test_router_health.yml" "T1 - Router Health" ;;
  3) run_playbook "02_test_lan_internet.yml" "T2 - LAN Internet" ;;
  4) run_playbook "03_test_guest_internet.yml" "T3 - GUEST Internet" ;;
  5) run_playbook "04_test_guest_lan_isolation.yml" "T4 - GUEST↛LAN Isolation" ;;
  6) run_playbook "05_test_wan_admin_block.yml" "T5 - WAN Admin Block" ;;
  7) run_playbook "06_test_guest_admin_block.yml" "T6 - GUEST Admin Block" ;;
  8) run_playbook "07_test_nmap_wan.yml" "T7 - Nmap WAN" ;;
  9) run_playbook "08_test_nmap_guest.yml" "T8 - Nmap GUEST" ;;
  0) echo "Thoát."; exit 0 ;;
  *) echo -e "${RED}Lựa chọn không hợp lệ${NC}"; exit 1 ;;
esac
