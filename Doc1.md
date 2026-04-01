# So sánh các công cụ SCA (Software Composition Analysis) miễn phí

> Tài liệu tổng hợp và so sánh các công cụ SCA phổ biến nhất hiện nay (2024-2025).
> Tập trung vào các tool miễn phí / open-source.

---

## Mục lục

1. [SCA là gì?](#1-sca-là-gì)
2. [Bảng so sánh tổng quan](#2-bảng-so-sánh-tổng-quan)
3. [Chi tiết từng công cụ](#3-chi-tiết-từng-công-cụ)
4. [So sánh Dependabot vs Dependency-Check vs Dependency-Track](#4-so-sánh-dependabot-vs-dependency-check-vs-dependency-track)
5. [Top công cụ SCA miễn phí nên dùng](#5-top-công-cụ-sca-miễn-phí-nên-dùng)
6. [Kết hợp các tool như thế nào?](#6-kết-hợp-các-tool-như-thế-nào)

---

## 1. SCA là gì?

**SCA (Software Composition Analysis)** là phương pháp phân tích các thành phần phần mềm bên thứ 3 (thư viện, framework, package) mà project của bạn sử dụng, nhằm:

- Phát hiện **lỗ hổng bảo mật đã biết** (CVE)
- Theo dõi **license** của các dependency
- Tạo **SBOM** (Software Bill of Materials) - danh sách tất cả thành phần phần mềm
- Phát hiện **supply chain attacks** (tấn công chuỗi cung ứng)

```
Code của bạn ──┐
               ├──▶ SCA Tool ──▶ Báo cáo lỗ hổng + Đề xuất fix
Dependencies ──┘
```

---

## 2. Bảng so sánh tổng quan

| Công cụ              | Miễn phí                  | Ngôn ngữ                | Tự tạo PR           | SBOM                 | Cơ sở dữ liệu                    | CI/CD         |
| -------------------- | ------------------------- | ----------------------- | ------------------- | -------------------- | -------------------------------- | ------------- |
| **Dependabot**       | Miễn phí (GitHub)         | 30+ ecosystem           | Có                  | Không                | GitHub Advisory DB               | GitHub native |
| **Dependency-Check** | Open source               | Java, .NET (chính)      | Không               | Không                | NVD, OSS Index                   | Có            |
| **Dependency-Track** | Open source               | Mọi ngôn ngữ (qua SBOM) | Không               | Quản lý SBOM         | NVD, GitHub, OSV, Snyk           | Có (API)      |
| **Trivy**            | Open source               | 15+ ngôn ngữ + OS       | Không               | Có (CycloneDX, SPDX) | 30+ nguồn                        | Có            |
| **Grype + Syft**     | Open source               | 8+ ngôn ngữ + OS        | Không               | Có (qua Syft)        | NVD, GitHub, distro              | Có            |
| **OSV-Scanner**      | Open source               | 12+ ngôn ngữ            | Guided remediation  | Quét SBOM            | OSV.dev (Google)                 | Có            |
| **Snyk**             | Freemium (400 test/tháng) | 13 ngôn ngữ             | Có                  | Có                   | Snyk DB (riêng)                  | Có            |
| **Renovate**         | Open source               | 90+ package manager     | Có (mục đích chính) | Không                | N/A (tool update)                | Đa nền tảng   |
| **Socket.dev**       | Miễn phí cho OSS          | 10+ ecosystem           | Chặn PR nguy hiểm   | Không                | Phân tích hành vi (70+ tín hiệu) | Có            |
| **npm audit**        | Miễn phí (built-in)       | JavaScript              | `npm audit fix`     | Không                | GitHub Advisory DB               | Có            |
| **pip-audit**        | Open source               | Python                  | `pip-audit --fix`   | CycloneDX            | OSV, PyUp.io                     | Có            |

---

## 3. Chi tiết từng công cụ

### 3.1. GitHub Dependabot

```
Loại:       Dịch vụ tích hợp GitHub
License:    Miễn phí (proprietary)
Website:    github.com (built-in)
```

**Cách hoạt động:**
- Quét file khai báo dependency (`requirements.txt`, `package.json`, `Dockerfile`...)
- So sánh version với GitHub Advisory Database (~28,000+ advisories)
- Tự động tạo PR để fix lỗ hổng hoặc update version

**Ưu điểm:**
- Zero setup - chỉ cần file `dependabot.yml`
- Tự động tạo PR với changelog, compatibility score
- Hỗ trợ 30+ ecosystem
- Group updates (gom nhiều package vào 1 PR)
- Hoàn toàn miễn phí

**Nhược điểm:**
- Chỉ hoạt động trên GitHub (không hỗ trợ GitLab, Bitbucket)
- Không tạo SBOM
- Không phân tích hành vi package (chỉ check CVE)
- Không có reachability analysis (không biết code có thực sự gọi hàm bị lỗi không)

---

### 3.2. OWASP Dependency-Check

```
Loại:       Scanner CLI / Plugin
License:    Apache 2.0 (Open Source)
GitHub:     github.com/dependency-check/DependencyCheck
```

**Cách hoạt động:**
- Quét dependency bằng **evidence-based engine** (thu thập vendor, product, version)
- Tải NVD database về local, so sánh dependency với CVE
- Xuất báo cáo dạng HTML, JSON, XML

**Ưu điểm:**
- Hoàn toàn miễn phí, open source
- Hỗ trợ tốt nhất cho Java/Maven và .NET
- Plugin sẵn cho Maven, Gradle, Jenkins
- Evidence-based matching giảm false negative
- Chạy offline được (sau khi tải DB)

**Nhược điểm:**
- Hỗ trợ hạn chế ngoài Java/.NET (Ruby, Node, Python chỉ ở mức experimental)
- Database local cần cập nhật thường xuyên
- Lần chạy đầu chậm (tải NVD database)
- Tỷ lệ false positive cao hơn tool thương mại
- Không tự tạo PR, không auto-fix
- Không tạo SBOM

**Ví dụ sử dụng:**
```bash
# Quét project Maven
mvn org.owasp:dependency-check-maven:check

# Quét bằng CLI
dependency-check --project "MyApp" --scan ./lib

# Output: báo cáo HTML với danh sách CVE
```

---

### 3.3. OWASP Dependency-Track

```
Loại:       Platform quản lý (Web Dashboard)
License:    Apache 2.0 (Open Source)
GitHub:     github.com/DependencyTrack/dependency-track
Website:    dependencytrack.org
```

**Cách hoạt động:**
- **KHÔNG phải scanner** - mà là platform quản lý
- Nhận SBOM từ các scanner khác (Dependency-Check, Trivy, Syft...)
- Theo dõi liên tục tất cả dependency trên toàn bộ portfolio
- Cung cấp dashboard, policy engine, và báo cáo

```
Scanner (Trivy/Syft/DC) ──▶ Tạo SBOM ──▶ Upload lên Dependency-Track
                                                      │
                                              ┌───────┴───────┐
                                              │  Dashboard    │
                                              │  - Alerts     │
                                              │  - Policies   │
                                              │  - Portfolio  │
                                              │  - Trends     │
                                              └───────────────┘
```

**Ưu điểm:**
- Quản lý SBOM tập trung cho nhiều project
- Dashboard web trực quan
- Tổng hợp từ nhiều nguồn CVE (NVD, GitHub, OSV, Snyk, OSS Index)
- Tích hợp EPSS (Exploit Prediction Scoring) để ưu tiên lỗ hổng
- Policy engine (tự động đánh giá risk)
- API-first design, dễ tích hợp

**Nhược điểm:**
- Cần server riêng để deploy (Docker/Kubernetes)
- Cần scanner bên ngoài để tạo SBOM
- Setup phức tạp hơn các CLI tool
- Không tự tạo PR, không auto-fix

**Ví dụ sử dụng:**
```bash
# Bước 1: Tạo SBOM bằng Syft
syft . -o cyclonedx-json > sbom.json

# Bước 2: Upload SBOM lên Dependency-Track
curl -X POST "https://dtrack.example.com/api/v1/bom" \
  -H "X-Api-Key: YOUR_KEY" \
  -F "project=PROJECT_UUID" \
  -F "bom=@sbom.json"

# Bước 3: Xem kết quả trên web dashboard
```

---

### 3.4. Trivy (Aqua Security)

```
Loại:       Scanner CLI all-in-one
License:    Apache 2.0 (Open Source)
GitHub:     github.com/aquasecurity/trivy
```

**Cách hoạt động:**
- Single binary, zero-config
- Quét: vulnerabilities + misconfigurations + secrets + licenses
- Hỗ trợ: container images, filesystem, git repos, Kubernetes, cloud

**Ưu điểm:**
- All-in-one: vuln + misconfig + secrets + SBOM + license
- Cực nhanh, không cần cấu hình
- Tạo SBOM (CycloneDX, SPDX)
- Hỗ trợ 15+ ngôn ngữ + tất cả OS packages
- Tổng hợp từ 30+ nguồn CVE
- Quét container image rất mạnh

**Nhược điểm:**
- Không tự tạo PR / auto-fix
- Không có web dashboard (chỉ CLI/report)
- Output có thể rất dài

**Ví dụ sử dụng:**
```bash
# Quét filesystem project
trivy fs .

# Quét Docker image
trivy image python:3.8-slim

# Tạo SBOM
trivy fs . --format cyclonedx --output sbom.json

# Chỉ hiện severity HIGH và CRITICAL
trivy fs . --severity HIGH,CRITICAL
```

---

### 3.5. Grype + Syft (Anchore)

```
Loại:       Scanner CLI + SBOM Generator
License:    Apache 2.0 (Open Source)
GitHub:     github.com/anchore/grype + github.com/anchore/syft
```

**Cách hoạt động:**
- **Syft**: tạo SBOM (danh sách dependency)
- **Grype**: quét SBOM/image/filesystem tìm CVE
- Hai tool tách biệt, phối hợp với nhau

**Ưu điểm:**
- Nhanh, nhẹ
- Tách biệt rõ ràng: Syft = SBOM, Grype = Scan
- SBOM đa format (CycloneDX, SPDX, JSON)
- Hỗ trợ EPSS, KEV scoring
- Hỗ trợ OpenVEX để filter kết quả

**Nhược điểm:**
- Scope hẹp hơn Trivy (không quét misconfig/secrets)
- Không có web UI
- Không auto-fix

**Ví dụ sử dụng:**
```bash
# Tạo SBOM bằng Syft
syft . -o cyclonedx-json > sbom.json

# Quét SBOM bằng Grype
grype sbom:sbom.json

# Hoặc pipe trực tiếp
syft . | grype

# Quét Docker image
grype python:3.8-slim
```

---

### 3.6. OSV-Scanner (Google)

```
Loại:       Scanner CLI
License:    Apache 2.0 (Open Source)
GitHub:     github.com/google/osv-scanner
Database:   osv.dev
```

**Cách hoạt động:**
- Quét lockfile/SBOM, so sánh với OSV.dev (database mở của Google)
- V2.0 (03/2025): thêm quét container image, guided remediation

**Ưu điểm:**
- Database hoàn toàn mở (không vendor lock-in)
- Advisory chất lượng cao, từ nguồn chính thức
- Guided remediation cho npm và Maven
- Quét container image (V2)
- Google hậu thuẫn

**Nhược điểm:**
- Tool còn trẻ, chưa mature bằng Trivy
- Không tự tạo PR
- Remediation chỉ hỗ trợ npm/Maven

**Ví dụ sử dụng:**
```bash
# Quét project
osv-scanner --lockfile=requirements.txt
osv-scanner --lockfile=package-lock.json

# Quét cả thư mục
osv-scanner -r .

# Guided remediation (V2)
osv-scanner fix --lockfile=package-lock.json
```

---

### 3.7. Snyk Open Source (Free Tier)

```
Loại:       Platform SCA (Freemium)
License:    Source-available (không phải OSS thuần)
Website:    snyk.io
```

**Free tier bao gồm:**
- 400 lần test SCA / tháng
- 100 lần test SAST / tháng
- 300 lần test IaC / tháng
- 100 lần test Container / tháng
- Project public/open-source: không giới hạn

**Ưu điểm:**
- Developer experience tốt nhất (IDE plugin, PR integration)
- Database CVE chất lượng cao, có remediation advice chi tiết
- Hỗ trợ 13 ngôn ngữ, 20+ package manager
- Tự tạo PR fix
- Tạo SBOM

**Nhược điểm:**
- Free tier giới hạn 400 test/tháng
- Database proprietary (vendor lock-in)
- Paid plan đắt
- Source-available, không phải open source thuần

---

### 3.8. Renovate (Mend)

```
Loại:       Tool auto-update dependency
License:    AGPL-3.0 (Open Source)
GitHub:     github.com/renovatebot/renovate
```

**So sánh với Dependabot:**

| Tính năng | Dependabot | Renovate |
|-----------|-----------|----------|
| Nền tảng | GitHub only | GitHub, GitLab, Bitbucket, Azure DevOps |
| Ecosystems | 30+ | 90+ |
| Cấu hình | Đơn giản | Rất chi tiết, linh hoạt |
| Group updates | Có | Mạnh hơn |
| Auto-merge | Cơ bản | Nâng cao (merge confidence) |
| Schedule | daily/weekly/monthly | Cron expression tùy ý |
| Setup | Zero-config | Cần cấu hình |

**Ưu điểm:**
- 90+ package manager (nhiều nhất trong tất cả tool)
- Hoạt động trên mọi Git platform
- Cấu hình cực kỳ linh hoạt
- Open source

**Nhược điểm:**
- Không phải vulnerability scanner (chỉ update version)
- Cấu hình phức tạp hơn Dependabot
- Cần self-host để kiểm soát hoàn toàn

---

### 3.9. Socket.dev

```
Loại:       Supply Chain Security
License:    Miễn phí cho OSS repos, trả phí cho private
Website:    socket.dev
```

**Điểm khác biệt:** Trong khi tất cả tool trên hỏi _"Package này có CVE không?"_, Socket hỏi _"Package này THỰC SỰ LÀM GÌ?"_

**70+ tín hiệu phân tích hành vi:**
- Package có truy cập network không?
- Có đọc/ghi filesystem không?
- Có chạy shell command không?
- Có đọc environment variables không?
- Code có bị obfuscate không?
- Có install scripts không?
- Có dấu hiệu typosquatting không?

**Ưu điểm:**
- Phát hiện supply chain attack TRƯỚC KHI có CVE
- Chặn package độc hại ngay tại PR
- Phương pháp độc đáo, bổ sung cho tool CVE-based

**Nhược điểm:**
- Không thay thế được SCA truyền thống (bổ sung)
- Trả phí cho private repos
- Phân tích hành vi chủ yếu mạnh ở JavaScript và Python

---

### 3.10. npm audit / pip-audit

**npm audit** (built-in):
```bash
npm audit                        # Quét vulnerabilities
npm audit fix                    # Auto-fix (semver-compatible)
npm audit fix --force            # Auto-fix (kể cả breaking changes)
npm audit --audit-level=high     # Chỉ báo HIGH trở lên (dùng trong CI)
```

**pip-audit** (cài riêng):
```bash
pip install pip-audit
pip-audit                        # Quét environment hiện tại
pip-audit -r requirements.txt    # Quét file requirements
pip-audit --fix                  # Auto-fix
pip-audit -f cyclonedx-json      # Xuất SBOM format
```

---

## 4. So sánh Dependabot vs Dependency-Check vs Dependency-Track

Đây là 3 tool thường bị nhầm lẫn. Thực tế chúng có vai trò **hoàn toàn khác nhau**:

```
┌─────────────────────────────────────────────────────────────────────┐
│                        VAI TRÒ KHÁC NHAU                           │
│                                                                     │
│  Dependency-Check    = SCANNER (tìm lỗ hổng)                      │
│  Dependency-Track    = PLATFORM (quản lý & theo dõi)               │
│  Dependabot          = SCANNER + AUTO-FIXER (tìm + tự sửa)        │
└─────────────────────────────────────────────────────────────────────┘
```

### So sánh chi tiết:

| Tiêu chí | Dependabot | Dependency-Check | Dependency-Track |
|----------|-----------|------------------|------------------|
| **Loại** | Dịch vụ GitHub | Scanner CLI/Plugin | Platform Web |
| **Chức năng chính** | Quét + tự tạo PR fix | Quét + báo cáo | Quản lý SBOM + theo dõi liên tục |
| **Tự quét dependency?** | Có | Có | Không (cần scanner bên ngoài) |
| **Tự tạo PR?** | Có | Không | Không |
| **Dashboard web?** | GitHub UI | Không (chỉ HTML report) | Có (dashboard riêng) |
| **SBOM?** | Không | Không | Quản lý SBOM |
| **Quản lý nhiều project?** | Từng repo riêng | Từng lần chạy riêng | Portfolio toàn bộ org |
| **Database** | GitHub Advisory | NVD | NVD + GitHub + OSV + Snyk + OSS Index |
| **Ngôn ngữ mạnh nhất** | Đa ngôn ngữ (30+) | Java, .NET | Mọi ngôn ngữ (qua SBOM) |
| **Nền tảng** | GitHub only | Mọi nơi | Self-hosted |
| **Setup** | 1 file YAML | Cài CLI/plugin | Deploy server |
| **Phù hợp cho** | Dev team dùng GitHub | Java/.NET projects | Enterprise, compliance |

### Khi nào dùng tool nào?

```
Bạn dùng GitHub và muốn auto-fix?
  └──▶ Dependabot

Bạn có project Java/.NET và cần report chi tiết?
  └──▶ Dependency-Check

Bạn quản lý nhiều project và cần compliance/SBOM?
  └──▶ Dependency-Track (+ scanner khác để tạo SBOM)

Bạn muốn tất cả trong 1 tool miễn phí?
  └──▶ Trivy
```

---

## 5. Top công cụ SCA miễn phí nên dùng

### Xếp hạng theo use case:

**1. Scanner all-in-one tốt nhất: Trivy**
- Lý do: Quét mọi thứ (vuln + misconfig + secrets + SBOM + license), nhanh, zero-config
- Phù hợp: Mọi project, mọi ngôn ngữ

**2. Auto-update tốt nhất trên GitHub: Dependabot**
- Lý do: Zero setup, tự tạo PR, miễn phí
- Phù hợp: Team dùng GitHub

**3. Auto-update tốt nhất đa nền tảng: Renovate**
- Lý do: 90+ ecosystem, GitHub/GitLab/Bitbucket, cấu hình linh hoạt
- Phù hợp: Team dùng GitLab/Bitbucket hoặc cần cấu hình nâng cao

**4. Quản lý portfolio tốt nhất: Dependency-Track**
- Lý do: Dashboard, SBOM management, policy engine, multi-source
- Phù hợp: Enterprise, compliance (ISO 27001, SOC2)

**5. Database mở tốt nhất: OSV-Scanner**
- Lý do: Database hoàn toàn mở, Google hậu thuẫn, guided remediation
- Phù hợp: Team muốn tránh vendor lock-in

**6. Phát hiện supply chain attack: Socket.dev**
- Lý do: Phương pháp unique, phát hiện malware trước khi có CVE
- Phù hợp: Bổ sung cho tool CVE-based, đặc biệt cho npm/Python

---

## 6. Kết hợp các tool như thế nào?

Không có tool nào làm tất cả. Dưới đây là các combo được khuyên dùng:

### Combo 1: Nhỏ gọn (cho team nhỏ, startup)

```
Dependabot (auto-fix PRs)
    +
Trivy (scan toàn diện trong CI)
```

### Combo 2: Đầy đủ (cho team trung bình)

```
Renovate (auto-update, đa nền tảng)
    +
Trivy (scan trong CI)
    +
Socket.dev (chặn supply chain attack)
```

### Combo 3: Enterprise (cho tổ chức lớn, compliance)

```
Dependency-Track (quản lý SBOM, dashboard, policy)
    +
Trivy hoặc Syft (tạo SBOM)
    +
Grype (scan bổ sung)
    +
Renovate (auto-update)
    +
Snyk (developer experience, IDE integration)
```

### Ví dụ CI pipeline kết hợp Dependabot + Trivy:

```yaml
# .github/workflows/security.yml
name: Security Scan

on:
  push:
    branches: [main]
  pull_request:
    branches: [main]

jobs:
  trivy-scan:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4

      - name: Trivy vulnerability scan
        uses: aquasecurity/trivy-action@master
        with:
          scan-type: 'fs'
          scan-ref: '.'
          severity: 'CRITICAL,HIGH'
          format: 'table'

      - name: Trivy SBOM generation
        uses: aquasecurity/trivy-action@master
        with:
          scan-type: 'fs'
          scan-ref: '.'
          format: 'cyclonedx'
          output: 'sbom.json'

      - name: Upload SBOM
        uses: actions/upload-artifact@v4
        with:
          name: sbom
          path: sbom.json
```

---

## Nguồn tham khảo

- [OWASP Dependency-Check](https://owasp.org/www-project-dependency-check/)
- [OWASP Dependency-Track](https://dependencytrack.org/)
- [GitHub Dependabot Docs](https://docs.github.com/en/code-security/dependabot)
- [Trivy](https://trivy.dev/)
- [Grype](https://github.com/anchore/grype) + [Syft](https://github.com/anchore/syft)
- [OSV-Scanner](https://github.com/google/osv-scanner) + [OSV.dev](https://osv.dev/)
- [Snyk](https://snyk.io/)
- [Renovate](https://github.com/renovatebot/renovate)
- [Socket.dev](https://socket.dev/)
- [pip-audit](https://pypi.org/project/pip-audit/)
