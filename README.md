# 🔥 OpenWRT Firewall Test Suite (Ansible)
## Nhóm 18 - NT131.Q22 | Xây dựng Soft-Router + Firewall Zone-Based

---

## 📁 Cấu trúc thư mục

```
openwrt-firewall-tests/
├── ansible.cfg                        ← Cấu hình Ansible
├── run_tests.sh                       ← Script chạy nhanh (interactive)
├── inventory/
│   └── hosts.ini                      ← Danh sách host (PHẢI CHỈNH IP)
├── group_vars/
│   └── all.yml                        ← Biến dùng chung
└── playbooks/
    ├── site.yml                       ← Master: chạy tất cả
    ├── 00_setup.yml                   ← Cài công cụ (nmap, curl...)
    ├── 01_test_router_health.yml      ← T1: Router + DHCP + Interfaces
    ├── 02_test_lan_internet.yml       ← T2: LAN → Internet (NAT)
    ├── 03_test_guest_internet.yml     ← T3: GUEST → Internet
    ├── 04_test_guest_lan_isolation.yml ← T4: GUEST ↛ LAN ⚠️ CRITICAL
    ├── 05_test_wan_admin_block.yml    ← T5: WAN ↛ SSH/HTTP ⚠️ CRITICAL
    ├── 06_test_guest_admin_block.yml  ← T6: GUEST ↛ Router Admin
    ├── 07_test_nmap_wan.yml           ← T7: Nmap từ WAN
    ├── 08_test_nmap_guest.yml         ← T8: Nmap từ GUEST → LAN
    └── 99_generate_report.yml        ← Tổng hợp báo cáo HTML
```

---

## ⚙️ Cài đặt

```bash
# 1. Cài Ansible
pip install ansible

# 2. Chỉnh IP trong inventory
nano inventory/hosts.ini

# 3. Cấp quyền script
chmod +x run_tests.sh
```

---

## 🔧 Chỉnh sửa hosts.ini (BẮT BUỘC)

```ini
[router]
openwrt ansible_host=192.168.1.1    # ← IP LAN của router OpenWRT

[lan_hosts]
lan-ubuntu ansible_host=192.168.1.100  # ← IP máy Ubuntu trong LAN

[guest_hosts]
guest-ubuntu ansible_host=192.168.2.100  # ← IP máy Ubuntu trong GUEST

[wan_hosts]
wan-attacker ansible_host=X.X.X.X   # ← IP máy mô phỏng WAN attacker
```

Cũng chỉnh `router_wan_actual_ip` trong playbook 05 và 07 cho đúng IP WAN của router.

---

## ▶️ Cách chạy

### Chạy toàn bộ test suite:
```bash
./run_tests.sh all
# hoặc
ansible-playbook -i inventory/hosts.ini playbooks/site.yml
```

### Chạy chỉ critical security tests:
```bash
./run_tests.sh critical
```

### Chạy từng test riêng lẻ:
```bash
ansible-playbook -i inventory/hosts.ini playbooks/04_test_guest_lan_isolation.yml -v
```

### Chạy với verbose:
```bash
ansible-playbook -i inventory/hosts.ini playbooks/site.yml -vv
```

---

## 📊 Ma trận kiểm thử

| Test | Kịch bản | Nguồn | Đích | Kết quả mong đợi |
|------|---------|-------|------|------------------|
| T1 | Router Health | - | Router | PASS (interfaces up, DHCP OK) |
| T2 | NAT LAN | LAN | Internet | PASS (ping 8.8.8.8 OK) |
| T3 | NAT GUEST | GUEST | Internet | PASS (ping 8.8.8.8 OK) |
| **T4** ⚠️ | **GUEST↛LAN** | GUEST | LAN | **BLOCKED (tất cả bị chặn)** |
| **T5** ⚠️ | **WAN Admin** | WAN | Router :22,:80 | **BLOCKED (DROP)** |
| T6 | GUEST Admin | GUEST | Router :22,:80 | BLOCKED |
| T7 | Nmap WAN | WAN | Router | All ports filtered |
| T8 | Nmap GUEST | GUEST | LAN subnet | All hosts hidden |

---

## 📂 Kết quả kiểm thử

Sau khi chạy, kết quả được lưu tại:
- Trên mỗi host: `/tmp/firewall-test-results/*.txt`
- Trên Ansible controller: `./test-results/report.html`
- Log: `./ansible.log`

---

## 🏗️ Kiến trúc Firewall Zone (theo đề tài)

```
Internet (WAN)
     │
     │ eth0 - VMnet0 (NAT)
  ┌──▼──────────────────┐
  │   OpenWRT Router     │
  │   fw4 / nftables     │
  └──┬──────────┬────────┘
     │ eth1     │ eth2
     │ VMnet1   │ VMnet2
  ┌──▼──┐    ┌──▼──────┐
  │ LAN │    │  GUEST  │
  │.1.x │    │  .2.x   │
  └─────┘    └─────────┘
  TRUSTED     ISOLATED
```

**Rules chính:**
- `GUEST → LAN`: DROP (Block-GUEST-to-LAN)
- `WAN → Router :22`: DROP (Block-WAN-SSH)
- `WAN → Router :80`: DROP (Block-WAN-HTTP)
- `GUEST → WAN`: ACCEPT (Internet OK)
- `LAN → WAN`: ACCEPT (Internet OK)

---

*NT131.Q22 - Nhóm 18 | Ansible Firewall Test Suite*
