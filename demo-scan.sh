#!/bin/bash
# ============================================================
# SCA Tools Demo Script — Dùng cho thuyết trình
# Chạy trong container: docker run -it --rm sca-demo
# ============================================================

set -euo pipefail

# --- Colors ---
GREEN='\033[0;32m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
BOLD='\033[1m'
DIM='\033[2m'
NC='\033[0m'

RESULTS="/project/scan-results"
mkdir -p "$RESULTS"

# --- Helpers ---
banner() {
    echo ""
    echo -e "${BLUE}══════════════════════════════════════════════════════════════${NC}"
    echo -e "${BOLD}  $1${NC}"
    echo -e "${BLUE}══════════════════════════════════════════════════════════════${NC}"
    echo ""
}

info()    { echo -e "${CYAN}  ℹ  $1${NC}"; }
success() { echo -e "${GREEN}  ✓  $1${NC}"; }
warn()    { echo -e "${YELLOW}  ⚠  $1${NC}"; }
cmd()     { echo -e "${DIM}  \$ $1${NC}"; }

separator() { echo -e "${DIM}  ──────────────────────────────────────────────────${NC}"; }

# ============================================================
# Commands
# ============================================================

show_versions() {
    banner "PHIÊN BẢN CÁC CÔNG CỤ SCA"
    echo -e "  ${BOLD}Trivy${NC}            $(trivy version 2>/dev/null | grep -i 'version' | head -1 | awk '{print $NF}')"
    echo -e "  ${BOLD}Grype${NC}            $(grype version 2>/dev/null | grep -i 'application' | awk '{print $NF}')"
    echo -e "  ${BOLD}Syft${NC}             $(syft version 2>/dev/null | grep -i 'application' | awk '{print $NF}')"
    echo -e "  ${BOLD}OSV-Scanner${NC}      $(osv-scanner --version 2>/dev/null | awk '{print $NF}')"
    echo -e "  ${BOLD}Dependency-Check${NC} $(dependency-check --version 2>/dev/null | grep -i 'version' | head -1 | awk '{print $NF}')"
    echo ""
}

# --- TRIVY ---
run_trivy() {
    banner "1. TRIVY — Quét Lỗ hổng"
    cmd "trivy fs /project --severity HIGH,CRITICAL"
    separator
    trivy fs /project --severity HIGH,CRITICAL 2>/dev/null
    separator
    # Save JSON for comparison
    trivy fs /project --format json --output "$RESULTS/trivy-vuln.json" 2>/dev/null
    success "Kết quả JSON: $RESULTS/trivy-vuln.json"
}

run_trivy_sbom() {
    banner "2. TRIVY — Tạo SBOM (CycloneDX)"
    cmd "trivy fs /project --format cyclonedx --output sbom-trivy.json"
    separator
    trivy fs /project --format cyclonedx --output "$RESULTS/sbom-trivy.json" 2>/dev/null
    COMPONENTS=$(python3 -c "
import json
with open('$RESULTS/sbom-trivy.json') as f:
    data = json.load(f)
    print(len(data.get('components', [])))
" 2>/dev/null || echo "N/A")
    success "SBOM đã tạo: $RESULTS/sbom-trivy.json ($COMPONENTS components)"
}

run_trivy_license() {
    banner "3. TRIVY — Quét License"
    cmd "trivy fs /project --scanners license --severity UNKNOWN,LOW,MEDIUM,HIGH,CRITICAL"
    separator
    trivy fs /project --scanners license --severity UNKNOWN,LOW,MEDIUM,HIGH,CRITICAL 2>/dev/null || true
}

# --- GRYPE + SYFT ---
run_syft() {
    banner "4. SYFT — Tạo SBOM (CycloneDX)"
    cmd "syft /project -o cyclonedx-json=sbom-syft.json"
    separator
    syft /project -o "cyclonedx-json=$RESULTS/sbom-syft.json" 2>/dev/null
    COMPONENTS=$(python3 -c "
import json
with open('$RESULTS/sbom-syft.json') as f:
    data = json.load(f)
    print(len(data.get('components', [])))
" 2>/dev/null || echo "N/A")
    success "SBOM đã tạo: $RESULTS/sbom-syft.json ($COMPONENTS components)"
}

run_grype() {
    banner "5. GRYPE — Quét Lỗ hổng (từ SBOM)"

    # Generate SBOM first if not exists
    if [ ! -f "$RESULTS/sbom-syft.json" ]; then
        info "Tạo SBOM bằng Syft trước..."
        syft /project -o "cyclonedx-json=$RESULTS/sbom-syft.json" 2>/dev/null
        success "SBOM đã tạo"
    fi

    cmd "grype sbom:$RESULTS/sbom-syft.json"
    separator
    grype "sbom:$RESULTS/sbom-syft.json" 2>/dev/null || true
    separator
    # Save JSON
    grype "sbom:$RESULTS/sbom-syft.json" -o json > "$RESULTS/grype-vuln.json" 2>/dev/null || true
    success "Kết quả JSON: $RESULTS/grype-vuln.json"
}

# --- OSV-SCANNER ---
run_osv() {
    banner "6. OSV-SCANNER — Quét Lỗ hổng"
    cmd "osv-scanner scan -r /project"
    separator
    # osv-scanner returns non-zero when vulns found, so || true
    osv-scanner scan -r /project 2>/dev/null || true
    separator
    osv-scanner scan -r /project --format json > "$RESULTS/osv-results.json" 2>/dev/null || true
    success "Kết quả JSON: $RESULTS/osv-results.json"
}

# --- DEPENDENCY-CHECK ---
run_dc() {
    banner "7. DEPENDENCY-CHECK — Quét Lỗ hổng"

    if [ -z "${NVD_API_KEY:-}" ]; then
        warn "NVD_API_KEY chưa được cấu hình!"
        warn "Từ 2023, Dependency-Check yêu cầu NVD API key."
        info "Lấy key miễn phí tại: https://nvd.nist.gov/developers/request-an-api-key"
        info "Chạy lại: docker run -e NVD_API_KEY=your_key ..."
        echo ""
        echo -n "  Tiếp tục không có API key? (rất chậm) [y/N]: "
        read -r yn
        if [ "$yn" != "y" ] && [ "$yn" != "Y" ]; then
            warn "Bỏ qua Dependency-Check."
            return
        fi
    fi

    DC_ARGS="--project Test-SCA --scan /project --out $RESULTS/dc-report --format HTML --format JSON"
    if [ -n "${NVD_API_KEY:-}" ]; then
        DC_ARGS="$DC_ARGS --nvdApiKey $NVD_API_KEY"
    fi

    cmd "dependency-check $DC_ARGS"
    warn "Lần đầu chạy cần tải NVD DB (~10-30 phút với API key, lâu hơn nếu không có)"
    separator
    dependency-check $DC_ARGS 2>/dev/null || true
    separator
    success "Báo cáo HTML: $RESULTS/dc-report/dependency-check-report.html"
    success "Báo cáo JSON: $RESULTS/dc-report/dependency-check-report.json"
}

# --- COMPARE ---
run_compare() {
    banner "SO SÁNH KẾT QUẢ CÁC SCANNER"

    # Count vulnerabilities from each tool
    TRIVY_COUNT="—"
    GRYPE_COUNT="—"
    OSV_COUNT="—"

    if [ -f "$RESULTS/trivy-vuln.json" ]; then
        TRIVY_COUNT=$(python3 -c "
import json
with open('$RESULTS/trivy-vuln.json') as f:
    data = json.load(f)
    total = sum(len(r.get('Vulnerabilities', [])) for r in data.get('Results', []))
    print(total)
" 2>/dev/null || echo "?")
    fi

    if [ -f "$RESULTS/grype-vuln.json" ]; then
        GRYPE_COUNT=$(python3 -c "
import json
with open('$RESULTS/grype-vuln.json') as f:
    data = json.load(f)
    print(len(data.get('matches', [])))
" 2>/dev/null || echo "?")
    fi

    if [ -f "$RESULTS/osv-results.json" ]; then
        OSV_COUNT=$(python3 -c "
import json
with open('$RESULTS/osv-results.json') as f:
    data = json.load(f)
    total = sum(len(p.get('vulnerabilities', [])) for r in data.get('results', []) for p in r.get('packages', []))
    print(total)
" 2>/dev/null || echo "?")
    fi

    echo -e "  ┌──────────────────────┬────────────────┐"
    echo -e "  │ ${BOLD}Scanner${NC}              │ ${BOLD}Lỗ hổng${NC}        │"
    echo -e "  ├──────────────────────┼────────────────┤"
    printf "  │ %-20s │ %-14s │\n" "Trivy" "$TRIVY_COUNT"
    printf "  │ %-20s │ %-14s │\n" "Grype (via Syft)" "$GRYPE_COUNT"
    printf "  │ %-20s │ %-14s │\n" "OSV-Scanner" "$OSV_COUNT"
    echo -e "  └──────────────────────┴────────────────┘"
    echo ""

    # SBOM comparison
    TRIVY_SBOM="—"
    SYFT_SBOM="—"
    if [ -f "$RESULTS/sbom-trivy.json" ]; then
        TRIVY_SBOM=$(python3 -c "
import json
with open('$RESULTS/sbom-trivy.json') as f:
    print(len(json.load(f).get('components', [])))
" 2>/dev/null || echo "?")
    fi
    if [ -f "$RESULTS/sbom-syft.json" ]; then
        SYFT_SBOM=$(python3 -c "
import json
with open('$RESULTS/sbom-syft.json') as f:
    print(len(json.load(f).get('components', [])))
" 2>/dev/null || echo "?")
    fi

    echo -e "  ┌──────────────────────┬────────────────┐"
    echo -e "  │ ${BOLD}SBOM Generator${NC}       │ ${BOLD}Components${NC}     │"
    echo -e "  ├──────────────────────┼────────────────┤"
    printf "  │ %-20s │ %-14s │\n" "Trivy" "$TRIVY_SBOM"
    printf "  │ %-20s │ %-14s │\n" "Syft" "$SYFT_SBOM"
    echo -e "  └──────────────────────┴────────────────┘"
    echo ""

    info "Kết quả chi tiết tại: $RESULTS/"
}

# --- ALL (trừ Dependency-Check vì chậm) ---
run_all() {
    show_versions
    run_trivy
    run_trivy_sbom
    run_trivy_license
    run_syft
    run_grype
    run_osv
    run_compare
    banner "HOÀN TẤT"
    info "Tất cả kết quả đã lưu tại: $RESULTS/"
    info "Chạy 'demo-scan dc' riêng nếu muốn test Dependency-Check (cần NVD API key)"
}

# --- HELP ---
show_help() {
    banner "SCA TOOLS DEMO"
    echo "  Sử dụng: demo-scan <command>"
    echo ""
    echo -e "  ${BOLD}Commands:${NC}"
    echo "    versions  (v)   Hiện phiên bản các tool"
    echo "    trivy     (t)   Trivy: quét lỗ hổng"
    echo "    sbom      (s)   Trivy: tạo SBOM CycloneDX"
    echo "    license   (l)   Trivy: quét license"
    echo "    syft            Syft: tạo SBOM CycloneDX"
    echo "    grype     (g)   Grype: quét lỗ hổng (qua SBOM từ Syft)"
    echo "    osv       (o)   OSV-Scanner: quét lỗ hổng"
    echo "    dc        (d)   Dependency-Check: quét lỗ hổng (chậm)"
    echo "    all       (a)   Chạy tất cả (trừ Dependency-Check)"
    echo "    compare   (c)   So sánh kết quả các tool"
    echo "    help      (h)   Hiện hướng dẫn này"
    echo ""
    echo -e "  ${BOLD}Ví dụ:${NC}"
    echo "    demo-scan all"
    echo "    demo-scan trivy"
    echo "    demo-scan compare"
    echo ""
}

# ============================================================
# Main
# ============================================================
case "${1:-help}" in
    versions|v)  show_versions ;;
    trivy|t)     run_trivy ;;
    sbom|s)      run_trivy_sbom ;;
    license|l)   run_trivy_license ;;
    syft)        run_syft ;;
    grype|g)     run_grype ;;
    osv|o)       run_osv ;;
    dc|d)        run_dc ;;
    all|a)       run_all ;;
    compare|c)   run_compare ;;
    help|h|*)    show_help ;;
esac
