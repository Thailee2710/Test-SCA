# Benchmark Software Composition Analysis (SCA) Solution Report

## Dependabot vs Trivy vs Grype/Syft vs OSV-Scanner vs OWASP Dependency-Check vs OWASP Dependency-Track

---

**Information Security Office**

---

### Tuyên bố Bảo mật

MẬT – Thông tin trong báo cáo này mang tính nhạy cảm và bảo mật. Do đó, chúng tôi khuyến nghị ban lãnh đạo xử lý báo cáo này như tài liệu mật, hạn chế phân phối và kiểm soát việc tạo bản sao bổ sung.

---

## Mục lục

- [I. Lịch sử Chỉnh sửa](#i-lịch-sử-chỉnh-sửa)
- [II. Tài liệu Tham khảo](#ii-tài-liệu-tham-khảo)
- [III. Tóm tắt Tổng quan](#iii-tóm-tắt-tổng-quan)
  - [3.1 Tóm tắt](#31-tóm-tắt)
  - [3.2 Bối cảnh và Lý do Triển khai](#32-bối-cảnh-và-lý-do-triển-khai)
  - [3.3 Kết quả Kỳ vọng](#33-kết-quả-kỳ-vọng)
  - [3.4 Phạm vi](#34-phạm-vi)
  - [3.5 Nhóm Dự án](#35-nhóm-dự-án)
  - [3.6 Kết luận](#36-kết-luận)
- [IV. Phương pháp và Kết quả](#iv-phương-pháp-và-kết-quả)
  - [Benchmark 1 – Production Metric](#benchmark-1--production-metric)
  - [Benchmark 2 – Vulnerability Detection Accuracy](#benchmark-2--vulnerability-detection-accuracy)
  - [Benchmark 3 – Vulnerability Database Coverage](#benchmark-3--vulnerability-database-coverage)
  - [Benchmark 4 – SBOM Generation](#benchmark-4--sbom-generation)
  - [Benchmark 5 – Auto-Remediation (PR Creation / Auto-Fix)](#benchmark-5--auto-remediation-pr-creation--auto-fix)
  - [Benchmark 6 – CI/CD Integration](#benchmark-6--cicd-integration)
  - [Benchmark 7 – Multi-Language and Ecosystem Support](#benchmark-7--multi-language-and-ecosystem-support)
  - [Benchmark 8 – Container Image Scanning](#benchmark-8--container-image-scanning)
  - [Benchmark 9 – License Compliance Detection](#benchmark-9--license-compliance-detection)
  - [Benchmark 10 – False Positive Rate](#benchmark-10--false-positive-rate)
  - [Benchmark 11 – Scan Performance (Speed)](#benchmark-11--scan-performance-speed)
  - [Benchmark 12 – Offline Capability](#benchmark-12--offline-capability)
  - [Benchmark 13 – Transitive Dependency Detection](#benchmark-13--transitive-dependency-detection)
  - [Benchmark 14 – Reporting and Dashboard](#benchmark-14--reporting-and-dashboard)
  - [Benchmark 15 – Ease of Setup and Maintenance](#benchmark-15--ease-of-setup-and-maintenance)
  - [Benchmark 16 – Custom Policy Enforcement](#benchmark-16--custom-policy-enforcement)
- [V. OWASP Dependency-Track – Management Platform](#v-owasp-dependency-track--management-platform)
  - [5.1 Phân biệt Dependency-Check và Dependency-Track](#51-phân-biệt-dependency-check-và-dependency-track)
  - [5.2 Kiến trúc và Cách hoạt động](#52-kiến-trúc-và-cách-hoạt-động)
  - [5.3 Phương án Triển khai (Deployment)](#53-phương-án-triển-khai-deployment)
  - [5.4 Tính năng Chính](#54-tính-năng-chính)
  - [5.5 Đánh giá Dependency-Track](#55-đánh-giá-dependency-track)

---

## I. Lịch sử Chỉnh sửa

| Rev | Nội dung chỉnh sửa | Ngày |
|-----|---------------------|------|
| 1 | Phiên bản đầu tiên của báo cáo | 18/03/2026 |
| 2 | Bổ sung OWASP Dependency-Track (management platform), bối cảnh triển khai, kết quả kỳ vọng, lộ trình triển khai chi tiết, kế hoạch tương lai và phân tích rủi ro | 19/03/2026 |
| 3 | Bổ sung Benchmark 16 – Custom Policy Enforcement: đánh giá chi tiết khả năng tùy chỉnh policy của tất cả công cụ, bao gồm cấu hình mẫu và khuyến nghị kết hợp 2 lớp | 19/03/2026 |
| 4 | Mở rộng Benchmark 7 – Multi-Language and Ecosystem Support: chi tiết manifest/lock file cho 12+ ngôn ngữ, bảng tra cứu nhanh theo team, khuyến nghị công cụ theo ngôn ngữ | 19/03/2026 |
| 5 | Review và sửa lỗi toàn bộ report: Dependabot 29 ecosystem (không phải 30+), không hỗ trợ Conan/setup.cfg; Trivy Rust chỉ cargo-auditable; Grype không có EPSS filter flag; OSV-Scanner hỗ trợ Dart/Elixir/C++; DC-Check hỗ trợ Go/PHP; DT chỉ CycloneDX (không SPDX), RAM khuyến nghị 16GB, Snyk cần enterprise license | 19/03/2026 |
| 6 | Cập nhật số liệu thực tế: 102 security alert (60 đang mở, 42 đã khắc phục), 23 pull request (15 đang mở, 8 đã đóng); cập nhật phân bố lỗ hổng theo package (Pillow 12, urllib3 10, Jinja2 6, requests 5, serialize-javascript 4, express 2+10 sub-dep); cập nhật trạng thái CI/CD — Trivy, Grype+Syft, OSV-Scanner đã tích hợp vào GitHub Actions; Trivy và Syft tạo SBOM tự động; cập nhật lộ trình theo kết quả thực tế | 01/04/2026 |

---

## II. Tài liệu Tham khảo

| STT | Tài liệu | Tác giả | Năm |
|-----|----------|---------|-----|
| 1 | GitHub Dependabot Documentation | GitHub, Inc. | 2025 |
| 2 | Trivy Documentation | Aqua Security | 2025 |
| 3 | Grype & Syft Documentation | Anchore, Inc. | 2025 |
| 4 | OSV-Scanner Documentation | Google Open Source | 2025 |
| 5 | OWASP Dependency-Check Documentation | OWASP Foundation | 2025 |
| 6 | OWASP Dependency-Track Documentation | OWASP Foundation | 2025 |
| 7 | Test-SCA Repository – Dependabot Demo | Nội bộ | 2026 |

---

## III. Tóm tắt Tổng quan

### 3.1 Tóm tắt

Software Composition Analysis (SCA) là thành phần quan trọng trong bảo mật ứng dụng hiện đại. Các công cụ SCA phân tích các thành phần bên thứ 3 (thư viện, framework, package) được sử dụng trong dự án nhằm phát hiện lỗ hổng bảo mật đã biết (CVE), theo dõi license, tạo SBOM (Software Bill of Materials) và nhận diện rủi ro chuỗi cung ứng (supply chain risk).

Nhóm đã triển khai **GitHub Dependabot** trên repository `Test-SCA`, kết quả cho thấy khả năng phát hiện lỗ hổng thành công trên 4 ecosystem (pip, npm, Docker, GitHub Actions) — tạo ra **102 security alert** (60 đang mở, 42 đã khắc phục) và **23 pull request** tự động (15 đang mở, 8 đã đóng).

Để xác định giải pháp SCA miễn phí tốt nhất cho việc áp dụng rộng rãi, chúng tôi đã lựa chọn và đã tích hợp 4 công cụ scanner bổ sung vào CI/CD pipeline (GitHub Actions):

- **Trivy** (Aqua Security) – Scanner all-in-one
- **Grype + Syft** (Anchore) – Vulnerability scanner chuyên dụng + SBOM generator
- **OSV-Scanner** (Google) – Scanner sử dụng cơ sở dữ liệu lỗ hổng mở
- **OWASP Dependency-Check** – Scanner dựa trên evidence-based matching

Ngoài ra, báo cáo cũng đánh giá **OWASP Dependency-Track** — một management platform (không phải scanner) đóng vai trò trung tâm quản lý SBOM, theo dõi lỗ hổng liên tục và cung cấp dashboard tập trung cho toàn bộ portfolio ứng dụng.

### 3.2 Bối cảnh và Lý do Triển khai

#### Tại sao cần triển khai SCA?

Trong bối cảnh an ninh mạng ngày càng phức tạp, các tổ chức phải đối mặt với nhiều thách thức liên quan đến thành phần phần mềm bên thứ 3:

1. **Gia tăng tấn công chuỗi cung ứng (Supply Chain Attack):** Các cuộc tấn công nhắm vào dependency phần mềm đang gia tăng mạnh. Các sự cố nổi bật như Log4Shell (CVE-2021-44228), SolarWinds và XZ Utils (CVE-2024-3094) cho thấy rủi ro nghiêm trọng khi không quản lý tốt các thành phần bên thứ 3.

2. **Tỷ lệ mã nguồn mở trong ứng dụng cao:** Theo thống kê ngành, 70–90% mã nguồn trong ứng dụng hiện đại đến từ thư viện open source. Điều này đồng nghĩa với việc phần lớn bề mặt tấn công nằm ngoài mã nguồn do tổ chức tự phát triển.

3. **Yêu cầu tuân thủ ngày càng chặt chẽ:** Các tiêu chuẩn và quy định như ISO 27001, SOC 2, PCI-DSS và Executive Order 14028 (Mỹ) yêu cầu tổ chức phải có khả năng kiểm kê và theo dõi tất cả thành phần phần mềm (SBOM), đồng thời chứng minh quy trình quản lý lỗ hổng.

4. **Thiếu khả năng quan sát tập trung:** Hiện tại, việc theo dõi lỗ hổng trong dependency được thực hiện rời rạc trên từng repository riêng lẻ. Không có dashboard tập trung để ban lãnh đạo và đội ngũ bảo mật nắm bắt tình trạng bảo mật tổng thể trên toàn bộ portfolio ứng dụng.

5. **Không có quy trình SBOM:** Tổ chức chưa có khả năng tạo và quản lý SBOM — yêu cầu bắt buộc trong nhiều hợp đồng và quy trình compliance hiện đại.

#### Trạng thái hiện tại

| Hạng mục | Trạng thái | Đánh giá |
|----------|------------|----------|
| Vulnerability scanning trên GitHub | Dependabot đã triển khai trên `Test-SCA` | Hoạt động tốt, nhưng chỉ giới hạn trên GitHub |
| SBOM Generation | Trivy và Syft tạo SBOM tự động trong CI/CD pipeline | Đã tích hợp vào GitHub Actions |
| Dashboard tập trung | Chưa có | Cần triển khai |
| Container Image Scanning | Chưa có (Dependabot chỉ bump tag `FROM`) | Cần triển khai |
| License Compliance | Chưa có | Cần triển khai |
| Policy Enforcement | Chưa có | Cần triển khai |
| Quản lý portfolio đa dự án | Chưa có | Cần triển khai |

### 3.3 Kết quả Kỳ vọng

Sau khi hoàn thành đánh giá và triển khai các công cụ SCA được chọn, tổ chức kỳ vọng đạt được:

#### Kết quả Ngắn hạn (1–3 tháng)

| # | Kết quả Kỳ vọng | Chỉ số Đo lường |
|---|-----------------|-----------------|
| 1 | Tất cả repository chính được quét vulnerability tự động | 100% repository có SCA scanner tích hợp trong CI/CD |
| 2 | Lỗ hổng Critical/High được phát hiện và thông báo trong vòng 24 giờ | Thời gian từ disclosure đến detection ≤ 24h |
| 3 | SBOM được tạo tự động cho mỗi bản build/release | 100% release có SBOM đi kèm (CycloneDX hoặc SPDX) |
| 4 | Giảm thời gian phản hồi lỗ hổng | Mean Time to Remediate (MTTR) giảm ≥ 50% so với quy trình thủ công |

#### Kết quả Trung hạn (3–6 tháng)

| # | Kết quả Kỳ vọng | Chỉ số Đo lường |
|---|-----------------|-----------------|
| 5 | Dashboard tập trung hiển thị tình trạng bảo mật toàn portfolio | Dependency-Track dashboard hoạt động với ≥ 80% dự án |
| 6 | Policy engine tự động đánh giá risk cho mỗi dự án | 100% dự án được đánh giá risk tự động |
| 7 | Báo cáo compliance sẵn sàng cho audit | Có thể xuất báo cáo SBOM + vulnerability cho auditor trong vòng 1 ngày làm việc |
| 8 | License compliance được kiểm soát | 100% dependency được kiểm tra license, ngăn chặn license không phù hợp |

#### Kết quả Dài hạn (6–12 tháng)

| # | Kết quả Kỳ vọng | Chỉ số Đo lường |
|---|-----------------|-----------------|
| 9 | Quy trình SCA trở thành phần bắt buộc trong SDLC | SCA gate trong CI/CD pipeline cho tất cả dự án |
| 10 | Giảm đáng kể số lượng lỗ hổng tồn đọng | Số lỗ hổng Critical/High chưa xử lý giảm ≥ 70% |
| 11 | Văn hóa bảo mật được nâng cao | Developer chủ động xử lý SCA alert mà không cần nhắc nhở |

### 3.4 Phạm vi

Báo cáo này trình bày kết quả và phát hiện từ việc so sánh tính năng, chất lượng và đặc điểm vận hành của 6 giải pháp SCA, bao gồm 5 scanner và 1 management platform. Các benchmark được thực hiện trên tất cả sản phẩm bao gồm:

- **Production Metric**: Hỗ trợ nền tảng, chi phí, yêu cầu hệ thống
- **Khả năng Phát hiện**:
  - Vulnerability Detection Accuracy (Độ chính xác phát hiện lỗ hổng)
  - Vulnerability Database Coverage (Phạm vi cơ sở dữ liệu lỗ hổng)
  - Transitive Dependency Detection (Phát hiện dependency gián tiếp)
  - Container Image Scanning (Quét container image)
  - License Compliance Detection (Phát hiện tuân thủ license)
  - False Positive Rate (Tỷ lệ cảnh báo sai)
- **Tính năng Vận hành**:
  - SBOM Generation (Tạo SBOM)
  - Auto-Remediation (Tự động khắc phục – tạo PR / auto-fix)
  - CI/CD Integration (Tích hợp CI/CD)
  - Multi-Language and Ecosystem Support (Hỗ trợ đa ngôn ngữ và ecosystem)
  - Scan Performance (Hiệu suất quét)
  - Offline Capability (Khả năng hoạt động offline)
  - Reporting and Dashboard (Báo cáo và dashboard)
  - Ease of Setup and Maintenance (Dễ dàng cài đặt và bảo trì)
- **Management Platform** (đánh giá riêng cho Dependency-Track):
  - Kiến trúc và cách triển khai
  - Quản lý SBOM tập trung
  - Policy Engine và Risk Scoring
  - Tích hợp với scanner

### 3.5 Nhóm Dự án

| Thành viên | Vai trò |
|------------|---------|
| *(Cần bổ sung)* | Security Engineer |

### 3.6 Kết luận

Nhóm đã xây dựng các test case phù hợp để đánh giá các công cụ SCA trên repository `Test-SCA`, chứa các dependency cố tình để phiên bản cũ trên các ecosystem Python (pip), Node.js (npm), Docker và GitHub Actions. Việc đánh giá tập trung vào so sánh chất lượng và khả năng của từng giải pháp.

Đối với các tính năng có thể đánh giá chất lượng, chúng tôi định nghĩa hệ thống xếp hạng như sau:

| Xếp hạng | Mô tả |
|-----------|-------|
| 0 - Không đáp ứng | Tính năng không khả dụng hoặc không được hỗ trợ. Công cụ không có khả năng này. |
| 1 - Đáp ứng một phần | Có hỗ trợ nhưng còn hạn chế về phạm vi, độ chính xác hoặc tính năng. Đáp ứng được một số yêu cầu cơ bản nhưng chưa đầy đủ cho mọi tình huống. |
| 2 - Đáp ứng | Hỗ trợ đầy đủ với phạm vi phủ rộng và độ chính xác cao. Đáng tin cậy cho hầu hết môi trường và use case. Đáp ứng tốt yêu cầu của tổ chức. |

---

Dưới đây là bảng tổng hợp kết quả dựa trên đánh giá của nhóm:

| Danh mục | Benchmark | Dependabot | Trivy | Grype + Syft | OSV-Scanner | Dependency-Check |
|----------|-----------|------------|-------|--------------|-------------|------------------|
| **PHÁT HIỆN** | Vulnerability Detection Accuracy | 2 | 2 | 2 | 2 | 1 |
| | Vulnerability Database Coverage | 1 | 2 | 2 | 2 | 1 |
| | SBOM Generation | 0 | 2 | 2 | 1 | 0 |
| | Container Image Scanning | 0 | 2 | 2 | 1 | 0 |
| | License Compliance Detection | 0 | 2 | 1 | 0 | 0 |
| | Transitive Dependency Detection | 2 | 2 | 2 | 1 | 1 |
| | False Positive Rate (thấp hơn = tốt hơn) | 2 | 2 | 2 | 2 | 1 |
| **KHẮC PHỤC** | Auto-Remediation (PR / Fix) | 2 | 0 | 0 | 1 | 0 |
| **VẬN HÀNH** | CI/CD Integration | 2 | 2 | 2 | 2 | 2 |
| | Multi-Language Support | 2 | 2 | 1 | 2 | 1 |
| | Scan Performance (Speed) | 2 | 2 | 2 | 2 | 1 |
| | Offline Capability | 0 | 2 | 2 | 0 | 2 |
| | Reporting and Dashboard | 1 | 1 | 1 | 1 | 2 |
| | Ease of Setup | 2 | 2 | 2 | 2 | 1 |

**Phát hiện chính:**

- **Trivy** là scanner all-in-one toàn diện nhất, vượt trội trong Vulnerability Detection, SBOM Generation, Container Scanning và hỗ trợ đa ngôn ngữ.
- **Dependabot** là công cụ auto-remediation tốt nhất với zero-setup trên GitHub, tự động tạo PR để sửa lỗ hổng.
- **Grype + Syft** cung cấp sự tách biệt rõ ràng về chức năng (SBOM Generation vs. Vulnerability Scanning) với hiệu suất nhanh.
- **OSV-Scanner** cung cấp cơ sở dữ liệu lỗ hổng mở và minh bạch nhất (OSV.dev của Google), với tỷ lệ false positive thấp nhất.
- **OWASP Dependency-Check** phù hợp nhất cho các dự án Java/.NET cần báo cáo HTML chi tiết và quét offline, nhưng yếu hơn về hỗ trợ đa ngôn ngữ và tốc độ.
- **OWASP Dependency-Track** không phải scanner mà là management platform — đóng vai trò trung tâm quản lý SBOM, theo dõi lỗ hổng liên tục và cung cấp dashboard tập trung cho toàn bộ portfolio. Xem đánh giá chi tiết tại [Mục V](#v-owasp-dependency-track--management-platform).

**Tổ hợp khuyến nghị để đạt phạm vi phủ tối ưu:**

```
Dependabot (tự động tạo PR sửa lỗi trên GitHub)
    +
Trivy (quét toàn diện + tạo SBOM trong CI/CD pipeline)
    +
Dependency-Track (dashboard tập trung + quản lý SBOM + policy engine)
```

---

## IV. Phương pháp và Kết quả

### Benchmark 1 – Production Metric

Ngoài các tiêu chí đánh giá chất lượng phát hiện và khắc phục lỗ hổng, nhóm cũng thu thập và so sánh các chỉ số vận hành như nền tảng hỗ trợ, chi phí, yêu cầu hệ thống và khả năng tích hợp, cụ thể như sau:

| Danh mục | Mô tả | Dependabot | Trivy | Grype + Syft | OSV-Scanner | Dependency-Check |
|----------|-------|------------|-------|--------------|-------------|------------------|
| **Loại** | Phân loại công cụ | GitHub Service | CLI Scanner | CLI Scanner + SBOM Generator | CLI Scanner | CLI Scanner / Plugin |
| **License** | Loại license | Proprietary (miễn phí) | Apache 2.0 | Apache 2.0 | Apache 2.0 | Apache 2.0 |
| **Chi phí** | Giá thành | Miễn phí (GitHub) | Miễn phí | Miễn phí | Miễn phí | Miễn phí |
| **Cài đặt** | Cách cài đặt | Tích hợp sẵn GitHub | Single binary / Docker / Package manager | Single binary / Docker | Single binary / Go install | CLI / Maven plugin / Gradle plugin / Docker |
| **Nền tảng** | Chạy trên đâu | Chỉ GitHub | Linux, macOS, Windows | Linux, macOS, Windows | Linux, macOS, Windows | Linux, macOS, Windows (cần JVM) |
| **Yêu cầu Hệ thống** | Tài nguyên cần thiết | N/A (SaaS) | Tối thiểu (single binary, ~50MB) | Tối thiểu (single binary, ~30MB mỗi tool) | Tối thiểu (single binary, ~20MB) | JRE 8+, ~1GB disk cho NVD DB |
| **Tích hợp** | Hệ sinh thái | GitHub native | GitHub Actions, GitLab CI, Jenkins, mọi CI | GitHub Actions, GitLab CI, Jenkins, mọi CI | GitHub Actions, GitLab CI, mọi CI | Maven, Gradle, Jenkins, Ant, SBT, mọi CI |
| **Git Platform** | Nền tảng hỗ trợ | Chỉ GitHub | Bất kỳ (platform-agnostic) | Bất kỳ (platform-agnostic) | Bất kỳ (platform-agnostic) | Bất kỳ (platform-agnostic) |
| **Phát triển** | Cộng đồng & bảo trì | GitHub (Microsoft) | Aqua Security + cộng đồng | Anchore + cộng đồng | Google + cộng đồng | OWASP + cộng đồng |

---

### Benchmark 2 – Vulnerability Detection Accuracy

Vulnerability Detection Accuracy đo lường mức độ chính xác của mỗi công cụ trong việc nhận diện các lỗ hổng đã biết (CVE) trong dependency của dự án. Công cụ có độ chính xác cao sẽ nhận diện đúng các lỗ hổng thực sự với tỷ lệ false negative tối thiểu.

**Test case:** Chạy tất cả 5 công cụ trên repository `Test-SCA`, chứa các dependency cố tình để phiên bản cũ với CVE đã biết trên ecosystem Python (`requirements.txt`) và Node.js (`package.json` / `package-lock.json`).

**Các package có lỗ hổng đã biết trong dự án thử nghiệm:**

| Ecosystem | Package | Version | CVE đã biết |
|-----------|---------|---------|-------------|
| Python | Pillow | 8.2.0 | 12 alert (Critical/High) |
| Python | urllib3 | 1.23 | 10 alert |
| Python | Jinja2 | 2.10 | 6 alert |
| Python | requests | 2.19.0 | 5 alert |
| Python | PyYAML | 5.3 | 2 alert (Critical) |
| Python | Flask | 1.0 | 2 alert |
| Node.js | serialize-javascript | 1.9.0 | 4 alert |
| Node.js | lodash | 4.17.20 | 3 alert |
| Node.js | moment | 2.29.1 | 2 CVE |
| Node.js | jquery | 3.4.1 | 2 CVE |
| Node.js | express | 4.17.1 | 2 alert trực tiếp + 10 từ sub-dependency (body-parser, qs, path-to-regexp, cookie, send, serve-static) |

**Kết quả mong đợi:** Mỗi công cụ cần phát hiện phần lớn trong 60+ lỗ hổng đang mở trên cả hai ecosystem (Dependabot phát hiện 60 alert đang mở — 37 pip, 23 npm — trong tổng số 102 alert tích lũy kể cả đã khắc phục).

> **Ghi chú về cột "CVE đã biết":** Số liệu trong bảng trên phản ánh số Dependabot open alert tính tại thời điểm đánh giá. Pillow và Jinja2/PyYAML được Dependabot theo dõi dưới 2 dạng tên (chữ hoa/thường) nên tổng alert = tổng cộng cả hai dạng.

| Công cụ | Trạng thái | Xếp hạng Phát hiện | Ghi chú |
|---------|------------|---------------------|---------|
| **Dependabot** | **Đã triển khai** | 2 - Đáp ứng | Phát hiện 102 alert (60 đang mở, 42 đã khắc phục) trên tất cả ecosystem. Bao gồm cả CVE từ direct và transitive dependency. Sử dụng GitHub Advisory Database (~28.000+ advisory). |
| **Trivy** | Chưa kiểm thử | 2 - Đáp ứng (dự kiến) | Tổng hợp từ 30+ nguồn lỗ hổng. Nổi tiếng với tỷ lệ phát hiện hàng đầu trong các benchmark độc lập. |
| **Grype + Syft** | Chưa kiểm thử | 2 - Đáp ứng (dự kiến) | Phát hiện mạnh nhờ tận dụng NVD, GitHub Advisory và các database theo distro. |
| **OSV-Scanner** | Chưa kiểm thử | 2 - Đáp ứng (dự kiến) | Sử dụng OSV.dev (cơ sở dữ liệu lỗ hổng mở của Google) với advisory chất lượng cao, được kiểm duyệt. |
| **Dependency-Check** | Chưa kiểm thử | 1 - Đáp ứng một phần (dự kiến) | Evidence-based matching có thể bỏ sót một số package ngoài Java/.NET. Tỷ lệ false negative cao hơn cho Python/Node.js. |

---

### Benchmark 3 – Vulnerability Database Coverage

Vulnerability Database Coverage đánh giá độ rộng và sâu của các nguồn dữ liệu lỗ hổng mà mỗi công cụ sử dụng. Cơ sở dữ liệu càng rộng đồng nghĩa càng ít điểm mù.

**Test case:** So sánh các vulnerability database được mỗi công cụ sử dụng, bao gồm số lượng nguồn, tần suất cập nhật và phạm vi các loại advisory.

| Công cụ | Database chính | Số nguồn | Tần suất Cập nhật | Loại Advisory |
|---------|---------------|----------|-------------------|---------------|
| **Dependabot** | GitHub Advisory Database | 1 (tổng hợp) | Liên tục | CVE, GHSA |
| **Trivy** | NVD, GitHub Advisory, OSV, Red Hat, Ubuntu, Debian, Alpine, Amazon, SUSE, Photon, v.v. | 30+ | Mỗi 6 giờ | CVE, vendor-specific, distro-specific |
| **Grype + Syft** | NVD, GitHub Advisory, distro-specific (Alpine, Amazon, Debian, Oracle, RHEL, SUSE, Ubuntu, Wolfi) | 10+ | Mỗi 5 phút (có thể cấu hình) | CVE, GHSA, distro-specific |
| **OSV-Scanner** | OSV.dev (tổng hợp: NVD, GitHub Advisory, PyPI, RubyGems, Go, Rust, npm, v.v.) | 15+ (qua OSV.dev) | Liên tục | Định dạng OSV (ecosystem-specific) |
| **Dependency-Check** | NVD, OSS Index (Sonatype), RetireJS | 3 | Tải thủ công/theo lịch | CVE, CPE-based matching |

| Công cụ | Trạng thái | Xếp hạng Phạm vi | Ghi chú |
|---------|------------|-------------------|---------|
| **Dependabot** | **Đã triển khai** | 1 - Đáp ứng một phần | Một nguồn tổng hợp duy nhất (GitHub Advisory DB). Phạm vi phủ tốt nhưng không có advisory theo distro. |
| **Trivy** | Chưa kiểm thử | 2 - Đáp ứng (dự kiến) | Dẫn đầu ngành với 30+ nguồn phủ sóng OS package, language package và container vulnerability. |
| **Grype + Syft** | Chưa kiểm thử | 2 - Đáp ứng (dự kiến) | Phạm vi phủ đa nguồn mạnh với khả năng đồng bộ nhanh. |
| **OSV-Scanner** | Chưa kiểm thử | 2 - Đáp ứng (dự kiến) | OSV.dev hoàn toàn mở và tổng hợp từ các nguồn advisory chính thức của ecosystem. |
| **Dependency-Check** | Chưa kiểm thử | 1 - Đáp ứng một phần (dự kiến) | Phụ thuộc nhiều vào NVD với CPE matching, có thể bỏ sót một số advisory. RetireJS bổ sung phạm vi cho JavaScript. |

---

### Benchmark 4 – SBOM Generation

SBOM (Software Bill of Materials) Generation là khả năng tạo ra danh sách kiểm kê toàn diện tất cả các thành phần phần mềm, phiên bản và mối quan hệ giữa chúng. SBOM rất quan trọng cho việc tuân thủ (Executive Order 14028, ISO 27001) và bảo mật chuỗi cung ứng.

**Test case:** Đánh giá liệu mỗi công cụ có thể tạo SBOM không và ở định dạng nào (CycloneDX, SPDX).

| Công cụ | Tạo SBOM | Định dạng Hỗ trợ | Chất lượng |
|---------|----------|-------------------|------------|
| **Dependabot** | Không | N/A | 0 - Không đáp ứng |
| **Trivy** | Có | CycloneDX, SPDX, GitHub, Custom template | 2 - Đáp ứng |
| **Syft** (thuộc Grype + Syft) | Có | CycloneDX, SPDX, JSON, Text, Table, GitHub | 2 - Đáp ứng |
| **OSV-Scanner** | Có thể quét SBOM có sẵn, không tự tạo | Đọc CycloneDX, SPDX | 1 - Đáp ứng một phần |
| **Dependency-Check** | Không | N/A | 0 - Không đáp ứng |

**Các lệnh mẫu (sẽ được demo):**

```bash
# Trivy – Tạo SBOM định dạng CycloneDX
trivy fs . --format cyclonedx --output sbom-trivy.json

# Syft – Tạo SBOM định dạng CycloneDX
syft . -o cyclonedx-json > sbom-syft.json

# OSV-Scanner – Quét một SBOM có sẵn
osv-scanner --sbom sbom-trivy.json
```

| Công cụ | Trạng thái | Xếp hạng SBOM |
|---------|------------|---------------|
| **Dependabot** | **Đã triển khai** | 0 - Không đáp ứng – Không hỗ trợ tạo SBOM |
| **Trivy** | Chưa kiểm thử | 2 - Đáp ứng (dự kiến) |
| **Grype + Syft** | Chưa kiểm thử | 2 - Đáp ứng (dự kiến) |
| **OSV-Scanner** | Chưa kiểm thử | 1 - Đáp ứng một phần (chỉ đọc) |
| **Dependency-Check** | Chưa kiểm thử | 0 - Không đáp ứng – Không hỗ trợ tạo SBOM |

---

### Benchmark 5 – Auto-Remediation (PR Creation / Auto-Fix)

Auto-Remediation đánh giá khả năng tự động sửa lỗ hổng đã phát hiện của công cụ, bằng cách tạo pull request với version bump hoặc áp dụng bản sửa trực tiếp.

**Test case:** Sử dụng repository `Test-SCA`, đánh giá khả năng tự động đề xuất hoặc áp dụng bản sửa cho các lỗ hổng đã phát hiện của mỗi công cụ.

| Công cụ | Tự tạo PR | Auto-Fix CLI | Guided Remediation | Group Updates |
|---------|-----------|-------------|-------------------|---------------|
| **Dependabot** | Có (tự động) | N/A | N/A | Có |
| **Trivy** | Không | Không | Không | N/A |
| **Grype + Syft** | Không | Không | Không | N/A |
| **OSV-Scanner** | Không | Không | Có (chỉ npm, Maven, V2) | N/A |
| **Dependency-Check** | Không | Không | Không | N/A |

**Kết quả Auto-Remediation của Dependabot trên Test-SCA (dữ liệu thực tế — 23 PR tổng cộng):**

**PR đang mở (15 PR):**

| PR # | Tiêu đề | Loại | Trạng thái CI |
|------|---------|------|---------------|
| #23 | npm: bump lodash 4.17.20 → 4.17.21 | Security | – |
| #22 | pip: bump requests 2.19.0 → 2.33.1 | Security + Version | – |
| #20 | npm: bump serialize-javascript 1.9.0 → 7.0.5 | Security + Version | – |
| #19 | pip: bump pytest 7.1.0 → 9.0.2 | Version | – |
| #18 | npm: bump the npm_and_yarn group (5 updates) | Group Update | – |
| #15 | pip: bump flask 1.0 → 3.1.3 | Security + Version | Fail (breaking change) |
| #14 | pip: bump pillow 8.2.0 → 12.1.1 | Security + Version | – |
| #13 | pip: bump the pip group (6 updates) | Group Update | – |
| #12 | docker: bump python 3.8-slim → 3.14-slim | Version Update | – |
| #11 | npm: bump jquery 3.4.1 → 4.0.0 | Security + Version | – |
| #9 | npm: bump express 4.17.1 → 5.2.1 | Security + Version | – |
| #8 | pip: bump urllib3 1.24.1 → 2.6.3 | Security + Version | – |
| #3 | pip: bump pyyaml 5.3 → 6.0.3 | Security | – |
| #2 | pip: bump jinja2 2.10 → 3.1.6 | Security + Version | – |
| #1 | npm: bump moment 2.29.1 → 2.30.1 | Security | – |

**PR đã đóng (8 PR):** #21 (requests → 2.33.0), #17 (serialize-javascript → 7.0.4), #16 (serialize-javascript → 7.0.3), #10 (flask → 3.1.2), #7 (requests → 2.32.5), #6 (serialize-javascript → 7.0.2), #5 (pillow → 12.1.0), #4 (lodash → 4.17.23) — đã đóng do có phiên bản mới hơn.

| Công cụ | Trạng thái | Xếp hạng Remediation |
|---------|------------|----------------------|
| **Dependabot** | **Đã triển khai** | 2 - Đáp ứng – Tự động tạo PR kèm changelog, compatibility score và grouped update. |
| **Trivy** | Chưa kiểm thử | 0 - Không đáp ứng – Chỉ là scanner, không cung cấp remediation. |
| **Grype + Syft** | Chưa kiểm thử | 0 - Không đáp ứng – Chỉ là scanner, không cung cấp remediation. |
| **OSV-Scanner** | Chưa kiểm thử | 1 - Đáp ứng một phần (dự kiến) – Guided Remediation chỉ giới hạn cho ecosystem npm và Maven. |
| **Dependency-Check** | Chưa kiểm thử | 0 - Không đáp ứng – Chỉ là scanner, không cung cấp remediation. |

---

### Benchmark 6 – CI/CD Integration

CI/CD Integration đánh giá mức độ dễ dàng tích hợp mỗi công cụ vào CI/CD pipeline trên các nền tảng khác nhau.

**Test case:** Đánh giá tính khả dụng và chất lượng của các tích hợp CI/CD cho mỗi công cụ, bao gồm official action, plugin và độ phức tạp cấu hình.

| Công cụ | GitHub Actions | GitLab CI | Jenkins | Nền tảng CI khác | Độ phức tạp Cấu hình |
|---------|---------------|-----------|---------|-------------------|----------------------|
| **Dependabot** | Native (tích hợp sẵn) | N/A | N/A | N/A | 1 file YAML (`dependabot.yml`) |
| **Trivy** | Official Action (`aquasecurity/trivy-action`) | Template có sẵn | Plugin có sẵn | Bất kỳ (CLI-based) | Một lệnh hoặc cấu hình action |
| **Grype + Syft** | Official Action (`anchore/scan-action`) | Template có sẵn | Plugin có sẵn | Bất kỳ (CLI-based) | Một lệnh hoặc cấu hình action |
| **OSV-Scanner** | Official Action (`google/osv-scanner-action`) | Template có sẵn | N/A | Bất kỳ (CLI-based) | Một lệnh hoặc cấu hình action |
| **Dependency-Check** | Community Action | Template có sẵn | Official Plugin | Maven/Gradle plugin | Cấu hình plugin/CLI + NVD API key |

**Cấu hình CI/CD của Dependabot (cấu hình thực tế từ Test-SCA):**

```yaml
# .github/dependabot.yml
version: 2
updates:
  - package-ecosystem: "pip"
    directory: "/"
    schedule:
      interval: "daily"
    groups:
      pip:
        patterns: ["*"]
  - package-ecosystem: "npm"
    directory: "/"
    schedule:
      interval: "daily"
    groups:
      npm_and_yarn:
        patterns: ["*"]
  - package-ecosystem: "docker"
    directory: "/"
    schedule:
      interval: "weekly"
  - package-ecosystem: "github-actions"
    directory: "/"
    schedule:
      interval: "weekly"
```

| Công cụ | Trạng thái | Xếp hạng CI/CD |
|---------|------------|----------------|
| **Dependabot** | **Đã triển khai** | 2 - Đáp ứng – Zero-config trên GitHub nhưng chỉ giới hạn trên GitHub. |
| **Trivy** | Chưa kiểm thử | 2 - Đáp ứng (dự kiến) – Hỗ trợ chính thức trên tất cả nền tảng CI chính với nhiều tùy chọn cấu hình. |
| **Grype + Syft** | Chưa kiểm thử | 2 - Đáp ứng (dự kiến) – Hỗ trợ chính thức tốt, hoạt động trên mọi nền tảng qua CLI. |
| **OSV-Scanner** | Chưa kiểm thử | 2 - Đáp ứng (dự kiến) – Official GitHub Action; CLI hoạt động ở mọi nơi. |
| **Dependency-Check** | Chưa kiểm thử | 2 - Đáp ứng (dự kiến) – Plugin Jenkins mature và tích hợp Maven/Gradle. Cần cấu hình NVD API key. |

---

### Benchmark 7 – Multi-Language and Ecosystem Support

Benchmark này đánh giá độ rộng của ngôn ngữ lập trình và package ecosystem mà mỗi công cụ hỗ trợ cho việc quét lỗ hổng. Đây là tiêu chí quan trọng khi triển khai SCA cho nhiều team Dev sử dụng các ngôn ngữ và framework khác nhau — mỗi team cần đảm bảo công cụ SCA được chọn hỗ trợ đầy đủ ecosystem của họ.

**Test case:** So sánh hỗ trợ ngôn ngữ và ecosystem được tài liệu hóa của mỗi công cụ với các ecosystem được sử dụng trong dự án `Test-SCA` (Python/pip, Node.js/npm, Docker, GitHub Actions).

#### 7.1 Bảng Tổng quan Hỗ trợ Ngôn ngữ

| Công cụ | Số Ecosystem | Python | Node.js | Java | .NET | Go | Ruby | Rust | PHP | C/C++ | Swift | Dart | Elixir |
|---------|-------------|--------|---------|------|------|----|------|------|-----|-------|-------|------|--------|
| **Dependabot** | 29 | Có | Có | Có | Có | Có | Có | Có | Có | — | Có | Có | Có |
| **Trivy** | 15+ + OS | Có | Có | Có | Có | Có | Có | Có | Có | Có | Có | Có | Có |
| **Grype + Syft** | 8+ + OS | Có | Có | Có | Có | Có | Có | Có | Có | Có | Có | Có | Có |
| **OSV-Scanner** | 15+ | Có | Có | Có | Có | Có | Có | Có | Có | Có | — | Có | Có |
| **DC-Check** | 7 (đầy đủ) + thêm experimental | Exp. | Exp. | **Tốt nhất** | **Tốt nhất** | Có | Exp. | — | Exp. | — | — | — | — |

> **Chú thích:** Exp. = Experimental (hỗ trợ thử nghiệm, chưa ổn định). DC-Check = Dependency-Check.

#### 7.2 Chi tiết Manifest File / Lock File được Hỗ trợ theo Từng Ngôn ngữ

Bảng dưới đây giúp từng team Dev xác định chính xác công cụ nào đọc được file dependency mà team đang sử dụng.

##### Python

| Manifest / Lock File | Dependabot | Trivy | Grype + Syft | OSV-Scanner | DC-Check |
|---------------------|------------|-------|--------------|-------------|----------|
| `requirements.txt` | Có | Có | Có | Có | Experimental |
| `Pipfile` / `Pipfile.lock` | Có | Có | Có | Có | — |
| `setup.py` | Có | — | — | — | — |
| `pyproject.toml` (PEP 621) | Có | Có | Có | Có | — |
| `poetry.lock` | Có | Có | Có | Có | — |
| `uv.lock` | Có | Có | — | Có | — |
| `pdm.lock` | — | — | — | Có | — |
| `conda` (conda-meta) | Có | Có (installed pkg) | — | — | — |

> **Lưu ý:** Dependabot không hỗ trợ `setup.cfg` (chỉ `setup.py`). Trivy hỗ trợ conda qua phân tích conda-meta package đã cài, không quét trực tiếp `environment.yml`.

**Khuyến nghị cho Python team:** Tất cả scanner đều hỗ trợ tốt Python. Dependabot và Trivy phủ sóng rộng nhất. OSV-Scanner hỗ trợ nhiều lock file nhất (bao gồm `uv.lock`, `pdm.lock`).

##### JavaScript / TypeScript (Node.js)

| Manifest / Lock File | Dependabot | Trivy | Grype + Syft | OSV-Scanner | DC-Check |
|---------------------|------------|-------|--------------|-------------|----------|
| `package.json` | Có | Có | Có | Có | Experimental |
| `package-lock.json` | Có | Có | Có | Có | Experimental |
| `yarn.lock` | Có | Có | Có | Có | — |
| `pnpm-lock.yaml` | Có | Có | Có | Có | — |
| `bun.lock` (text, Bun ≥1.1.39) | Có | — | — | Có | — |

> **Lưu ý:** Định dạng binary `bun.lockb` (cũ) không được scanner nào hỗ trợ trực tiếp. Dependabot và OSV-Scanner hỗ trợ `bun.lock` định dạng text (Bun ≥1.1.39). Trivy chưa hỗ trợ trực tiếp Bun nhưng có thể quét nếu export sang `yarn.lock`.

**Khuyến nghị cho JS/TS team:** Mọi scanner chính đều hỗ trợ tốt npm, yarn, pnpm. Nếu team dùng Bun, cần đảm bảo sử dụng `bun.lock` (text format) thay vì `bun.lockb` (binary).

##### Java / Kotlin

| Manifest / Lock File | Dependabot | Trivy | Grype + Syft | OSV-Scanner | DC-Check |
|---------------------|------------|-------|--------------|-------------|----------|
| `pom.xml` (Maven) | Có | Có | Có | Có | **Tốt nhất** |
| `build.gradle` / `build.gradle.kts` | Có | Có | Có | Có | **Tốt nhất** |
| `gradle.lockfile` | Có | Có | Có | Có | Có |
| `.jar` / `.war` / `.ear` (binary scan) | — | Có | Có | — | **Tốt nhất** |
| `sbt` (Scala) | — | — | — | — | Có |

**Khuyến nghị cho Java/Kotlin team:** Dependency-Check là lựa chọn mạnh nhất cho Java (evidence-based matching, quét cả binary `.jar`). Trivy và Grype cũng hỗ trợ tốt. Nên kết hợp Trivy (đa năng) + Dependency-Check (chuyên sâu Java) nếu team chủ yếu dùng Java.

##### .NET / C#

| Manifest / Lock File | Dependabot | Trivy | Grype + Syft | OSV-Scanner | DC-Check |
|---------------------|------------|-------|--------------|-------------|----------|
| `.csproj` / `.vbproj` / `.fsproj` | Có | Có | Có | — | **Tốt nhất** |
| `packages.config` | Có | Có | Có | Có | **Tốt nhất** |
| `Directory.Packages.props` | Có | Có | — | — | — |
| `packages.lock.json` | Có | Có | Có | Có | Có |
| `.deps.json` | — | Có | Có | Có | — |
| `nuget.config` | Có | — | — | — | Có |
| `.nupkg` / `.dll` (binary scan) | — | — | — | — | **Tốt nhất** |

> **Lưu ý:** OSV-Scanner hỗ trợ .NET qua `packages.lock.json`, `packages.config` và `.deps.json`, nhưng không quét trực tiếp `.csproj`. Để sử dụng OSV-Scanner với .NET, cần tạo `packages.lock.json` qua `dotnet restore --use-lock-file`.

**Khuyến nghị cho .NET team:** Dependency-Check là lựa chọn mạnh nhất cho .NET (quét cả binary `.dll`, `.nupkg`). Dependabot và Trivy cũng hỗ trợ tốt ở mức manifest file.

##### Go

| Manifest / Lock File | Dependabot | Trivy | Grype + Syft | OSV-Scanner | DC-Check |
|---------------------|------------|-------|--------------|-------------|----------|
| `go.mod` | Có | Có | Có | Có | Có |
| `go.sum` | Có | Có | Có | Có | — |
| Go binary (compiled) | — | Có | Có | — | — |

**Khuyến nghị cho Go team:** Trivy và Grype nổi bật vì có thể quét cả Go binary đã compile (phát hiện dependency trong binary production). Dependency-Check cũng hỗ trợ Go qua Golang Mod Analyzer.

##### Ruby

| Manifest / Lock File | Dependabot | Trivy | Grype + Syft | OSV-Scanner | DC-Check |
|---------------------|------------|-------|--------------|-------------|----------|
| `Gemfile` | Có | Có | Có | Có | Experimental |
| `Gemfile.lock` | Có | Có | Có | Có | Experimental |
| `.gemspec` | Có | — | — | — | — |

**Khuyến nghị cho Ruby team:** Dependabot, Trivy và Grype đều hỗ trợ tốt. Tránh dùng Dependency-Check cho Ruby (chỉ experimental).

##### Rust

| Manifest / Lock File | Dependabot | Trivy | Grype + Syft | OSV-Scanner | DC-Check |
|---------------------|------------|-------|--------------|-------------|----------|
| `Cargo.toml` | Có | Có | Có | Có | — |
| `Cargo.lock` | Có | Có | Có | Có | — |
| Rust binary (cargo-auditable) | — | Có | Có | — | — |

> **Lưu ý:** Quét Rust binary chỉ hoạt động với binary được build bằng `cargo-auditable` (nhúng metadata dependency vào binary). Binary build thông thường không chứa thông tin dependency để quét.

**Khuyến nghị cho Rust team:** Trivy và Grype hỗ trợ tốt nhất (bao gồm quét binary cargo-auditable). Dependency-Check không hỗ trợ Rust.

##### PHP

| Manifest / Lock File | Dependabot | Trivy | Grype + Syft | OSV-Scanner | DC-Check |
|---------------------|------------|-------|--------------|-------------|----------|
| `composer.json` | Có | Có | Có | Có | Experimental |
| `composer.lock` | Có | Có | Có | Có | Experimental |

**Khuyến nghị cho PHP team:** Dependabot, Trivy, Grype và OSV-Scanner đều hỗ trợ tốt PHP qua Composer. Dependency-Check hỗ trợ ở mức experimental.

##### C / C++

| Manifest / Lock File | Dependabot | Trivy | Grype + Syft | OSV-Scanner | DC-Check |
|---------------------|------------|-------|--------------|-------------|----------|
| `conan.lock` (Conan) | — | Có | Có | Có | — |
| `conanfile.txt` / `conanfile.py` | — | Có | — | — | — |
| `vcpkg.json` | — | — | — | — | — |
| OS package (apt, yum, apk) | — | Có | Có | — | — |

> **Lưu ý:** Dependabot **không hỗ trợ Conan** (có nhiều feature request nhưng chưa được triển khai). Grype + Syft hỗ trợ Conan nhưng chất lượng SBOM tạo ra có thể chưa đầy đủ thông tin component.

**Khuyến nghị cho C/C++ team:** C/C++ thường sử dụng system-level dependency (apt, yum) hơn là package manager riêng. Trivy là lựa chọn tốt nhất vì quét được cả OS package trong container image và hỗ trợ Conan (`conan.lock`, `conanfile.txt`).

##### Swift / Objective-C (iOS)

| Manifest / Lock File | Dependabot | Trivy | Grype + Syft | OSV-Scanner | DC-Check |
|---------------------|------------|-------|--------------|-------------|----------|
| `Package.swift` (Swift PM) | Có | — | Có | — | — |
| `Package.resolved` | Có | Có | Có | — | — |
| `Podfile` (CocoaPods) | — | — | Có | — | — |
| `Podfile.lock` | — | Có | Có | — | — |
| `Cartfile` (Carthage) | — | — | — | — | — |

> **Lưu ý:** Dependabot không hỗ trợ Carthage. Trivy quét `Package.resolved` và `Podfile.lock` (lock file), không quét trực tiếp `Package.swift` hay `Podfile` (manifest).

**Khuyến nghị cho iOS team:** Dependabot (Swift PM), Trivy và Grype (Swift PM + CocoaPods) đều hỗ trợ tốt. Dependency-Check không hỗ trợ Swift.

##### Dart / Flutter

| Manifest / Lock File | Dependabot | Trivy | Grype + Syft | OSV-Scanner | DC-Check |
|---------------------|------------|-------|--------------|-------------|----------|
| `pubspec.yaml` | Có | Có | Có | — | — |
| `pubspec.lock` | Có | Có | Có | Có | — |

**Khuyến nghị cho Dart/Flutter team:** Dependabot, Trivy, Grype và OSV-Scanner đều hỗ trợ. Dependency-Check không hỗ trợ Dart.

##### Elixir

| Manifest / Lock File | Dependabot | Trivy | Grype + Syft | OSV-Scanner | DC-Check |
|---------------------|------------|-------|--------------|-------------|----------|
| `mix.exs` | Có | Có | Có | — | — |
| `mix.lock` | Có | Có | Có | Có | — |

**Khuyến nghị cho Elixir team:** Dependabot, Trivy, Grype và OSV-Scanner hỗ trợ Elixir qua Hex package manager.

##### Hệ điều hành / Container (OS Package Manager)

| Package Manager | Dependabot | Trivy | Grype + Syft | OSV-Scanner | DC-Check |
|----------------|------------|-------|--------------|-------------|----------|
| Alpine (apk) | — | Có | Có | Có (V2) | — |
| Debian / Ubuntu (apt/dpkg) | — | Có | Có | Có (V2) | — |
| Red Hat / CentOS (rpm/yum) | — | Có | Có | — | — |
| Amazon Linux | — | Có | Có | — | — |
| SUSE (zypper) | — | Có | Có | — | — |
| Wolfi / Chainguard | — | Có | Có | — | — |
| Photon OS | — | Có | — | — | — |
| Windows (system) | — | — | — | — | Có |

**Khuyến nghị cho DevOps/Infra team:** Trivy là lựa chọn tốt nhất cho quét OS package trong container image — hỗ trợ nhiều distro nhất. Grype cũng rất tốt.

##### Khác (Infrastructure as Code, CI/CD)

| Ecosystem | Dependabot | Trivy | Grype + Syft | OSV-Scanner | DC-Check |
|-----------|------------|-------|--------------|-------------|----------|
| Docker (`Dockerfile`) | Có (bump `FROM`) | Có (quét image) | Có (quét image) | Có (V2) | — |
| GitHub Actions | Có | — | — | — | — |
| Terraform (`.tf`) | Có | Có (misconfig) | — | — | — |
| Helm Chart | Có | Có (misconfig + vuln) | — | — | — |
| Kubernetes manifest | — | Có (misconfig) | — | — | — |
| Ansible | — | Có (misconfig) | — | — | — |
| CloudFormation | — | Có (misconfig) | — | — | — |

**Khuyến nghị cho DevOps team:** Dependabot xử lý tốt việc cập nhật GitHub Actions và Terraform module. Trivy vượt trội trong quét misconfiguration cho Dockerfile, Kubernetes, Terraform, Helm, Ansible và CloudFormation.

#### 7.3 Bảng Tra cứu Nhanh: Team dùng Ngôn ngữ X → Nên chọn Tool nào?

Bảng dưới đây giúp từng team Dev tra cứu nhanh công cụ phù hợp nhất cho ngôn ngữ/ecosystem họ đang sử dụng:

| Ngôn ngữ / Ecosystem | Công cụ Khuyến nghị | Lý do |
|----------------------|---------------------|-------|
| **Python** | Dependabot + Trivy | Cả hai phủ sóng rộng nhất (pip, Pipenv, Poetry, uv, conda) |
| **JavaScript / TypeScript** | Dependabot + Trivy | Hỗ trợ npm, yarn, pnpm, bun (Trivy). Auto-fix PR (Dependabot) |
| **Java / Kotlin** | Dependabot + Trivy + Dependency-Check | DC-Check mạnh nhất cho Java (quét cả `.jar` binary). Trivy đa năng. |
| **.NET / C#** | Dependabot + Trivy + Dependency-Check | DC-Check quét binary `.dll`/`.nupkg`. Dependabot auto-fix. |
| **Go** | Dependabot + Trivy | Trivy quét cả Go binary đã compile. OSV-Scanner cũng tốt. |
| **Ruby** | Dependabot + Trivy | Cả hai hỗ trợ Gemfile/Gemfile.lock tốt. |
| **Rust** | Dependabot + Trivy | Trivy quét cả Rust binary. OSV-Scanner cũng tốt. |
| **PHP** | Dependabot + Trivy | Hỗ trợ Composer đầy đủ. |
| **C / C++** | Trivy | Quét OS package + Conan. Dependabot không hỗ trợ Conan. |
| **Swift / iOS** | Dependabot + Trivy | Hỗ trợ Swift PM + CocoaPods. |
| **Dart / Flutter** | Dependabot + Trivy | Hỗ trợ pub (pubspec.yaml/pubspec.lock). |
| **Elixir** | Dependabot + Trivy | Hỗ trợ Hex (mix.exs/mix.lock). |
| **Container / OS** | Trivy | Hàng đầu: nhiều distro nhất, layer analysis, SBOM. |
| **IaC (Terraform, K8s, Helm)** | Dependabot (update) + Trivy (misconfig) | Dependabot update module version. Trivy quét misconfig. |
| **GitHub Actions** | Dependabot | Công cụ duy nhất tự động cập nhật action version. |

#### 7.4 Đánh giá Tổng hợp

| Công cụ | Trạng thái | Xếp hạng Hỗ trợ Ngôn ngữ |
|---------|------------|---------------------------|
| **Dependabot** | **Đã triển khai** | 2 - Đáp ứng – Hỗ trợ 29 ecosystem bao gồm cả IaC (Terraform, Helm) và GitHub Actions. Nhưng chỉ scan manifest file, không quét binary. Không hỗ trợ Conan (C/C++). |
| **Trivy** | Chưa kiểm thử | 2 - Đáp ứng (dự kiến) – Hỗ trợ 15+ ngôn ngữ + tất cả OS package manager chính + binary scanning (Go, Rust cargo-auditable, Java) + IaC misconfiguration. Phạm vi phủ toàn diện nhất trong các scanner. |
| **Grype + Syft** | Chưa kiểm thử | 2 - Đáp ứng (dự kiến) – Hỗ trợ tốt 12+ ngôn ngữ + OS package + binary scanning. Gần bằng Trivy nhưng không có IaC misconfig. |
| **OSV-Scanner** | Chưa kiểm thử | 2 - Đáp ứng (dự kiến) – 15+ ecosystem bao gồm Dart, Elixir, C/C++ (conan.lock). V2 thêm container scanning (Alpine, Debian, Ubuntu). |
| **Dependency-Check** | Chưa kiểm thử | 1 - Đáp ứng một phần (dự kiến) – Xuất sắc cho Java/.NET (bao gồm binary scan `.jar`/`.dll`). Hỗ trợ Go. Experimental cho Python, Node.js, Ruby, PHP. |

---

### Benchmark 8 – Container Image Scanning

Container Image Scanning đánh giá khả năng phát hiện lỗ hổng trong base image và OS-level package trong Docker/OCI container image.

**Test case:** Quét Docker base image `python:3.8-slim` (được sử dụng trong `Dockerfile` của dự án `Test-SCA`) để tìm lỗ hổng đã biết.

```bash
# Trivy
trivy image python:3.8-slim

# Grype
grype python:3.8-slim

# OSV-Scanner (V2)
osv-scanner scan --image python:3.8-slim

# Dependency-Check – không hỗ trợ container scanning
```

| Công cụ | Container Scanning | OS Package Detection | Layer Analysis | Gợi ý Base Image |
|---------|-------------------|---------------------|---------------|------------------|
| **Dependabot** | Không (chỉ cập nhật tag `FROM` trong Dockerfile) | Không | Không | Không |
| **Trivy** | Có (hỗ trợ đầy đủ) | Có | Có | Có |
| **Grype + Syft** | Có (hỗ trợ đầy đủ) | Có | Có (qua Syft) | Không |
| **OSV-Scanner** | Có (V2, mới) | Có | Hạn chế | Không |
| **Dependency-Check** | Không | Không | Không | Không |

| Công cụ | Trạng thái | Xếp hạng Container Scanning |
|---------|------------|------------------------------|
| **Dependabot** | **Đã triển khai** | 0 - Không đáp ứng – Chỉ bump tag `FROM`, không quét lỗ hổng nội dung image. |
| **Trivy** | Chưa kiểm thử | 2 - Đáp ứng (dự kiến) – Container scanner hàng đầu ngành với phân tích đầy đủ các layer. |
| **Grype + Syft** | Chưa kiểm thử | 2 - Đáp ứng (dự kiến) – Container scanning mạnh với tạo SBOM chi tiết qua Syft. |
| **OSV-Scanner** | Chưa kiểm thử | 1 - Đáp ứng một phần (dự kiến) – Tính năng mới trong V2, vẫn đang hoàn thiện. |
| **Dependency-Check** | Chưa kiểm thử | 0 - Không đáp ứng – Không hỗ trợ container scanning. |

---

### Benchmark 9 – License Compliance Detection

License Compliance Detection đánh giá khả năng nhận diện và đánh dấu license phần mềm trong dependency, giúp tổ chức đảm bảo tuân thủ các yêu cầu pháp lý.

**Test case:** Đánh giá khả năng phát hiện và báo cáo license cho tất cả dependency trong dự án `Test-SCA` của mỗi công cụ.

| Công cụ | Phát hiện License | Áp dụng Policy License | Loại License Nhận diện |
|---------|------------------|------------------------|------------------------|
| **Dependabot** | Không | Không | N/A |
| **Trivy** | Có | Có (qua `.trivy.yaml` policy) | SPDX identifier |
| **Syft** (thuộc Grype + Syft) | Có (trong output SBOM) | Không (xem xét thủ công) | SPDX identifier |
| **OSV-Scanner** | Không | Không | N/A |
| **Dependency-Check** | Không | Không | N/A |

| Công cụ | Trạng thái | Xếp hạng Phát hiện License |
|---------|------------|----------------------------|
| **Dependabot** | **Đã triển khai** | 0 - Không đáp ứng – Không phát hiện license. |
| **Trivy** | Chưa kiểm thử | 2 - Đáp ứng (dự kiến) – Phát hiện license với khả năng áp dụng policy. |
| **Grype + Syft** | Chưa kiểm thử | 1 - Đáp ứng một phần (dự kiến) – Syft bao gồm thông tin license trong SBOM nhưng không có policy enforcement. |
| **OSV-Scanner** | Chưa kiểm thử | 0 - Không đáp ứng – Không phát hiện license. |
| **Dependency-Check** | Chưa kiểm thử | 0 - Không đáp ứng – Không phát hiện license. |

---

### Benchmark 10 – False Positive Rate

False Positive Rate đo lường tần suất công cụ đánh dấu sai một dependency là có lỗ hổng khi thực tế không có. Tỷ lệ false positive thấp hơn đồng nghĩa với việc developer mất ít thời gian hơn để phân loại các vấn đề không thực sự tồn tại.

**Test case:** Phân tích kết quả phát hiện từ mỗi công cụ trên dự án `Test-SCA` và xác định các false positive (alert cho lỗ hổng không thực sự ảnh hưởng đến dự án).

| Công cụ | Phương pháp Matching | Tỷ lệ False Positive Dự kiến | Tính năng Giảm thiểu |
|---------|---------------------|------------------------------|----------------------|
| **Dependabot** | Exact version match với GitHub Advisory DB | Thấp | Advisory do GitHub kiểm duyệt giúp giảm false positive |
| **Trivy** | Exact version match với nhiều DB | Thấp | Tham chiếu chéo nhiều nguồn |
| **Grype + Syft** | Exact version match + SBOM-based | Thấp | Hỗ trợ OpenVEX để lọc false positive |
| **OSV-Scanner** | Exact version match với OSV.dev | Rất thấp | Advisory theo ecosystem được kiểm duyệt bởi maintainer |
| **Dependency-Check** | CPE evidence-based matching | Trung bình–Cao | File suppression cho các false positive đã biết |

| Công cụ | Trạng thái | Xếp hạng False Positive (cao hơn = ít FP hơn) |
|---------|------------|------------------------------------------------|
| **Dependabot** | **Đã triển khai** | 2 - Đáp ứng – Advisory do GitHub kiểm duyệt cung cấp tỷ lệ signal-to-noise tốt. |
| **Trivy** | Chưa kiểm thử | 2 - Đáp ứng (dự kiến) – Tham chiếu chéo nhiều nguồn giúp giảm false positive. |
| **Grype + Syft** | Chưa kiểm thử | 2 - Đáp ứng (dự kiến) – Tích hợp OpenVEX cho phép loại bỏ false positive một cách tường minh. |
| **OSV-Scanner** | Chưa kiểm thử | 2 - Đáp ứng (dự kiến) – Advisory theo ecosystem từ maintainer chính thức giúp giảm thiểu tối đa false positive. |
| **Dependency-Check** | Chưa kiểm thử | 1 - Đáp ứng một phần (dự kiến) – CPE-based matching về bản chất tạo ra nhiều false positive hơn, đặc biệt cho các package ngoài Java. |

---

### Benchmark 11 – Scan Performance (Speed)

Scan Performance đo thời gian cần thiết để hoàn thành quét lỗ hổng toàn bộ dự án. Quét nhanh hơn giúp vòng phản hồi trong CI/CD pipeline chặt chẽ hơn.

**Test case:** Đo thời gian thực tế (wall-clock time) của mỗi công cụ khi quét toàn bộ dự án `Test-SCA` (bao gồm tất cả dependency manifest).

| Công cụ | Thời gian Quét Dự kiến | Chi phí Chạy Lần đầu | Caching |
|---------|------------------------|-----------------------|---------|
| **Dependabot** | N/A (chạy background service) | Không | Tích hợp sẵn |
| **Trivy** | ~5-15 giây | ~30 giây (tải DB) | Có (local DB cache) |
| **Grype + Syft** | ~5-10 giây | ~30 giây (tải DB) | Có (local DB cache) |
| **OSV-Scanner** | ~3-10 giây | Tối thiểu (API-based) | Hạn chế |
| **Dependency-Check** | ~2-10 phút | ~10-30 phút (tải NVD DB) | Có (local NVD DB) |

| Công cụ | Trạng thái | Xếp hạng Tốc độ |
|---------|------------|------------------|
| **Dependabot** | **Đã triển khai** | 2 - Đáp ứng – Chạy dưới dạng SaaS background service; không ảnh hưởng đến workflow của developer. |
| **Trivy** | Chưa kiểm thử | 2 - Đáp ứng (dự kiến) – Cực nhanh sau khi tải DB lần đầu. |
| **Grype + Syft** | Chưa kiểm thử | 2 - Đáp ứng (dự kiến) – Tối ưu hóa cho tốc độ với incremental DB update. |
| **OSV-Scanner** | Chưa kiểm thử | 2 - Đáp ứng (dự kiến) – Tra cứu API nhanh nhưng phụ thuộc vào mạng. |
| **Dependency-Check** | Chưa kiểm thử | 1 - Đáp ứng một phần (dự kiến) – Chậm hơn đáng kể do tải NVD database và CPE matching. |

---

### Benchmark 12 – Offline Capability

Offline Capability đánh giá liệu công cụ có thể quét lỗ hổng mà không cần kết nối internet hay không, điều này rất quan trọng cho các môi trường air-gapped hoặc bị hạn chế kết nối.

**Test case:** Đánh giá khả năng quét dự án `Test-SCA` của mỗi công cụ khi không có kết nối internet (sau khi cài đặt/tải database ban đầu).

| Công cụ | Quét Offline | Lưu trữ Database | Cần tải DB Trước |
|---------|-------------|-------------------|------------------|
| **Dependabot** | Không (chỉ SaaS) | Cloud (GitHub) | N/A |
| **Trivy** | Có | Local file system | Có (`trivy image --download-db-only`) |
| **Grype + Syft** | Có | Local file system | Có (`grype db update`) |
| **OSV-Scanner** | Không (cần gọi API đến osv.dev) | Cloud (osv.dev) | N/A |
| **Dependency-Check** | Có | Local file system (NVD) | Có (tải NVD data feed) |

| Công cụ | Trạng thái | Xếp hạng Offline |
|---------|------------|------------------|
| **Dependabot** | **Đã triển khai** | 0 - Không đáp ứng – Dịch vụ cloud, không thể chạy offline. |
| **Trivy** | Chưa kiểm thử | 2 - Đáp ứng (dự kiến) – Hỗ trợ offline đầy đủ sau khi tải DB. |
| **Grype + Syft** | Chưa kiểm thử | 2 - Đáp ứng (dự kiến) – Hỗ trợ offline đầy đủ sau khi tải DB. |
| **OSV-Scanner** | Chưa kiểm thử | 0 - Không đáp ứng – Cần internet để tra cứu lỗ hổng. |
| **Dependency-Check** | Chưa kiểm thử | 2 - Đáp ứng (dự kiến) – Hỗ trợ offline đầy đủ sau khi tải NVD DB. |

---

### Benchmark 13 – Transitive Dependency Detection

Transitive Dependency Detection đánh giá khả năng nhận diện lỗ hổng không chỉ trong các dependency được khai báo trực tiếp, mà còn trong các sub-dependency lồng nhau của chúng.

**Test case:** Sử dụng dự án `Test-SCA`, xác minh rằng mỗi công cụ phát hiện lỗ hổng trong transitive dependency của `express@4.17.1` (có 6 sub-dependency bị lỗ hổng đã biết: `body-parser`, `qs`, `path-to-regexp`, `cookie`, `send`, `serve-static`).

| Công cụ | Phát hiện Transitive | Hiển thị Dependency Tree | Hỗ trợ Lock File |
|---------|---------------------|--------------------------|-------------------|
| **Dependabot** | Có (qua lock file) | Không | `package-lock.json`, `yarn.lock`, `Pipfile.lock`, v.v. |
| **Trivy** | Có (built-in resolver) | Có (với flag `--dependency-tree`) | Tất cả lock file chính |
| **Grype + Syft** | Có (qua Syft SBOM) | Có (qua Syft) | Tất cả lock file chính |
| **OSV-Scanner** | Có (qua lock file) | Không | Các lock file chính |
| **Dependency-Check** | Một phần (phụ thuộc build tool) | Không | Maven/Gradle dependency resolution |

**Kết quả phát hiện transitive dependency của Dependabot (dữ liệu thực tế từ Test-SCA):**

Dependabot đã phát hiện thành công lỗ hổng trong các transitive dependency sau của `express@4.17.1`:

| Sub-dependency | CVE | Severity |
|---------------|-----|----------|
| body-parser@1.19.0 | CVE-2024-45590 | High |
| qs@6.7.0 | CVE-2022-24999 | High |
| path-to-regexp@0.1.7 | CVE-2024-45296 | High |
| cookie@0.4.1 | CVE-2024-47764 | Low |
| send@0.17.1 | CVE-2024-43799 | Low |
| serve-static@1.14.1 | CVE-2024-43800 | Low |

| Công cụ | Trạng thái | Xếp hạng Phát hiện Transitive |
|---------|------------|--------------------------------|
| **Dependabot** | **Đã triển khai** | 2 - Đáp ứng – Phát hiện tất cả 6 transitive vulnerability qua phân tích lock file. |
| **Trivy** | Chưa kiểm thử | 2 - Đáp ứng (dự kiến) – Built-in dependency resolver với hiển thị dependency tree. |
| **Grype + Syft** | Chưa kiểm thử | 2 - Đáp ứng (dự kiến) – Syft tạo SBOM toàn diện bao gồm transitive dependency. |
| **OSV-Scanner** | Chưa kiểm thử | 1 - Đáp ứng một phần (dự kiến) – Dựa trên lock file; có thể bỏ sót khi không có lock file. |
| **Dependency-Check** | Chưa kiểm thử | 1 - Đáp ứng một phần (dự kiến) – Tốt cho Maven/Gradle, hạn chế cho ecosystem khác. |

---

### Benchmark 14 – Reporting and Dashboard

Reporting and Dashboard đánh giá khả năng trình bày kết quả quét ở định dạng dễ đọc và cung cấp khả năng quan sát tập trung về tình trạng bảo mật.

**Test case:** So sánh các định dạng đầu ra và khả năng hiển thị trực quan của mỗi công cụ.

| Công cụ | Định dạng Đầu ra | Web Dashboard | Theo dõi Xu hướng | Xuất cho Compliance |
|---------|------------------|---------------|--------------------|--------------------|
| **Dependabot** | GitHub Security tab | GitHub UI (tích hợp sẵn) | Hạn chế (lịch sử alert) | Xuất CSV từ GitHub |
| **Trivy** | Table, JSON, SARIF, CycloneDX, SPDX, Template | Không (chỉ CLI; có thể tích hợp Trivy Operator cho K8s dashboard) | Không | SARIF, JSON, CycloneDX |
| **Grype + Syft** | Table, JSON, CycloneDX, SARIF | Không (chỉ CLI) | Không | SARIF, JSON |
| **OSV-Scanner** | Table, JSON, SARIF, Markdown | Không (chỉ CLI) | Không | SARIF, JSON |
| **Dependency-Check** | HTML, JSON, XML, CSV, SARIF, JUnit | Báo cáo HTML (standalone) | Không (báo cáo theo lần chạy) | HTML, XML, SARIF |

| Công cụ | Trạng thái | Xếp hạng Reporting |
|---------|------------|---------------------|
| **Dependabot** | **Đã triển khai** | 1 - Đáp ứng một phần – GitHub UI cung cấp dashboard cơ bản với bộ lọc severity, nhưng hạn chế phân tích xu hướng. |
| **Trivy** | Chưa kiểm thử | 1 - Đáp ứng một phần (dự kiến) – Nhiều định dạng đầu ra phong phú nhưng không có dashboard tích hợp sẵn (cần công cụ bên ngoài). |
| **Grype + Syft** | Chưa kiểm thử | 1 - Đáp ứng một phần (dự kiến) – Đầu ra tập trung CLI; tích hợp với dashboard bên ngoài. |
| **OSV-Scanner** | Chưa kiểm thử | 1 - Đáp ứng một phần (dự kiến) – Tập trung CLI; đầu ra SARIF có thể upload lên GitHub Code Scanning. |
| **Dependency-Check** | Chưa kiểm thử | 2 - Đáp ứng (dự kiến) – Tạo báo cáo HTML chi tiết, độc lập với biểu đồ và khả năng xem chi tiết. |

> **Lưu ý:** Để có dashboard tập trung và quản lý portfolio, hãy cân nhắc kết hợp bất kỳ công cụ nào ở trên với **OWASP Dependency-Track**, đóng vai trò nền tảng quản lý theo dõi lỗ hổng dựa trên SBOM.

---

### Benchmark 15 – Ease of Setup and Maintenance

Ease of Setup đánh giá nỗ lực cần thiết để cài đặt, cấu hình và bảo trì mỗi công cụ trên cơ sở liên tục.

**Test case:** Ghi nhận các bước cần thiết để cài đặt mỗi công cụ cho dự án `Test-SCA` và đánh giá độ phức tạp tổng thể.

**Cài đặt Dependabot (các bước đã thực hiện thực tế):**

```
Bước 1: Tạo file .github/dependabot.yml (1 file duy nhất)
Bước 2: Push lên GitHub
Bước 3: Hoàn tất – alert và PR bắt đầu tự động
Tổng thời gian: < 5 phút
```

**Cài đặt dự kiến cho các công cụ khác:**

| Công cụ | Các bước Cài đặt | Bảo trì Cần thiết | Độ phức tạp Cấu hình |
|---------|-------------------|--------------------|-----------------------|
| **Dependabot** | 1 file YAML | Không (do GitHub quản lý) | Tối thiểu |
| **Trivy** | Cài binary + thêm bước CI | Cập nhật binary định kỳ | Tối thiểu (zero-config mặc định) |
| **Grype + Syft** | Cài 2 binary + thêm bước CI | Cập nhật binary định kỳ | Thấp (2 tool riêng biệt cần phối hợp) |
| **OSV-Scanner** | Cài binary + thêm bước CI | Cập nhật binary định kỳ | Thấp |
| **Dependency-Check** | Cài CLI hoặc plugin + cấu hình NVD API key + tải DB ban đầu | Quản lý NVD API key + cập nhật DB | Trung bình (NVD rate limit, cần API key từ 2023) |

| Công cụ | Trạng thái | Xếp hạng Cài đặt |
|---------|------------|-------------------|
| **Dependabot** | **Đã triển khai** | 2 - Đáp ứng – Một file YAML duy nhất, không cần bảo trì, được GitHub quản lý hoàn toàn. |
| **Trivy** | Chưa kiểm thử | 2 - Đáp ứng (dự kiến) – Single binary, zero-config, hoạt động ngay lập tức. |
| **Grype + Syft** | Chưa kiểm thử | 2 - Đáp ứng (dự kiến) – Hai tool riêng biệt cần cài đặt và phối hợp, nhưng cả hai đều đơn giản. |
| **OSV-Scanner** | Chưa kiểm thử | 2 - Đáp ứng (dự kiến) – Single binary, cấu hình tối thiểu. |
| **Dependency-Check** | Chưa kiểm thử | 1 - Đáp ứng một phần (dự kiến) – Cần JRE, NVD API key (từ 2023) và thời gian tải DB ban đầu lâu. |

---

### Benchmark 16 – Custom Policy Enforcement

Custom Policy Enforcement đánh giá khả năng tùy chỉnh các quy tắc để **bắt buộc tuân thủ chính sách bảo mật nội bộ** của công ty. Đây là tính năng quan trọng giúp tổ chức tự động ngăn chặn các vi phạm trước khi dependency có vấn đề đi vào production — ví dụ: cấm license GPL, block dependency có CVE Critical chưa sửa, hoặc cấm sử dụng package từ nguồn không tin cậy.

**Test case:** Đánh giá khả năng custom policy của mỗi công cụ, bao gồm: loại policy hỗ trợ, cách cấu hình, và khả năng tích hợp vào CI/CD để tự động chặn vi phạm.

---

#### 16.1 Tổng quan Khả năng Custom Policy

| Công cụ | Hỗ trợ Custom Policy | Cơ chế Cấu hình | Mức độ Linh hoạt |
|---------|----------------------|------------------|------------------|
| **Dependabot** | Rất hạn chế | `dependabot.yml` (chỉ allow/ignore) | Thấp |
| **Trivy** | Mạnh | `.trivy.yaml` + OPA/Rego policy | Cao |
| **Grype** | Cơ bản | `.grype.yaml` (ignore rules) | Trung bình |
| **OSV-Scanner** | Cơ bản | `osv-scanner.toml` (ignore rules) | Thấp |
| **Dependency-Check** | Cơ bản | `suppression.xml` (suppress FP) | Trung bình |
| **Dependency-Track** | Mạnh nhất | Web UI / REST API (Policy Engine) | Rất cao |

---

#### 16.2 Chi tiết Custom Policy từng Công cụ

##### Dependabot – Hạn chế

Dependabot chỉ hỗ trợ cấu hình cơ bản trong `dependabot.yml`, không có policy engine thực sự:

| Loại Policy | Hỗ trợ | Cách cấu hình |
|-------------|--------|----------------|
| Cho phép/cấm update dependency cụ thể | Có | `allow` / `ignore` trong `dependabot.yml` |
| Lọc theo severity | Không | N/A |
| Cấm license cụ thể | Không | N/A |
| Chặn CI khi có lỗ hổng | Không (cần tool bên ngoài) | N/A |
| Custom rule tùy ý | Không | N/A |

```yaml
# dependabot.yml – Ví dụ allow/ignore
version: 2
updates:
  - package-ecosystem: "npm"
    directory: "/"
    schedule:
      interval: "daily"
    # Chỉ cho phép update security
    allow:
      - dependency-type: "direct"
    # Bỏ qua dependency cụ thể
    ignore:
      - dependency-name: "lodash"
        versions: [">=5.0.0"]  # Không update lên v5
```

---

##### Trivy – Custom Policy mạnh với OPA/Rego

Trivy hỗ trợ custom policy phong phú qua 2 cơ chế: file `.trivy.yaml` và OPA/Rego policy language.

| Loại Policy | Hỗ trợ | Cách cấu hình |
|-------------|--------|----------------|
| Lọc theo severity (chỉ block Critical/High) | Có | `--severity` flag hoặc `.trivy.yaml` |
| Cấm license cụ thể (GPL, AGPL, v.v.) | Có | `trivy fs --scanners license --license-full` + Rego policy |
| Bỏ qua CVE cụ thể (accepted risk) | Có | `.trivyignore` file hoặc `.trivy.yaml` |
| Bỏ qua package cụ thể | Có | `.trivy.yaml` |
| Block dependency quá cũ (end-of-life) | Có (qua Rego) | Custom OPA/Rego policy |
| Chặn CI khi vi phạm (exit code non-zero) | Có | `--exit-code 1` |
| Custom rule hoàn toàn tùy ý | Có | OPA/Rego policy language |
| Quét secret trong code | Có | Built-in + custom pattern |
| Quét misconfiguration (Dockerfile, K8s, Terraform) | Có | Built-in + custom Rego |

**Ví dụ 1: `.trivy.yaml` – Cấu hình chính sách cơ bản**

```yaml
# .trivy.yaml
severity:
  - CRITICAL
  - HIGH

# Bỏ qua các CVE đã được đánh giá rủi ro chấp nhận được
ignoredVulnerabilities:
  - id: CVE-2023-XXXXX
    reason: "Accepted risk – không ảnh hưởng vì module này không được gọi"
    expired_at: "2026-06-30"  # Tự động hết hạn bỏ qua

  - id: CVE-2024-YYYYY
    reason: "False positive – đã xác nhận không ảnh hưởng"

# Bỏ qua package cụ thể
ignoredPackages:
  - name: "lodash"
    version: "4.17.20"
    reason: "Sẽ update trong sprint tới"
    expired_at: "2026-04-15"
```

**Ví dụ 2: `.trivyignore` – Danh sách CVE bỏ qua (đơn giản, có hết hạn)**

```
# .trivyignore
# CVE đã review và chấp nhận rủi ro
CVE-2023-XXXXX exp:2026-06-30  # accepted risk – tự hết hạn bỏ qua vào 30/06/2026
CVE-2024-YYYYY                 # false positive – đã xác nhận (bỏ qua vĩnh viễn)
```

**Ví dụ 3: Chặn license cấm theo chính sách công ty**

```bash
# Quét license và chặn nếu phát hiện license cấm
trivy fs . \
  --scanners license \
  --license-full \
  --severity UNKNOWN,LOW,MEDIUM,HIGH,CRITICAL \
  --exit-code 1
```

**Ví dụ 4: OPA/Rego policy – Custom rule nâng cao**

```rego
# policy/deny-gpl.rego
# Chặn tất cả dependency sử dụng license GPL
package trivy

import rego.v1

deny contains msg if {
    some license in input.Results[_].Licenses[_]
    contains(license.Name, "GPL")
    not contains(license.Name, "LGPL")
    msg := sprintf(
        "License GPL không được phép theo chính sách công ty: package '%s' sử dụng license '%s'",
        [license.PkgName, license.Name]
    )
}
```

```rego
# policy/deny-critical-cve.rego
# Chặn deployment nếu có CVE Critical chưa được suppress
package trivy

import rego.v1

deny contains msg if {
    some vuln in input.Results[_].Vulnerabilities[_]
    vuln.Severity == "CRITICAL"
    msg := sprintf(
        "CVE Critical không được phép: %s trong package '%s' (severity: %s)",
        [vuln.VulnerabilityID, vuln.PkgName, vuln.Severity]
    )
}
```

```rego
# policy/deny-old-packages.rego
# Chặn dependency đã end-of-life hoặc quá cũ (ví dụ: Python 2.x, Node 14)
package trivy

import rego.v1

deny contains msg if {
    some pkg in input.Results[_].Packages[_]
    pkg.Name == "python"
    startswith(pkg.Version, "2.")
    msg := sprintf(
        "Python 2.x đã end-of-life, không được sử dụng: phát hiện version %s",
        [pkg.Version]
    )
}
```

```bash
# Chạy Trivy với custom policy
trivy fs . --policy ./policy/ --exit-code 1
```

**Ví dụ 5: Tích hợp vào CI/CD để tự động chặn**

```yaml
# .github/workflows/trivy-policy.yml
name: Trivy Policy Check

on: [push, pull_request]

jobs:
  policy-check:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4

      - name: Quét lỗ hổng – chặn nếu có Critical/High
        uses: aquasecurity/trivy-action@master
        with:
          scan-type: 'fs'
          scan-ref: '.'
          severity: 'CRITICAL,HIGH'
          exit-code: '1'  # CI fail nếu phát hiện

      - name: Quét license – chặn nếu có GPL
        uses: aquasecurity/trivy-action@master
        with:
          scan-type: 'fs'
          scan-ref: '.'
          scanners: 'license'
          exit-code: '1'
```

---

##### Grype – Ignore Rules và Severity Gate

Grype hỗ trợ cấu hình ignore rules và severity threshold, nhưng không có policy engine phức tạp như Trivy hay Dependency-Track:

| Loại Policy | Hỗ trợ | Cách cấu hình |
|-------------|--------|----------------|
| Lọc theo severity | Có | `--fail-on critical` |
| Bỏ qua CVE cụ thể | Có | `.grype.yaml` ignore rules |
| Bỏ qua package cụ thể | Có | `.grype.yaml` ignore rules |
| Lọc theo fix state (chỉ hiện CVE có bản fix) | Có | `--only-fixed` |
| EPSS score (hiển thị và sắp xếp) | Có | Hiển thị trong output, sắp xếp theo EPSS |
| OpenVEX (đánh dấu false positive theo chuẩn) | Có | `--vex` flag |
| Cấm license | Không | N/A |
| Custom rule tùy ý | Không | N/A |

```yaml
# .grype.yaml
ignore:
  # Bỏ qua CVE cụ thể
  - vulnerability: CVE-2023-XXXXX
    reason: "Accepted risk – module không được gọi trong production"

  # Bỏ qua tất cả lỗ hổng của package cụ thể
  - package:
      name: "lodash"
      version: "4.17.20"
      type: "npm"
    reason: "Sẽ update trong sprint tới"

  # Bỏ qua tất cả lỗ hổng severity Low
  - vulnerability: "*"
    fix-state: "not-fixed"   # Chỉ bỏ qua CVE chưa có bản fix
```

```bash
# Chặn CI nếu có lỗ hổng Critical
grype sbom:sbom.json --fail-on critical

# Chỉ hiện lỗ hổng đã có bản fix (bỏ qua CVE chưa patch)
grype sbom:sbom.json --only-fixed

# Sử dụng OpenVEX để đánh dấu false positive
grype sbom:sbom.json --vex ./vex-document.json
```

---

##### OSV-Scanner – Ignore Rules cơ bản

OSV-Scanner hỗ trợ cấu hình ignore ở mức cơ bản:

| Loại Policy | Hỗ trợ | Cách cấu hình |
|-------------|--------|----------------|
| Bỏ qua CVE cụ thể | Có | `osv-scanner.toml` |
| Bỏ qua package cụ thể | Có | `osv-scanner.toml` |
| Lọc theo severity | Không | N/A |
| Cấm license | Không | N/A |
| Custom rule | Không | N/A |

```toml
# osv-scanner.toml
[[IgnoredVulns]]
id = "GHSA-xxxx-yyyy-zzzz"
reason = "Accepted risk – không ảnh hưởng"
ignoreUntil = "2026-06-30T00:00:00Z"

[[IgnoredVulns]]
id = "CVE-2023-XXXXX"
reason = "False positive – đã xác nhận"
```

---

##### Dependency-Check – Suppression File

Dependency-Check sử dụng suppression file để quản lý false positive và accepted risk:

| Loại Policy | Hỗ trợ | Cách cấu hình |
|-------------|--------|----------------|
| Bỏ qua CVE cụ thể | Có | `suppression.xml` |
| Bỏ qua package cụ thể | Có | `suppression.xml` (theo CPE/GAV) |
| Lọc theo CVSS score | Có | `--failOnCVSS <score>` |
| Cấm license | Không | N/A |
| Custom rule | Không | N/A |

```xml
<!-- suppression.xml -->
<?xml version="1.0" encoding="UTF-8"?>
<suppressions xmlns="https://jeremylong.github.io/DependencyCheck/dependency-suppression.1.3.xsd">

  <!-- Bỏ qua CVE cụ thể -->
  <suppress>
    <notes><![CDATA[Accepted risk – module không được gọi]]></notes>
    <cve>CVE-2023-XXXXX</cve>
  </suppress>

  <!-- Bỏ qua tất cả lỗ hổng của package cụ thể -->
  <suppress>
    <notes><![CDATA[False positive – CPE match sai]]></notes>
    <gav regex="true">.*:lodash:.*</gav>
    <cve>CVE-2021-23337</cve>
  </suppress>

</suppressions>
```

```bash
# Chặn CI nếu CVSS score >= 7.0 (High)
dependency-check --project "MyApp" --scan . \
  --failOnCVSS 7 \
  --suppression suppression.xml
```

---

##### Dependency-Track – Policy Engine Đầy đủ (mạnh nhất)

Dependency-Track cung cấp Policy Engine mạnh nhất trong tất cả các công cụ, với giao diện GUI trực quan và REST API. Chi tiết xem tại [Mục V – Dependency-Track](#v-owasp-dependency-track--management-platform).

| Loại Policy | Hỗ trợ | Cách cấu hình |
|-------------|--------|----------------|
| Lọc theo severity (Critical, High, Medium, v.v.) | Có | GUI / API – Security Policy Condition |
| Cấm license cụ thể (GPL, AGPL, SSPL, v.v.) | Có | GUI / API – License Policy + License Group |
| Chặn component cụ thể (Package URL, CPE, SWID, Hash) | Có | GUI / API – Operational Policy Condition |
| Chặn component không có phiên bản mới | Có | GUI / API – Version Distance Policy |
| Chặn theo EPSS score (xác suất bị khai thác) | Có | GUI / API – EPSS Policy Condition |
| Chặn theo CWE (loại lỗ hổng cụ thể) | Có | GUI / API – CWE Policy Condition |
| Kết hợp nhiều điều kiện (AND/OR) | Có | GUI / API – Multiple Conditions per Policy |
| Gán policy cho project/team cụ thể | Có | GUI / API – Policy Assignment |
| Alert khi vi phạm (Slack, Teams, Email, Webhook, Jira) | Có | GUI / API – Notification |
| Audit trail (ai đã chấp nhận risk, khi nào) | Có | GUI – Audit History |

**Ví dụ Policy Enforcement trên Dependency-Track:**

```
Policy: "Chính sách Bảo mật Sản phẩm"
├── Condition 1: Severity = CRITICAL → Violation = FAIL
├── Condition 2: Severity = HIGH, EPSS > 0.7 → Violation = FAIL
├── Condition 3: License Group = "Copyleft" (GPL, AGPL, SSPL) → Violation = FAIL
├── Condition 4: Version Distance > 3 major versions → Violation = WARN
├── Condition 5: CWE-89 (SQL Injection) → Violation = FAIL
└── Áp dụng cho: Tất cả dự án Production
```

```bash
# Kiểm tra policy violation qua API
curl -s "http://dtrack.example.com/api/v1/violation/project/PROJECT_UUID" \
  -H "X-Api-Key: YOUR_KEY" | jq '.[] | {component: .component.name, policy: .policyCondition.policy.name, type: .type}'

# Tích hợp vào CI – fail nếu có policy violation
VIOLATIONS=$(curl -s "http://dtrack.example.com/api/v1/violation/project/PROJECT_UUID" \
  -H "X-Api-Key: YOUR_KEY" | jq 'length')

if [ "$VIOLATIONS" -gt 0 ]; then
  echo "Policy violation detected: $VIOLATIONS violations"
  exit 1
fi
```

---

#### 16.3 Bảng So sánh Custom Policy

| Loại Policy | Dependabot | Trivy | Grype | OSV-Scanner | DC-Check | DT-Track |
|-------------|-----------|-------|-------|-------------|----------|----------|
| Chặn theo Severity | — | **Có** | **Có** | — | **Có** (CVSS) | **Có** |
| Cấm License cụ thể | — | **Có** (Rego) | — | — | — | **Có** (GUI) |
| Bỏ qua CVE cụ thể (accepted risk) | — | **Có** | **Có** | **Có** | **Có** | **Có** |
| Bỏ qua Package cụ thể | **Có** | **Có** | **Có** | **Có** | **Có** | **Có** |
| Hết hạn bỏ qua (auto-expire) | — | **Có** | — | **Có** | — | — |
| Chặn theo EPSS score | — | — | **Có** | — | — | **Có** |
| Chặn theo CWE | — | **Có** (Rego) | — | — | — | **Có** |
| Chặn component quá cũ (version distance) | — | **Có** (Rego) | — | — | — | **Có** |
| OpenVEX (chuẩn FP marking) | — | — | **Có** | — | — | **Có** |
| Custom rule hoàn toàn tùy ý | — | **Có** (OPA/Rego) | — | — | — | — |
| GUI quản lý policy | — | — | — | — | — | **Có** |
| API quản lý policy | — | — | — | — | — | **Có** |
| Audit trail | — | — | — | — | — | **Có** |
| Gán policy theo project/team | — | — | — | — | — | **Có** |

#### 16.4 Đánh giá Custom Policy

| Công cụ | Trạng thái | Xếp hạng Policy | Ghi chú |
|---------|------------|------------------|---------|
| **Dependabot** | **Đã triển khai** | 1 - Đáp ứng một phần – Chỉ có allow/ignore dependency, không có policy enforcement thực sự. |
| **Trivy** | Chưa kiểm thử | 2 - Đáp ứng (dự kiến) – OPA/Rego cho phép viết policy tùy ý (severity, license, custom rule). Linh hoạt nhất trong các scanner. |
| **Grype** | Chưa kiểm thử | 1 - Đáp ứng một phần (dự kiến) – Ignore rules + severity gate + EPSS + OpenVEX. Đủ dùng nhưng không linh hoạt bằng Trivy. |
| **OSV-Scanner** | Chưa kiểm thử | 1 - Đáp ứng một phần (dự kiến) – Chỉ có ignore rules cơ bản. |
| **Dependency-Check** | Chưa kiểm thử | 1 - Đáp ứng một phần (dự kiến) – Suppression file + CVSS threshold. Cấu hình XML verbose. |
| **Dependency-Track** | Chưa kiểm thử | 2 - Đáp ứng (dự kiến) – Policy Engine mạnh nhất với GUI, API, nhiều loại condition, audit trail, gán theo project/team. Phù hợp nhất cho enterprise. |

#### 16.5 Khuyến nghị Kết hợp Policy

Để đạt hiệu quả policy enforcement tối đa, khuyến nghị kết hợp 2 lớp:

```
LỚP 1 – SCANNER POLICY (chặn sớm tại CI/CD)
┌──────────────────────────────────────────────────┐
│  Trivy + .trivy.yaml + OPA/Rego policy           │
│  • Chặn CI nếu có CVE Critical/High              │
│  • Chặn CI nếu có license GPL/AGPL               │
│  • Developer nhận feedback ngay tại PR            │
└──────────────────────┬───────────────────────────┘
                       │
LỚP 2 – PLATFORM POLICY (quản lý tập trung)
┌──────────────────────┴───────────────────────────┐
│  Dependency-Track Policy Engine                   │
│  • Policy tập trung cho toàn portfolio            │
│  • EPSS-based prioritization                      │
│  • License policy theo nhóm                       │
│  • Audit trail cho compliance                     │
│  • Ban lãnh đạo review trên dashboard             │
└──────────────────────────────────────────────────┘
```

---

## V. OWASP Dependency-Track – Management Platform

> **Lưu ý quan trọng:** Dependency-Track **không phải là scanner** — nó là một management platform. Do đó, Dependency-Track không được đưa vào so sánh trực tiếp với 5 scanner ở trên trong các Benchmark 1–15. Thay vào đó, mục này đánh giá Dependency-Track với vai trò là lớp quản lý tập trung, hoạt động phía trên các scanner.

### 5.1 Phân biệt Dependency-Check và Dependency-Track

Hai công cụ OWASP này thường bị nhầm lẫn vì tên gần giống nhau, nhưng vai trò **hoàn toàn khác biệt**:

```
┌─────────────────────────────────────────────────────────────────────────┐
│                         VAI TRÒ KHÁC NHAU                               │
│                                                                         │
│  Dependency-Check  = SCANNER      (quét dependency → tìm lỗ hổng)     │
│  Dependency-Track  = PLATFORM     (nhận SBOM → quản lý & theo dõi)    │
│  Dependabot        = SCANNER + AUTO-FIXER (tìm lỗ hổng + tự sửa)     │
│                                                                         │
│  Dependency-Check  → "Anh thợ đi kiểm tra"                            │
│  Dependency-Track  → "Anh quản lý tòa nhà"                            │
└─────────────────────────────────────────────────────────────────────────┘
```

| Tiêu chí | Dependency-Check | Dependency-Track |
|----------|------------------|------------------|
| **Loại** | Scanner CLI/Plugin | Management Platform (Web) |
| **Chức năng chính** | Quét dependency → báo cáo CVE | Nhận SBOM → theo dõi liên tục → dashboard + policy |
| **Tự quét dependency?** | Có | Không (cần scanner bên ngoài tạo SBOM) |
| **Tạo SBOM?** | Không | Quản lý SBOM (không tạo) |
| **Web Dashboard?** | Không (chỉ HTML report) | Có (dashboard riêng, đầy đủ) |
| **Quản lý nhiều dự án?** | Từng lần chạy riêng | Portfolio toàn bộ tổ chức |
| **Database** | NVD | NVD + GitHub Advisory + OSV + Snyk + OSS Index |
| **Deploy** | CLI, không cần server | Cần server riêng (Docker/Kubernetes) |
| **Phù hợp cho** | Developer cần quét trong CI | Enterprise cần quản lý tập trung, compliance |

### 5.2 Kiến trúc và Cách hoạt động

Dependency-Track hoạt động như một trung tâm tập trung, nhận SBOM từ các scanner rồi liên tục theo dõi và đánh giá rủi ro:

```
                        CÁC SCANNER TẠO SBOM
                    ┌──────────────────────────┐
                    │  Trivy     → SBOM (JSON)  │
                    │  Syft      → SBOM (JSON)  │
                    │  DC-Check  → Report       │
                    └──────────┬───────────────┘
                               │
                     Upload SBOM qua API / CI
                               │
                               ▼
              ┌────────────────────────────────────┐
              │       DEPENDENCY-TRACK SERVER       │
              │                                    │
              │  ┌──────────┐  ┌──────────────┐   │
              │  │ API      │  │ Vulnerability │   │
              │  │ Server   │  │ Analyzer      │   │
              │  │ (Java)   │  │ (NVD, GitHub, │   │
              │  │          │  │  OSV, Snyk,   │   │
              │  │          │  │  OSS Index)   │   │
              │  └────┬─────┘  └──────┬───────┘   │
              │       │               │            │
              │  ┌────┴───────────────┴───────┐   │
              │  │       PostgreSQL DB         │   │
              │  │  (SBOM, Vuln, Policy, ...)  │   │
              │  └────────────────────────────┘   │
              └──────────────┬─────────────────────┘
                             │
                             ▼
              ┌────────────────────────────────────┐
              │       WEB DASHBOARD (Frontend)      │
              │                                    │
              │  • Portfolio Overview               │
              │  • Vulnerability Audit              │
              │  • Policy Violations                │
              │  • Component Search                 │
              │  • Trends & Metrics                 │
              │  • Alert & Notification             │
              └────────────────────────────────────┘
```

**Luồng hoạt động chi tiết:**

1. **Scanner tạo SBOM:** Trivy, Syft hoặc scanner khác quét dự án → tạo SBOM ở định dạng CycloneDX (Dependency-Track chỉ hỗ trợ CycloneDX, không hỗ trợ SPDX từ v4.x).
2. **Upload SBOM:** SBOM được upload lên Dependency-Track qua REST API (thủ công hoặc tự động trong CI/CD pipeline).
3. **Phân tích lỗ hổng:** Dependency-Track so sánh các component trong SBOM với nhiều nguồn vulnerability (NVD, GitHub Advisory, OSV, Snyk DB, OSS Index).
4. **Đánh giá Policy:** Policy engine tự động đánh giá risk dựa trên các quy tắc đã cấu hình (ví dụ: block dependency có CVE Critical, cấm license GPL, v.v.).
5. **Thông báo:** Gửi alert qua webhook, email, Slack, Microsoft Teams hoặc các kênh khác khi phát hiện lỗ hổng mới.
6. **Theo dõi liên tục:** Ngay cả khi không có SBOM mới, Dependency-Track vẫn liên tục đối chiếu các component đã biết với lỗ hổng mới được công bố.

### 5.3 Phương án Triển khai (Deployment)

#### Phương án 1: Docker Compose (khuyến nghị cho đánh giá và team nhỏ)

Phương án đơn giản nhất, phù hợp để thử nghiệm và triển khai cho team nhỏ–trung bình:

```yaml
# docker-compose.yml
version: '3.8'
services:
  dtrack-apiserver:
    image: dependencytrack/apiserver:latest
    ports:
      - "8081:8080"
    volumes:
      - dtrack-data:/data
    environment:
      - ALPINE_DATABASE_MODE=external
      - ALPINE_DATABASE_URL=jdbc:postgresql://postgres:5432/dtrack
      - ALPINE_DATABASE_DRIVER=org.postgresql.Driver
      - ALPINE_DATABASE_USERNAME=dtrack
      - ALPINE_DATABASE_PASSWORD=dtrack
    depends_on:
      - postgres
    restart: unless-stopped

  dtrack-frontend:
    image: dependencytrack/frontend:latest
    ports:
      - "8080:8080"
    environment:
      - API_BASE_URL=http://localhost:8081
    depends_on:
      - dtrack-apiserver
    restart: unless-stopped

  postgres:
    image: postgres:16-alpine
    environment:
      - POSTGRES_DB=dtrack
      - POSTGRES_USER=dtrack
      - POSTGRES_PASSWORD=dtrack
    volumes:
      - postgres-data:/var/lib/postgresql/data
    restart: unless-stopped

volumes:
  dtrack-data:
  postgres-data:
```

**Các bước cài đặt:**

```bash
# Bước 1: Tạo thư mục và file docker-compose.yml
mkdir dependency-track && cd dependency-track

# Bước 2: Khởi chạy
docker compose up -d

# Bước 3: Truy cập web dashboard
# Frontend: http://localhost:8080
# API: http://localhost:8081
# Đăng nhập mặc định: admin / admin

# Bước 4: Upload SBOM từ scanner
# Tạo SBOM bằng Trivy
trivy fs /path/to/project --format cyclonedx --output sbom.json

# Upload SBOM qua API
curl -X POST "http://localhost:8081/api/v1/bom" \
  -H "X-Api-Key: YOUR_API_KEY" \
  -H "Content-Type: multipart/form-data" \
  -F "project=PROJECT_UUID" \
  -F "bom=@sbom.json"
```

**Yêu cầu tài nguyên:**

| Tài nguyên | Tối thiểu | Khuyến nghị |
|-----------|-----------|-------------|
| CPU | 2 core | 4 core |
| RAM | 4 GB (Xmx4G) | 16 GB |
| Disk | 10 GB | 50 GB (tùy số lượng dự án) |
| Network | Truy cập internet (tải NVD mirror) | Có thể cấu hình offline mirror |

#### Phương án 2: Kubernetes / Helm Chart (khuyến nghị cho production / enterprise)

Phù hợp cho triển khai production với yêu cầu cao về tính khả dụng, khả năng mở rộng:

```bash
# Cài đặt qua Helm
helm repo add dependencytrack https://dependencytrack.github.io/helm-charts
helm repo update

helm install dependency-track dependencytrack/dependency-track \
  --namespace dependency-track \
  --create-namespace \
  --set apiserver.resources.requests.memory=4Gi \
  --set apiserver.resources.requests.cpu=2 \
  --set frontend.env.API_BASE_URL=https://dtrack-api.example.com
```

**Ưu điểm so với Docker Compose:**

- High Availability (HA) với nhiều replica
- Auto-scaling dựa trên tải
- Tích hợp sẵn với Ingress, TLS, monitoring
- Quản lý secret an toàn hơn qua Kubernetes Secret

#### Phương án 3: Cài đặt thủ công trên server (cho môi trường hạn chế)

Phù hợp cho môi trường không có Docker/Kubernetes:

```bash
# Yêu cầu: JRE 17+, PostgreSQL 11+
# Tải API Server
wget https://github.com/DependencyTrack/dependency-track/releases/download/4.x.x/dependency-track-apiserver.war

# Chạy
java -Xmx4g -jar dependency-track-apiserver.war

# Frontend deploy riêng hoặc dùng bundled version
```

#### So sánh các phương án triển khai

| Tiêu chí | Docker Compose | Kubernetes | Cài đặt Thủ công |
|----------|---------------|------------|------------------|
| **Độ phức tạp** | Thấp | Trung bình–Cao | Trung bình |
| **Thời gian cài đặt** | ~15 phút | ~30–60 phút | ~1–2 giờ |
| **High Availability** | Không | Có | Cần cấu hình thêm |
| **Auto-scaling** | Không | Có | Không |
| **Phù hợp cho** | PoC, team nhỏ, đánh giá | Production, enterprise | Môi trường air-gapped, hạn chế |
| **Bảo trì** | Thấp (docker compose pull) | Thấp (helm upgrade) | Cao (thủ công) |

### 5.4 Tính năng Chính

| Tính năng | Mô tả | Lợi ích |
|-----------|-------|---------|
| **SBOM Management** | Nhận, lưu trữ và quản lý SBOM từ nhiều dự án tập trung (chỉ CycloneDX, không hỗ trợ SPDX từ v4.x) | Một nơi duy nhất để biết toàn bộ thành phần phần mềm trong tổ chức |
| **Continuous Vulnerability Monitoring** | Liên tục đối chiếu component đã biết với lỗ hổng mới | Phát hiện lỗ hổng mới ngay cả khi không quét lại dự án |
| **Multi-Source Vulnerability Intelligence** | Tổng hợp từ NVD, GitHub Advisory, OSV, Sonatype OSS Index, Trivy DB (Snyk cần enterprise license) | Phạm vi phủ rộng, giảm blind spot |
| **EPSS Integration** | Tích hợp Exploit Prediction Scoring System | Ưu tiên xử lý lỗ hổng có khả năng bị khai thác cao nhất |
| **Policy Engine** | Tự động đánh giá risk dựa trên quy tắc | Block dependency vi phạm policy trước khi vào production |
| **Portfolio Management** | Quản lý tất cả dự án/ứng dụng trên 1 dashboard | Ban lãnh đạo nắm bắt tình trạng bảo mật tổng thể |
| **Component Search** | Tìm kiếm component trên toàn portfolio | Khi có lỗ hổng mới (ví dụ Log4Shell), tìm ngay tất cả dự án bị ảnh hưởng |
| **Notification** | Gửi alert qua Webhook, Slack, Microsoft Teams, Email, Jira | Đội ngũ được thông báo kịp thời |
| **REST API** | API-first design, mọi thao tác đều có API | Tự động hóa hoàn toàn qua CI/CD |
| **Audit Trail** | Ghi nhận lịch sử thay đổi, quyết định xử lý | Phục vụ audit và compliance |

### 5.5 Đánh giá Dependency-Track

Vì Dependency-Track là management platform (không phải scanner), việc đánh giá được thực hiện theo các tiêu chí khác so với 5 scanner ở Benchmark 1–15:

| Tiêu chí | Xếp hạng | Ghi chú |
|----------|----------|---------|
| **SBOM Management** | 2 - Đáp ứng (dự kiến) | Nền tảng quản lý SBOM hàng đầu cho open source. Chỉ hỗ trợ CycloneDX (SPDX đã bị loại bỏ từ v4.x). |
| **Dashboard & Visualization** | 2 - Đáp ứng (dự kiến) | Web dashboard trực quan với portfolio overview, vulnerability audit, trend analysis. |
| **Multi-Source Vulnerability DB** | 2 - Đáp ứng (dự kiến) | Tổng hợp 5+ nguồn (NVD, GitHub Advisory, OSV, Snyk, OSS Index). Nhiều hơn bất kỳ scanner đơn lẻ nào. |
| **Policy Engine** | 2 - Đáp ứng (dự kiến) | Hỗ trợ policy dựa trên severity, license, component age, EPSS score. |
| **Portfolio Management** | 2 - Đáp ứng (dự kiến) | Quản lý hàng trăm dự án trên 1 dashboard. Tính năng nổi bật nhất. |
| **API & Automation** | 2 - Đáp ứng (dự kiến) | API-first design, tích hợp dễ dàng vào CI/CD pipeline. |
| **Notification & Alert** | 2 - Đáp ứng (dự kiến) | Hỗ trợ Webhook, Slack, Teams, Email, Jira. |
| **Ease of Deployment** | 1 - Đáp ứng một phần (dự kiến) | Cần server riêng (Docker hoặc Kubernetes). Phức tạp hơn các CLI scanner. |
| **Maintenance** | 1 - Đáp ứng một phần (dự kiến) | Cần quản lý database PostgreSQL, backup, update. |

**Khi nào nên dùng Dependency-Track?**

```
✅ NÊN dùng khi:
  • Quản lý nhiều dự án/repository (portfolio > 5 dự án)
  • Cần dashboard tập trung cho ban lãnh đạo và đội bảo mật
  • Yêu cầu compliance (ISO 27001, SOC 2, PCI-DSS)
  • Cần policy engine tự động đánh giá risk
  • Cần khả năng "tìm tất cả dự án bị ảnh hưởng bởi lỗ hổng X"

❌ CHƯA CẦN khi:
  • Chỉ có 1-2 dự án nhỏ
  • Chưa có quy trình SBOM
  • Không có server để deploy
  • GitHub Security tab đã đủ đáp ứng nhu cầu
```

**Tích hợp Dependency-Track vào CI/CD pipeline:**

```yaml
# .github/workflows/sbom-upload.yml
name: SBOM Upload to Dependency-Track

on:
  push:
    branches: [main]
  release:
    types: [published]

jobs:
  sbom-upload:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4

      - name: Tạo SBOM bằng Trivy
        uses: aquasecurity/trivy-action@master
        with:
          scan-type: 'fs'
          scan-ref: '.'
          format: 'cyclonedx'
          output: 'sbom.json'

      - name: Upload SBOM lên Dependency-Track
        uses: DependencyTrack/gh-upload-sbom@v3
        with:
          serverhostname: ${{ secrets.DTRACK_HOST }}
          apikey: ${{ secrets.DTRACK_API_KEY }}
          projectname: 'Test-SCA'
          projectversion: ${{ github.sha }}
          bomfilename: 'sbom.json'
          autocreate: true
```

---

## VI. Bảng So sánh Tổng hợp

### 6.1 So sánh 5 Scanner

| # | Benchmark | Dependabot | Trivy | Grype + Syft | OSV-Scanner | Dependency-Check |
|---|-----------|------------|-------|--------------|-------------|------------------|
| 1 | Vulnerability Detection Accuracy | 2 | 2* | 2* | 2* | 1* |
| 2 | Vulnerability Database Coverage | 1 | 2* | 2* | 2* | 1* |
| 3 | SBOM Generation | 0 | 2* | 2* | 1* | 0 |
| 4 | Auto-Remediation | **2** | 0 | 0 | 1* | 0 |
| 5 | CI/CD Integration | 2 | 2* | 2* | 2* | 2* |
| 6 | Multi-Language Support | 2 | 2* | 2* | 1* | 1* |
| 7 | Container Image Scanning | 0 | 2* | 2* | 1* | 0 |
| 8 | License Compliance | 0 | 2* | 1* | 0 | 0 |
| 9 | False Positive Rate | 2 | 2* | 2* | 2* | 1* |
| 10 | Scan Performance | 2 | 2* | 2* | 2* | 1* |
| 11 | Offline Capability | 0 | 2* | 2* | 0 | 2* |
| 12 | Transitive Dependency Detection | 2 | 2* | 2* | 1* | 1* |
| 13 | Reporting and Dashboard | 1 | 1* | 1* | 1* | 2* |
| 14 | Ease of Setup | **2** | 2* | 2* | 2* | 1* |
| 15 | Custom Policy Enforcement | **1** | 2* | 1* | 1* | 1* |

> **Chú thích:** In đậm = đã xác nhận qua kiểm thử. \* = xếp hạng dự kiến, sẽ được xác nhận qua kiểm thử thực tế. Thang điểm: 0 = Không đáp ứng, 1 = Đáp ứng một phần, 2 = Đáp ứng.
>
> **Lưu ý:** Dependency-Track (management platform) có Custom Policy Enforcement xếp hạng 2* – xem chi tiết tại [Mục V](#v-owasp-dependency-track--management-platform) và [Benchmark 16](#benchmark-16--custom-policy-enforcement).

### 6.2 So sánh Management Platform (Dependency-Track)

Dependency-Track không phải scanner nên không so sánh trực tiếp với bảng trên. Thay vào đó, bảng dưới đây so sánh vai trò management platform của Dependency-Track với khả năng tương đương (nếu có) của các scanner:

| Tiêu chí Management Platform | Dependency-Track | Dependabot (GitHub UI) | Trivy | Dependency-Check |
|-------------------------------|-----------------|------------------------|-------|------------------|
| Portfolio Dashboard (nhiều dự án) | 2* – Hàng đầu | 1 – Từng repo riêng | 0 | 0 |
| SBOM Management tập trung | 2* – Chức năng chính | 0 | 0 | 0 |
| Policy Engine tự động | 2* – Severity, license, EPSS | 0 | 1* – `.trivy.yaml` policy | 0 |
| Multi-Source Vulnerability DB | 2* – NVD + GitHub + OSV + Snyk + OSS Index | 1 – GitHub Advisory DB | 2* – 30+ nguồn | 1* – NVD + OSS Index |
| Continuous Monitoring (không cần quét lại) | 2* – Liên tục | 2 – Quét daily | 0 – Cần chạy lại | 0 – Cần chạy lại |
| Notification (Slack, Teams, Email, Jira) | 2* – Đa kênh | 1 – GitHub notification | 0 | 0 |
| Component Search toàn portfolio | 2* – Tìm ngay | 0 | 0 | 0 |
| Audit Trail / Compliance | 2* – Đầy đủ | 1 – Alert history | 0 | 1* – HTML report |
| Custom Policy Enforcement | 2* – Policy Engine đầy đủ (GUI/API) | 1 – Chỉ allow/ignore | 2* – OPA/Rego | 1* – Suppression XML |
| Ease of Deployment | 1* – Cần server | 2 – SaaS | 2* – CLI | 1* – CLI + JRE |

### 6.3 Bảng Tổng hợp Vai trò của Tất cả Công cụ

| Vai trò | Công cụ Tốt nhất | Ghi chú |
|---------|------------------|---------|
| **Auto-Remediation** (tự sửa lỗi) | Dependabot | Tự tạo PR, zero-setup, miễn phí trên GitHub |
| **Vulnerability Scanning** (quét lỗ hổng) | Trivy | All-in-one, 30+ nguồn, nhanh, đa ngôn ngữ |
| **SBOM Generation** (tạo SBOM) | Trivy hoặc Syft | Cả hai đều hỗ trợ CycloneDX và SPDX |
| **Container Scanning** (quét container) | Trivy | Hàng đầu ngành, full layer analysis |
| **Portfolio Management** (quản lý tập trung) | Dependency-Track | Dashboard, policy engine, SBOM management |
| **Lowest False Positive** (ít cảnh báo sai) | OSV-Scanner | Database mở, kiểm duyệt bởi maintainer chính thức |
| **Java/.NET Scanning** (quét Java/.NET) | Dependency-Check | Evidence-based, plugin Maven/Gradle mature |
| **Compliance Reporting** (báo cáo compliance) | Dependency-Track | Audit trail, SBOM export, policy violation report |

---

## VII. Khuyến nghị

### Dành cho Team Nhỏ / Startup (sử dụng GitHub)

```
Dependabot (tự động tạo PR sửa lỗi)  ←  Đã triển khai
    +
Trivy (quét toàn diện trong CI)  ←  Cần cài đặt
```

**Lý do:** Cài đặt tối thiểu, phạm vi phủ tối đa. Dependabot xử lý auto-remediation trong khi Trivy bổ sung các khoảng trống (SBOM, Container Scanning, License Detection). Chưa cần Dependency-Track ở giai đoạn này vì số lượng dự án ít.

### Dành cho Team Trung bình (5–20 dự án)

```
Dependabot (tự động tạo PR sửa lỗi)  ←  Đã triển khai
    +
Trivy (quét toàn diện + tạo SBOM trong CI)  ←  Cần cài đặt
    +
Dependency-Track (dashboard tập trung + quản lý SBOM)  ←  Cần triển khai
```

**Lý do:** Khi số lượng dự án tăng lên, cần dashboard tập trung để nắm bắt tình trạng bảo mật tổng thể. Dependency-Track nhận SBOM từ Trivy, cung cấp portfolio view và continuous monitoring.

### Dành cho Team Đa nền tảng (GitLab, Bitbucket, v.v.)

```
Trivy (scanner chính)
    +
OSV-Scanner (scanner phụ cho cơ sở dữ liệu mở)
    +
Dependency-Track (dashboard tập trung)
```

**Lý do:** Cả Trivy, OSV-Scanner và Dependency-Track đều platform-agnostic và miễn phí. Không phụ thuộc vào GitHub.

### Dành cho Enterprise / Yêu cầu Compliance

```
Trivy hoặc Syft (tạo SBOM)
    +
Grype (quét lỗ hổng bổ sung)
    +
OWASP Dependency-Track (dashboard tập trung + quản lý SBOM + policy engine)
    +
Dependabot hoặc Renovate (auto-remediation)
```

**Lý do:** Quản lý vòng đời SBOM đầy đủ với policy enforcement tập trung và báo cáo compliance. Dependency-Track là trung tâm của kiến trúc này, đóng vai trò "single pane of glass" cho toàn bộ portfolio.

---

## VIII. Lộ trình Triển khai và Các bước Tiếp theo

### 8.1 Lộ trình Triển khai theo Giai đoạn

#### Giai đoạn 1 – Nền tảng (Tháng 1–2)

> Mục tiêu: Hoàn thành đánh giá các scanner và chọn tổ hợp công cụ tối ưu.

| # | Hạng mục Công việc | Ưu tiên | Trạng thái | Người phụ trách |
|---|-------------------|---------|------------|-----------------|
| 1.1 | Cài đặt và kiểm thử **Trivy** trên repository Test-SCA | Cao | **Đã hoàn thành** — tích hợp vào GitHub Actions, chạy trên mỗi push (60 alert, SARIF → Security tab, SBOM artifact) | *(Cần bổ sung)* |
| 1.2 | Cài đặt và kiểm thử **Grype + Syft** trên repository Test-SCA | Cao | **Đã hoàn thành** — tích hợp vào GitHub Actions, chạy trên mỗi push (60 alert, SARIF + SBOM artifact) | *(Cần bổ sung)* |
| 1.3 | Cài đặt và kiểm thử **OSV-Scanner** trên repository Test-SCA | Trung bình | **Đã hoàn thành** — tích hợp vào GitHub Actions, chạy trên mỗi push (124 alert, SARIF → Security tab) | *(Cần bổ sung)* |
| 1.4 | Cài đặt và kiểm thử **OWASP Dependency-Check** trên repository Test-SCA | Trung bình | Chưa thực hiện | *(Cần bổ sung)* |
| 1.5 | Cập nhật báo cáo với kết quả kiểm thử thực tế (thay thế xếp hạng dự kiến) | Cao | Chưa thực hiện | *(Cần bổ sung)* |
| 1.6 | Xác nhận tổ hợp công cụ cuối cùng và trình ban lãnh đạo phê duyệt | Cao | Chưa thực hiện | *(Cần bổ sung)* |

#### Giai đoạn 2 – Tích hợp Scanner vào CI/CD (Tháng 2–3)

> Mục tiêu: Scanner được chọn hoạt động tự động trong CI/CD pipeline cho tất cả repository chính.

| # | Hạng mục Công việc | Ưu tiên | Trạng thái | Người phụ trách |
|---|-------------------|---------|------------|-----------------|
| 2.1 | Tạo GitHub Actions workflow template cho scanner đã chọn | Cao | **Đã hoàn thành** — `.github/workflows/sca-scan.yml` tích hợp Trivy, Grype+Syft, OSV-Scanner, DC-Check | *(Cần bổ sung)* |
| 2.2 | Tích hợp SBOM generation vào CI/CD pipeline | Cao | **Đã hoàn thành** — Trivy tạo CycloneDX SBOM artifact; Syft tạo SBOM artifact trên mỗi push | *(Cần bổ sung)* |
| 2.3 | Triển khai scanner trên tất cả repository chính (rollout) | Cao | Chưa thực hiện (hiện chỉ trên Test-SCA) | *(Cần bổ sung)* |
| 2.4 | Cấu hình severity threshold (fail CI khi có lỗ hổng Critical) | Trung bình | Chưa thực hiện | *(Cần bổ sung)* |
| 2.5 | Viết tài liệu hướng dẫn cho developer | Trung bình | Chưa thực hiện | *(Cần bổ sung)* |

#### Giai đoạn 3 – Triển khai Dependency-Track (Tháng 3–4)

> Mục tiêu: Dependency-Track hoạt động như dashboard tập trung, nhận SBOM từ tất cả dự án.

| # | Hạng mục Công việc | Ưu tiên | Trạng thái | Người phụ trách |
|---|-------------------|---------|------------|-----------------|
| 3.1 | Triển khai Dependency-Track (Docker Compose hoặc Kubernetes) | Cao | Chưa thực hiện | *(Cần bổ sung)* |
| 3.2 | Cấu hình Dependency-Track (user, team, permission) | Cao | Chưa thực hiện | *(Cần bổ sung)* |
| 3.3 | Tích hợp CI/CD pipeline upload SBOM lên Dependency-Track | Cao | Chưa thực hiện | *(Cần bổ sung)* |
| 3.4 | Cấu hình notification (Slack/Teams/Email) | Trung bình | Chưa thực hiện | *(Cần bổ sung)* |
| 3.5 | Cấu hình policy engine (severity threshold, license policy) | Trung bình | Chưa thực hiện | *(Cần bổ sung)* |
| 3.6 | Upload SBOM từ tất cả repository chính | Cao | Chưa thực hiện | *(Cần bổ sung)* |

#### Giai đoạn 4 – Hoàn thiện và Vận hành (Tháng 4–6)

> Mục tiêu: Quy trình SCA hoạt động ổn định, tích hợp vào SDLC, sẵn sàng cho audit.

| # | Hạng mục Công việc | Ưu tiên | Trạng thái | Người phụ trách |
|---|-------------------|---------|------------|-----------------|
| 4.1 | Thiết lập SCA gate trong CI/CD (chặn deploy khi vi phạm policy) | Cao | Chưa thực hiện | *(Cần bổ sung)* |
| 4.2 | Thiết lập quy trình xử lý lỗ hổng (SLA theo severity) | Cao | Chưa thực hiện | *(Cần bổ sung)* |
| 4.3 | Tạo báo cáo compliance định kỳ (tuần/tháng) | Trung bình | Chưa thực hiện | *(Cần bổ sung)* |
| 4.4 | Đào tạo developer về quy trình SCA và cách xử lý alert | Trung bình | Chưa thực hiện | *(Cần bổ sung)* |
| 4.5 | Đánh giá hiệu quả sau 3 tháng vận hành | Trung bình | Chưa thực hiện | *(Cần bổ sung)* |

### 8.2 Kế hoạch Tương lai (sau 6 tháng)

| # | Hạng mục | Mô tả | Ưu tiên |
|---|----------|-------|---------|
| F1 | **Mở rộng sang SAST** | Tích hợp Static Application Security Testing (ví dụ: Semgrep, SonarQube) để quét mã nguồn do tổ chức phát triển, bổ sung cho SCA quét thành phần bên thứ 3. | Trung bình |
| F2 | **Container Runtime Security** | Triển khai quét container image trong registry (Harbor, ECR, ACR) và runtime monitoring (Falco). | Trung bình |
| F3 | **Supply Chain Security nâng cao** | Đánh giá và triển khai Socket.dev hoặc công cụ tương đương để phát hiện supply chain attack trước khi có CVE (phân tích hành vi package). | Thấp |
| F4 | **Tích hợp Dependency-Track với SIEM/SOAR** | Kết nối Dependency-Track với hệ thống SIEM (Splunk, ELK) hoặc SOAR để tự động hóa quy trình phản hồi sự cố. | Thấp |
| F5 | **SCA cho Mobile App** | Mở rộng SCA cho ứng dụng mobile (iOS/Android) bao gồm quét dependency của CocoaPods, Swift Package Manager, Gradle (Android). | Thấp |
| F6 | **Metric & KPI Dashboard** | Xây dựng dashboard KPI bảo mật tổng hợp (MTTR, số lỗ hổng theo thời gian, compliance score) từ dữ liệu Dependency-Track. | Trung bình |
| F7 | **Tự động hóa Remediation đa nền tảng** | Đánh giá Renovate để thay thế/bổ sung Dependabot cho các repository ngoài GitHub (GitLab, Bitbucket). | Trung bình |

### 8.3 Rủi ro và Giảm thiểu

| Rủi ro | Tác động | Xác suất | Biện pháp Giảm thiểu |
|--------|----------|----------|----------------------|
| Developer bỏ qua hoặc không xử lý SCA alert | Lỗ hổng tồn đọng, không được sửa | Cao | Thiết lập SLA theo severity, SCA gate chặn deploy, đào tạo |
| False positive quá nhiều gây "alert fatigue" | Developer mất niềm tin vào công cụ, bỏ qua cả alert thật | Trung bình | Chọn scanner có tỷ lệ FP thấp, cấu hình suppression, review định kỳ |
| Dependency-Track server gặp sự cố | Mất khả năng quan sát tập trung | Thấp | Backup định kỳ, HA deployment (Kubernetes), monitoring |
| Breaking change khi auto-merge PR từ Dependabot | Ứng dụng bị lỗi trên production | Trung bình | Luôn chạy CI test trước khi merge, không bật auto-merge cho major version |
| NVD API key bị revoke hoặc rate limit | Dependency-Check không thể cập nhật DB | Trung bình | Sử dụng NVD mirror, hoặc chuyển sang scanner không phụ thuộc NVD |

---

## IX. Tài liệu Tham khảo

- [GitHub Dependabot Documentation](https://docs.github.com/en/code-security/dependabot)
- [Trivy Documentation](https://trivy.dev/latest/docs/)
- [Grype GitHub Repository](https://github.com/anchore/grype)
- [Syft GitHub Repository](https://github.com/anchore/syft)
- [OSV-Scanner GitHub Repository](https://github.com/google/osv-scanner)
- [OSV.dev – Open Source Vulnerabilities](https://osv.dev/)
- [OWASP Dependency-Check](https://owasp.org/www-project-dependency-check/)
- [OWASP Dependency-Track](https://dependencytrack.org/)
- [Dependency-Track GitHub Repository](https://github.com/DependencyTrack/dependency-track)
- [Dependency-Track Helm Charts](https://github.com/DependencyTrack/helm-charts)
- [CycloneDX SBOM Standard](https://cyclonedx.org/)
- [SPDX SBOM Standard](https://spdx.dev/)
- [NIST Executive Order 14028 – SBOM Requirements](https://www.nist.gov/itl/executive-order-14028-improving-nations-cybersecurity)
- [EPSS – Exploit Prediction Scoring System](https://www.first.org/epss/)
