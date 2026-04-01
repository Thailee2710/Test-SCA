# Benchmark SCA Solution Report
### So sánh các Công cụ Software Composition Analysis miễn phí

**Information Security Office**

---

## I. SCA là gì và Tại sao cần triển khai?

### SCA (Software Composition Analysis) là gì?

SCA là phương pháp phân tích các thành phần phần mềm bên thứ 3 (thư viện, framework, package) mà dự án sử dụng, nhằm:

```
Code của bạn ──┐
               ├──▶ SCA Tool ──▶ Phát hiện lỗ hổng (CVE) + Đề xuất fix
Dependencies ──┘                  Theo dõi license
                                  Tạo SBOM (danh sách thành phần)
                                  Phát hiện supply chain attack
```

### Tại sao cần triển khai SCA?

| # | Thách thức | Tác động |
|---|-----------|----------|
| 1 | **Supply Chain Attack gia tăng** — Log4Shell, SolarWinds, XZ Utils | Một lỗ hổng trong dependency có thể ảnh hưởng toàn bộ hệ thống |
| 2 | **70–90% mã nguồn đến từ open source** | Bề mặt tấn công chủ yếu nằm ngoài code do tổ chức tự viết |
| 3 | **Yêu cầu compliance** — ISO 27001, SOC 2, PCI-DSS | Cần SBOM và quy trình quản lý lỗ hổng rõ ràng |
| 4 | **Thiếu quan sát tập trung** | Không có dashboard tổng thể về tình trạng bảo mật |
| 5 | **Chưa có quy trình SBOM** | Không kiểm kê được thành phần phần mềm đang sử dụng |

### Trạng thái hiện tại

| Hạng mục | Trạng thái |
|----------|------------|
| Vulnerability Scanning | Dependabot đã triển khai trên `Test-SCA` — **102 alert** (60 đang mở, 42 đã khắc phục), **23 PR** tự động (15 đang mở, 8 đã đóng) |
| SBOM Generation | Trivy và Syft tạo SBOM tự động trong CI/CD pipeline |
| Dashboard tập trung | Chưa có |
| Container Image Scanning | Chưa có |
| License Compliance | Trivy quét license trong CI (chưa cấu hình chặn vi phạm) |
| Custom Policy Enforcement | Chưa có |

---

## II. Các Công cụ Được Đánh giá

### 6 công cụ — 2 loại khác nhau

```
┌─────────────────────────────────────────────────────────────────────────┐
│  5 SCANNER (quét và phát hiện lỗ hổng)                                │
│  ┌───────────┐ ┌───────┐ ┌────────────┐ ┌─────────────┐ ┌──────────┐ │
│  │Dependabot │ │ Trivy │ │Grype + Syft│ │ OSV-Scanner │ │ DC-Check │ │
│  │(GitHub)   │ │(Aqua) │ │ (Anchore)  │ │  (Google)   │ │ (OWASP)  │ │
│  └───────────┘ └───────┘ └────────────┘ └─────────────┘ └──────────┘ │
│                                                                       │
│  1 MANAGEMENT PLATFORM (quản lý tập trung)                           │
│  ┌──────────────────────────────────────────────────────────────────┐ │
│  │  Dependency-Track (OWASP) — Nhận SBOM → Dashboard → Policy     │ │
│  └──────────────────────────────────────────────────────────────────┘ │
└─────────────────────────────────────────────────────────────────────────┘
```

| Công cụ | Loại | License | Chi phí | Vai trò |
|---------|------|---------|---------|---------|
| **Dependabot** | GitHub Service | Proprietary | Miễn phí | Scanner + Auto-fix PR |
| **Trivy** | CLI Scanner | Apache 2.0 | Miễn phí | Scanner all-in-one |
| **Grype + Syft** | CLI Scanner + SBOM Gen | Apache 2.0 | Miễn phí | Scanner + SBOM Generator |
| **OSV-Scanner** | CLI Scanner | Apache 2.0 | Miễn phí | Scanner (DB mở của Google) |
| **Dependency-Check** | CLI Scanner / Plugin | Apache 2.0 | Miễn phí | Scanner (chuyên Java/.NET) |
| **Dependency-Track** | Web Platform | Apache 2.0 | Miễn phí | SBOM Management + Dashboard |

---

## III. Bảng So sánh Tổng hợp

### 3.1 So sánh 5 Scanner

> Thang điểm: **0** = Không đáp ứng | **1** = Đáp ứng một phần | **2** = Đáp ứng
>
> In đậm = đã xác nhận qua kiểm thử thực tế. Dấu * = dự kiến, chưa kiểm thử.

| # | Tiêu chí | Dependabot | Trivy | Grype + Syft | OSV-Scanner | DC-Check |
|---|----------|------------|-------|--------------|-------------|----------|
| 1 | Phát hiện lỗ hổng (Accuracy) | **2** | 2* | 2* | 2* | 1* |
| 2 | Phạm vi DB lỗ hổng (Coverage) | **1** | 2* | 2* | 2* | 1* |
| 3 | Tạo SBOM | 0 | **2** | **2** | 1* | 0 |
| 4 | Tự tạo PR sửa lỗi (Auto-Fix) | **2** | 0 | 0 | 1* | 0 |
| 5 | Tích hợp CI/CD | **2** | **2** | **2** | **2** | **2** |
| 6 | Hỗ trợ đa ngôn ngữ | **2** | 2* | 2* | 2* | 1* |
| 7 | Quét Container Image | 0 | 2* | 2* | 1* | 0 |
| 8 | Phát hiện License | 0 | 2* | 1* | 0 | 0 |
| 9 | Tỷ lệ False Positive (cao = tốt) | **2** | 2* | 2* | 2* | 1* |
| 10 | Tốc độ quét | **2** | 2* | 2* | 2* | 1* |
| 11 | Hoạt động Offline | 0 | 2* | 2* | 0 | 2* |
| 12 | Phát hiện Transitive Dependency | **2** | 2* | 2* | 1* | 1* |
| 13 | Báo cáo & Dashboard | **1** | 1* | 1* | 1* | 2* |
| 14 | Dễ cài đặt & bảo trì | **2** | 2* | 2* | 2* | 1* |
| 15 | Custom Policy Enforcement | **1** | 2* | 1* | 1* | 1* |

### 3.2 So sánh Management Platform (Dependency-Track)

| Tiêu chí | Dependency-Track | Dependabot (GitHub UI) | Trivy |
|----------|-----------------|------------------------|-------|
| Dashboard portfolio (nhiều dự án) | 2* | 1 – Từng repo riêng | 0 |
| Quản lý SBOM tập trung | 2* | 0 | 0 |
| Policy Engine tự động | 2* (GUI/API) | 0 | 1* (Rego file) |
| Theo dõi liên tục (không cần quét lại) | 2* | 2 – Quét daily | 0 – Cần chạy lại |
| Thông báo (Slack, Teams, Email, Jira) | 2* | 1 – GitHub notification | 0 |
| Tìm kiếm component toàn portfolio | 2* | 0 | 0 |
| Custom Policy Enforcement | 2* | 1 | 2* |
| Audit Trail / Compliance | 2* | 1 | 0 |

### 3.3 Công cụ Tốt nhất theo Vai trò

| Vai trò | Công cụ Tốt nhất | Lý do |
|---------|------------------|-------|
| **Tự sửa lỗi** (Auto-Remediation) | Dependabot | Tự tạo PR, zero-setup, miễn phí trên GitHub |
| **Quét lỗ hổng** (Vulnerability Scan) | Trivy | All-in-one, 30+ nguồn DB, nhanh, đa ngôn ngữ |
| **Tạo SBOM** | Trivy hoặc Syft | CycloneDX và SPDX |
| **Quét Container** | Trivy | Hàng đầu ngành, full layer analysis |
| **Quản lý tập trung** | Dependency-Track | Dashboard, policy engine, SBOM management |
| **Ít cảnh báo sai nhất** | OSV-Scanner | DB mở, kiểm duyệt bởi maintainer chính thức |
| **Quét Java/.NET** | Dependency-Check | Evidence-based, quét binary `.jar`/`.dll` |
| **Custom Policy** | Trivy (CI) + DT (platform) | Trivy: OPA/Rego. DT: GUI Policy Engine |

---

## IV. Hỗ trợ Ngôn ngữ theo Từng Team Dev

### 4.1 Tổng quan

| Ngôn ngữ | Dependabot | Trivy | Grype + Syft | OSV-Scanner | DC-Check |
|----------|------------|-------|--------------|-------------|----------|
| Python | Có | Có | Có | Có | Experimental |
| JavaScript / TypeScript | Có | Có | Có | Có | Experimental |
| Java / Kotlin | Có | Có | Có | Có | **Tốt nhất** |
| .NET / C# | Có | Có | Có | Có | **Tốt nhất** |
| Go | Có | Có | Có | Có | Có |
| Ruby | Có | Có | Có | Có | Experimental |
| Rust | Có | Có | Có | Có | — |
| PHP | Có | Có | Có | Có | Experimental |
| C / C++ (Conan) | — | Có | Có | Có | — |
| Swift / iOS | Có | Có | Có | — | — |
| Dart / Flutter | Có | Có | Có | Có | — |
| Elixir | Có | Có | Có | Có | — |

### 4.2 Tra cứu Nhanh: Team dùng Ngôn ngữ X → Chọn Tool nào?

| Team | Tổ hợp Khuyến nghị | Ghi chú |
|------|---------------------|---------|
| **Python** | Dependabot + Trivy | Phủ rộng nhất: pip, Pipenv, Poetry, uv, conda |
| **JavaScript / TS** | Dependabot + Trivy | npm, yarn, pnpm. Bun cần `bun.lock` text format |
| **Java / Kotlin** | Dependabot + Trivy + DC-Check | DC-Check quét binary `.jar` tốt nhất |
| **.NET / C#** | Dependabot + Trivy + DC-Check | DC-Check quét binary `.dll`/`.nupkg` |
| **Go** | Dependabot + Trivy | Trivy quét cả Go binary đã compile |
| **Rust** | Dependabot + Trivy | Trivy quét binary `cargo-auditable` |
| **PHP** | Dependabot + Trivy | Composer đầy đủ |
| **C / C++** | Trivy | Dependabot không hỗ trợ Conan |
| **Swift / iOS** | Dependabot + Trivy | Swift PM + CocoaPods |
| **Dart / Flutter** | Dependabot + Trivy | pub (pubspec.yaml/pubspec.lock) |
| **Container / DevOps** | Trivy | Nhiều distro nhất, layer analysis, SBOM |
| **IaC (Terraform, K8s)** | Dependabot + Trivy | Dependabot: update. Trivy: quét misconfig |

---

## V. Custom Policy — Bắt Vi phạm theo Chính sách Công ty

### 5.1 Tổng quan

Chỉ có **3 công cụ** hỗ trợ custom policy mạnh:

| Công cụ | Mức độ | Cơ chế | Phù hợp cho |
|---------|--------|--------|-------------|
| **Dependency-Track** | Mạnh nhất | GUI / REST API — Policy Engine | Quản lý tập trung, enterprise |
| **Trivy** | Rất mạnh | File `.trivy.yaml` + OPA/Rego policy | Chặn sớm tại CI/CD |
| **Grype** | Cơ bản | File `.grype.yaml` ignore rules | Lọc kết quả scan |

### 5.2 So sánh Chi tiết

| Loại Policy | Dependabot | Trivy | Grype | OSV-Scanner | DC-Check | DT-Track |
|-------------|-----------|-------|-------|-------------|----------|----------|
| Chặn theo Severity | — | **Có** | **Có** | — | **Có** | **Có** |
| Cấm License (GPL, AGPL...) | — | **Có** | — | — | — | **Có** |
| Bỏ qua CVE cụ thể | — | **Có** | **Có** | **Có** | **Có** | **Có** |
| Hết hạn bỏ qua (auto-expire) | — | **Có** | — | **Có** | — | — |
| Chặn theo EPSS score | — | — | — | — | — | **Có** |
| Chặn theo CWE | — | **Có** | — | — | — | **Có** |
| Chặn component quá cũ | — | **Có** | — | — | — | **Có** |
| Custom rule tùy ý | — | **Có** (Rego) | — | — | — | — |
| GUI quản lý policy | — | — | — | — | — | **Có** |
| Audit trail | — | — | — | — | — | **Có** |
| Gán policy theo project/team | — | — | — | — | — | **Có** |

### 5.3 Khuyến nghị: 2 lớp Policy

```
LỚP 1 – CI/CD (chặn sớm tại PR)
┌─────────────────────────────────────────────┐
│  Trivy + OPA/Rego policy                    │
│  • Chặn CI nếu có CVE Critical/High         │
│  • Chặn CI nếu có license GPL/AGPL          │
│  • Developer nhận feedback ngay tại PR       │
└─────────────────────┬───────────────────────┘
                      │
LỚP 2 – PLATFORM (quản lý tập trung)
┌─────────────────────┴───────────────────────┐
│  Dependency-Track Policy Engine             │
│  • Policy tập trung cho toàn portfolio      │
│  • EPSS-based prioritization                │
│  • Audit trail cho compliance               │
│  • Ban lãnh đạo review trên dashboard       │
└─────────────────────────────────────────────┘
```

---

## VI. Dependency-Track — Management Platform

### 6.1 Dependency-Track KHÔNG phải Scanner

```
 Dependency-Check  = SCANNER       → "Anh thợ đi kiểm tra"
 Dependency-Track  = PLATFORM      → "Anh quản lý tòa nhà"
 Dependabot        = SCANNER + FIX → "Anh thợ kiểm tra + tự sửa"
```

### 6.2 Kiến trúc

```
 Scanner (Trivy/Syft)  ──▶  Tạo SBOM  ──▶  Upload lên Dependency-Track
                                                       │
                                               ┌───────┴───────┐
                                               │  Dashboard    │
                                               │  • Portfolio  │
                                               │  • Alerts     │
                                               │  • Policies   │
                                               │  • Trends     │
                                               │  • Compliance │
                                               └───────────────┘
```

### 6.3 Tính năng Chính

| Tính năng | Mô tả |
|-----------|-------|
| **SBOM Management** | Quản lý SBOM tập trung (chỉ CycloneDX, không hỗ trợ SPDX từ v4.x) |
| **Continuous Monitoring** | Liên tục đối chiếu component với lỗ hổng mới, không cần quét lại |
| **Multi-Source Vuln DB** | NVD + GitHub Advisory + OSV + OSS Index + Trivy DB (Snyk cần enterprise) |
| **EPSS Integration** | Ưu tiên xử lý lỗ hổng có xác suất bị khai thác cao nhất |
| **Policy Engine** | Tự động đánh giá risk: severity, license, CWE, EPSS, version distance |
| **Portfolio Management** | Quản lý tất cả dự án trên 1 dashboard |
| **Component Search** | Khi có lỗ hổng mới → tìm ngay tất cả dự án bị ảnh hưởng |
| **Notification** | Slack, Microsoft Teams, Email, Jira, Webhook |
| **REST API** | Tự động hóa hoàn toàn qua CI/CD |

### 6.4 Triển khai

**Phương án khuyến nghị: Docker Compose**

```yaml
# docker-compose.yml (rút gọn)
services:
  dtrack-apiserver:
    image: dependencytrack/apiserver:latest
    ports: ["8081:8080"]
    environment:
      - ALPINE_DATABASE_URL=jdbc:postgresql://postgres:5432/dtrack

  dtrack-frontend:
    image: dependencytrack/frontend:latest
    ports: ["8080:8080"]
    environment:
      - API_BASE_URL=http://localhost:8081

  postgres:
    image: postgres:16-alpine
    environment:
      - POSTGRES_DB=dtrack
```

```bash
docker compose up -d
# Truy cập: http://localhost:8080 (admin / admin)
```

**Yêu cầu tài nguyên:**

| Tài nguyên | Tối thiểu | Khuyến nghị |
|-----------|-----------|-------------|
| CPU | 2 core | 4 core |
| RAM | 4 GB | 16 GB |
| Disk | 10 GB | 50 GB |

---

## VII. Kết quả Demo Dependabot (đã triển khai)

### Kết quả thực tế trên repository `Test-SCA`

```
 requirements.txt ─┐
 package.json ─────┤     ┌──────────────────┐     ┌──────────────────┐
 package-lock.json ┼──▶  │ Dependabot quét  │────▶│ 102 Alerts       │
 Dockerfile ───────┤     │ (daily)          │     │ (60 đang mở)     │
 ci.yml ───────────┘     └────────┬─────────┘     │ 5 Critical       │
                                  │               │ 23 High          │
                                  ▼               │ 25 Medium        │
                         ┌──────────────────┐     │ 7 Low            │
                         │ 23 PRs tự động   │     └──────────────────┘
                         │ 15 Open, 8 Closed│
                         └──────────────────┘
```

### Phân bố Alert theo Package

**Python:**

| Package | Version | Số Alert | Severity cao nhất | PR Fix |
|---------|---------|----------|-------------------|--------|
| Pillow | 8.2.0 | 12 | Critical | #14 → 12.1.1 |
| urllib3 | 1.23 | 10 | High | #8 → 2.6.3 |
| Jinja2 | 2.10 | 6 | High | #2 → 3.1.6 |
| requests | 2.19.0 | 5 | High | #22 → 2.33.1 |
| PyYAML | 5.3 | 2 | Critical | #3 → 6.0.3 |
| Flask | 1.0 | 2 | High | #15 → 3.1.3 (CI fail) |

**Node.js:**

| Package | Version | Số Alert | Severity cao nhất | PR Fix |
|---------|---------|----------|-------------------|--------|
| express | 4.17.1 | 12 (2 trực tiếp + 10 sub-dep) | High | #9 → 5.2.1 |
| serialize-javascript | 1.9.0 | 4 | High | #20 → 7.0.5 |
| lodash | 4.17.20 | 3 | High | #23 → 4.17.21 |
| moment | 2.29.1 | 2 | High | #1 → 2.30.1 |
| jquery | 3.4.1 | 2 | Medium | #11 → 4.0.0 |

### Đánh giá Dependabot

```
✅ 102 security alert (60 đang mở, 42 đã khắc phục) — hoạt động đúng
✅ 23 PR tự động kèm changelog, compatibility score (15 đang mở, 8 đã đóng)
✅ Phủ 4 ecosystem: pip, npm, docker, github-actions
✅ CI chạy tự động trên mỗi PR — phát hiện breaking change
✅ PR cũ tự đóng khi có version mới — tự dọn dẹp

⚠️ Chỉ hoạt động trên GitHub
⚠️ Không tạo SBOM
⚠️ Không có dashboard tập trung
⚠️ Không tạo SBOM
⚠️ Không có dashboard tập trung
⚠️ Không có custom policy enforcement
```

---

### Kết quả Multi-Tool Scanning (GitHub Actions — đã tích hợp)

Ngoài Dependabot, **4 scanner** đã được tích hợp vào CI/CD pipeline (`.github/workflows/sca-scan.yml`) và chạy thành công trên repository `Test-SCA`:

| Tool | Trạng thái CI | Kết quả Code Scanning | Output Artifact |
|------|---------------|----------------------|-----------------|
| **Trivy** | ✅ SUCCESS | **40 alert** (5C / 12H / 21M / 2L) → GitHub Security tab | CycloneDX SBOM (3.2KB) + license scan |
| **Grype + Syft** | ✅ SUCCESS | **60 alert** (6C / 23H / 28M / 3L) → GitHub Security tab | CycloneDX SBOM × 2 (Syft 6.7KB + Grype 6.7KB) |
| **OSV-Scanner** | ✅ SUCCESS | 0 alert riêng biệt (đã phủ bởi Grype/Trivy — GitHub tự dedup) | SARIF uploaded |
| **OWASP DC** | ✅ SUCCESS | HTML report 63KB | Artifact (không tích hợp Security tab) |

**Tổng GitHub Security tab (Code Scanning):** 100 alert đang mở — Grype: 60, Trivy: 40

**SBOM artifacts từ CI/CD mỗi push lên main:**
- `sbom-trivy.json` — CycloneDX JSON, Trivy (3.2KB)
- `sbom-syft.json` — CycloneDX JSON, Syft (6.7KB)
- `Test-SCA-grype.cyclonedx.json` — CycloneDX JSON, Grype via Syft (6.7KB)
- `dependency-check-report/` — HTML report, OWASP DC (63KB)

> **Ghi chú OSV-Scanner:** Tool chạy thành công và upload SARIF, nhưng GitHub Security tab hiển thị 0 alert riêng biệt vì toàn bộ lỗ hổng đã được Grype và Trivy phát hiện (GitHub tự merge duplicate alerts giữa các tool).

> **Ghi chú OWASP DC:** Tool chạy thành công nhưng kết quả chỉ xuất ra HTML artifact, không tích hợp vào GitHub Security tab (không có SARIF upload). Cần NVD API Key để đạt phạm vi phủ tối đa.

---

## VIII. Khuyến nghị Tổ hợp Công cụ

### Dành cho Team Nhỏ / Startup

```
Dependabot (auto-fix PR)  ←  Đã triển khai
    +
Trivy (quét toàn diện + SBOM)  ←  Đã tích hợp vào CI/CD
```

### Dành cho Team Trung bình (5–20 dự án)

```
Dependabot (auto-fix PR)  ←  Đã triển khai
    +
Trivy + Grype + OSV-Scanner (quét + SBOM trong CI)  ←  Đã tích hợp vào CI/CD
    +
Dependency-Track (dashboard + policy)  ←  Cần triển khai
```

### Dành cho Enterprise / Compliance

```
Trivy hoặc Syft (SBOM) + Grype (scan bổ sung)
    +
Dependency-Track (dashboard + SBOM + policy)
    +
Dependabot hoặc Renovate (auto-fix)
```

### Luồng CI/CD Hiện tại (đã triển khai)

```
Developer push code
       │
       ▼
┌──────────────────────────────────────────────┐
│  sca-scan.yml (GitHub Actions)               │
│                                              │
│  ✅ Trivy — fs scan → SARIF + SBOM artifact  │
│  ✅ Trivy — license scan (log only)          │
│  ✅ Grype + Syft — SARIF + SBOM artifact     │
│  ✅ OSV-Scanner — SARIF (0 dedup alerts)     │
│  ✅ OWASP DC — HTML artifact                 │
│                                              │
│  ⚠️ Chưa cấu hình fail-build (không chặn)   │
│  ⚠️ Chưa upload SBOM lên Dependency-Track   │
└──────────────────────────────────────────────┘
       │
       ▼
┌──────────────────────────────────────────────┐
│  Dependabot (tự động, daily)                 │
│  ✅ Tạo PR fix lỗ hổng (23 PR tổng cộng)    │
│  ✅ CI test trên mỗi PR                      │
└──────────────────────────────────────────────┘
```

### Luồng CI/CD Mục tiêu (khuyến nghị — chưa triển khai)

```
Developer push code
       │
       ▼
┌──────────────────────────────────┐
│  CI/CD Pipeline                  │
│                                  │
│  1. Trivy quét lỗ hổng          │
│     → Chặn nếu Critical/High    │
│                                  │
│  2. Trivy quét license           │
│     → Chặn nếu GPL/AGPL         │
│                                  │
│  3. Trivy tạo SBOM (CycloneDX)  │
│                                  │
│  4. Upload SBOM → DT-Track      │
│                                  │
│  5. Build & Deploy               │
└──────────────────────────────────┘
       │
       ▼
┌──────────────────────────────────┐
│  Dependency-Track (liên tục)     │
│  • Theo dõi lỗ hổng mới         │
│  • Policy engine đánh giá risk   │
│  • Alert qua Slack/Teams/Email   │
│  • Dashboard cho ban lãnh đạo    │
└──────────────────────────────────┘
```

---

## IX. Kết quả Kỳ vọng

### Ngắn hạn (1–3 tháng)

| # | Kỳ vọng | Chỉ số |
|---|---------|--------|
| 1 | Tất cả repo chính được quét tự động | 100% repo có SCA trong CI/CD |
| 2 | Lỗ hổng Critical/High phát hiện ≤ 24h | MTTD ≤ 24h |
| 3 | SBOM tự động cho mỗi release | 100% release có SBOM |
| 4 | Giảm thời gian phản hồi | MTTR giảm ≥ 50% |

### Trung hạn (3–6 tháng)

| # | Kỳ vọng | Chỉ số |
|---|---------|--------|
| 5 | Dashboard tập trung hoạt động | ≥ 80% dự án trên Dependency-Track |
| 6 | Policy engine tự động | 100% dự án có policy |
| 7 | Sẵn sàng cho audit | Xuất báo cáo compliance trong 1 ngày |
| 8 | License compliance | 100% dependency được kiểm tra license |

### Dài hạn (6–12 tháng)

| # | Kỳ vọng | Chỉ số |
|---|---------|--------|
| 9 | SCA gate bắt buộc trong SDLC | 100% dự án có SCA gate |
| 10 | Giảm lỗ hổng tồn đọng | Critical/High giảm ≥ 70% |
| 11 | Developer chủ động bảo mật | Xử lý SCA alert mà không cần nhắc |

---

## X. Lộ trình Triển khai

```
 Giai đoạn 1             Giai đoạn 2             Giai đoạn 3             Giai đoạn 4
 ĐÁNH GIÁ               TÍCH HỢP CI/CD          DEPENDENCY-TRACK        HOÀN THIỆN
 (Tháng 1–2)            (Tháng 2–3)             (Tháng 3–4)             (Tháng 4–6)
 ┌─────────────┐        ┌─────────────┐         ┌─────────────┐         ┌─────────────┐
 │• Cài & test │        │• Workflow    │         │• Deploy DT  │         │• SCA gate   │
 │  Trivy      │───────▶│  template   │────────▶│  (Docker)   │────────▶│  bắt buộc   │
 │• Cài & test │        │• SBOM gen   │         │• Upload SBOM│         │• SLA xử lý  │
 │  Grype+Syft │        │• Rollout    │         │• Notification│        │• Đào tạo    │
 │• Cài & test │        │  all repos  │         │• Policy     │         │  developer  │
 │  OSV-Scanner│        │• Severity   │         │  engine     │         │• Đánh giá   │
 │• Cài & test │        │  threshold  │         │             │         │  hiệu quả   │
 │  DC-Check   │        │• Docs       │         │             │         │             │
 │• Chọn combo │        │             │         │             │         │             │
 └─────────────┘        └─────────────┘         └─────────────┘         └─────────────┘
```

### Hạng mục ưu tiên cao

| # | Hạng mục | Giai đoạn | Trạng thái |
|---|----------|-----------|------------|
| 1 | Cài đặt và kiểm thử **Trivy** | GĐ 1 | **Đã hoàn thành** — CI chạy, 60 alert |
| 2 | Cài đặt và kiểm thử **Grype + Syft** | GĐ 1 | **Đã hoàn thành** — CI chạy, 60 alert |
| 3 | Chọn tổ hợp công cụ, trình phê duyệt | GĐ 1 | Chưa thực hiện |
| 4 | Tạo CI/CD workflow template | GĐ 2 | **Đã hoàn thành** — `.github/workflows/sca-scan.yml` |
| 5 | Tích hợp SBOM generation vào pipeline | GĐ 2 | **Đã hoàn thành** — Trivy (CycloneDX) + Syft SBOM artifact |
| 6 | Triển khai **Dependency-Track** (Docker) | GĐ 3 | Chưa thực hiện |
| 7 | Cấu hình policy engine + notification | GĐ 3 | Chưa thực hiện |
| 8 | Thiết lập SCA gate + SLA xử lý | GĐ 4 | Chưa thực hiện |

---

## XI. Rủi ro và Giảm thiểu

| Rủi ro | Tác động | Giảm thiểu |
|--------|----------|------------|
| Developer bỏ qua SCA alert | Lỗ hổng không được sửa | SLA theo severity, SCA gate chặn deploy, đào tạo |
| False positive gây "alert fatigue" | Mất niềm tin vào tool | Chọn scanner có FP thấp, cấu hình suppression |
| Dependency-Track server sự cố | Mất dashboard | Backup, HA deployment (K8s), monitoring |
| Breaking change khi merge PR | App lỗi trên production | CI test bắt buộc, không auto-merge major version |

---

## XII. Tài liệu Tham khảo

| # | Tài liệu | Link |
|---|----------|------|
| 1 | Benchmark SCA Solution Report (chi tiết) | `Benchmark SCA Solution Report.md` (nội bộ) |
| 2 | GitHub Dependabot Documentation | docs.github.com/en/code-security/dependabot |
| 3 | Trivy Documentation | trivy.dev/latest/docs/ |
| 4 | Grype + Syft | github.com/anchore/grype, github.com/anchore/syft |
| 5 | OSV-Scanner | github.com/google/osv-scanner |
| 6 | OWASP Dependency-Check | owasp.org/www-project-dependency-check/ |
| 7 | OWASP Dependency-Track | dependencytrack.org |
| 8 | CycloneDX SBOM Standard | cyclonedx.org |
