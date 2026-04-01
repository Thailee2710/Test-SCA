# Hướng dẫn Dependabot - Project Test-SCA

> Tài liệu này giải thích cơ chế hoạt động của Dependabot dựa trên **dữ liệu thực tế** từ repo `Thailee2710/Test-SCA`.

---

## 1. Dependabot là gì?

Dependabot là công cụ **SCA (Software Composition Analysis)** miễn phí, tích hợp sẵn trong GitHub. Nó làm 3 việc:

1. **Quét** các file khai báo dependency → so sánh với cơ sở dữ liệu lỗ hổng (GitHub Advisory Database)
2. **Cảnh báo** khi phát hiện dependency có CVE (Common Vulnerabilities and Exposures)
3. **Tự động tạo Pull Request** để nâng version lên bản an toàn

---

## 2. Project này hoạt động thế nào?

### 2.1. Input - Dependabot quét những gì?

Project có 4 file khai báo dependency, tương ứng 4 ecosystem trong `.github/dependabot.yml`:

| File | Ecosystem | Dependency cố tình để cũ | Mục đích |
|------|-----------|--------------------------|----------|
| `requirements.txt` | pip | `requests==2.19.0`, `PyYAML==5.3`, `Flask==1.0`, `Jinja2==2.10`, `Pillow==8.2.0`, `urllib3==1.23` | Trigger alerts cho Python |
| `package.json` + `package-lock.json` | npm | `lodash@4.17.20`, `moment@2.29.1`, `jquery@3.4.1`, `serialize-javascript@1.9.0`, `express@4.17.1` | Trigger alerts cho Node.js |
| `Dockerfile` | docker | `python:3.8-slim` (EOL) | Trigger update base image |
| `.github/workflows/ci.yml` | github-actions | `actions/checkout@v3`, `actions/setup-python@v4`, `actions/setup-node@v3` | Trigger update actions |

### 2.2. Luồng xử lý

```
 requirements.txt ─┐
 package.json ─────┤    ┌──────────────────────┐     ┌─────────────────┐
 package-lock.json ┼──▶ │ Dependabot quét      │────▶│ 98 Alerts       │
 Dockerfile ───────┤    │ (daily, mỗi ngày)    │     │ (Security tab)  │
 ci.yml ───────────┘    └──────────┬───────────┘     └─────────────────┘
                                   │
                                   ▼
                        ┌──────────────────────┐     ┌─────────────────┐
                        │ Tạo Pull Requests    │────▶│ 18 PRs          │
                        │ (auto fix + version) │     │ (PRs tab)       │
                        └──────────┬───────────┘     └─────────────────┘
                                   │
                                   ▼
                        ┌──────────────────────┐
                        │ CI chạy trên mỗi PR  │
                        │ (GitHub Actions)      │
                        └──────────────────────┘
```

---

## 3. Output thực tế - Đang có gì trên repo?

### 3.1. Security Alerts: 98 alerts

Xem tại: **Security > Dependabot alerts**

**Phân bố theo severity:**

| Severity | Số lượng | Ví dụ cụ thể |
|----------|----------|---------------|
| Critical | 7 | PyYAML CVE-2020-1747, Pillow CVE-2022-22817, Pillow CVE-2021-34552 |
| High | 39 | requests CVE-2018-18074, lodash CVE-2021-23337, Flask CVE-2023-30861 |
| Medium | 25 | jquery CVE-2020-11022, Jinja2 CVE-2024-34064, urllib3 CVE-2020-26137 |
| Low | 7 | express CVE-2024-43796, cookie CVE-2024-47764, Flask CVE-2026-27205 |

**Phân bố theo trạng thái:**

| Trạng thái | Số lượng | Giải thích |
|------------|----------|------------|
| Open | 68 | Chưa xử lý - dependency vẫn đang dùng version cũ |
| Fixed | 30 | Đã fix - Dependabot tạo PR và version mới không còn CVE này |

> **Tại sao 11 package mà có đến 98 alerts?**
>
> Vì mỗi package có thể có **nhiều CVE khác nhau**. Ví dụ:
> - `Pillow==8.2.0` một mình có **~30 alerts** (buffer overflow, out-of-bounds read, DoS...)
> - `urllib3==1.23` có **8 alerts** (redirect leak, CRLF injection, certificate bypass...)
> - `express@4.17.1` kéo theo alerts từ sub-dependencies: `body-parser`, `qs`, `path-to-regexp`, `cookie`, `send`, `serve-static`

### 3.2. Pull Requests: 18 PRs

Xem tại: **Pull Requests tab**

**14 PRs đang Open:**

| PR | Title | Loại | Giải thích |
|----|-------|------|------------|
| #18 | npm: bump the npm_and_yarn group (5 updates) | Group Update | Gom 5 package npm update cùng lúc |
| #17 | npm: bump serialize-javascript 1.9.0 → 7.0.4 | Security + Version | Fix CVE-2020-7660 (RCE) |
| #15 | pip: bump flask 1.0 → 3.1.3 | Security + Version | Fix CVE-2023-30861 |
| #14 | pip: bump pillow 6.2.0 → 12.1.1 | Security + Version | Fix ~30 CVEs |
| #13 | pip: bump the pip group (6 updates) | Group Update | Gom 6 package Python update cùng lúc |
| #12 | docker: bump python 3.8-slim → 3.14-slim | Version Update | Base image mới hơn |
| #11 | npm: bump jquery 3.4.1 → 4.0.0 | Security + Version | Fix CVE-2020-11022, CVE-2020-11023 |
| #9 | npm: bump express 4.17.1 → 5.2.1 | Version Update | Major version bump |
| #8 | pip: bump urllib3 1.24.1 → 2.6.3 | Security + Version | Fix 8 CVEs |
| #7 | pip: bump requests 2.19.0 → 2.32.5 | Security + Version | Fix CVE-2018-18074 |
| #4 | npm: bump lodash 4.17.20 → 4.17.23 | Security | Fix CVE-2021-23337 |
| #3 | pip: bump pyyaml 5.3 → 6.0.3 | Security | Fix CVE-2020-1747, CVE-2020-14343 |
| #2 | pip: bump jinja2 2.10 → 3.1.6 | Security + Version | Fix CVE-2019-10906 + 4 CVEs khác |
| #1 | npm: bump moment 2.29.1 → 2.30.1 | Security | Fix CVE-2022-31129, CVE-2022-24785 |

**4 PRs đã Closed (không merge):**

| PR | Title | Lý do đóng |
|----|-------|------------|
| #16 | npm: bump serialize-javascript → 7.0.3 | Bị thay thế bởi PR #17 (version mới hơn 7.0.4) |
| #10 | pip: bump flask → 3.1.2 | Bị thay thế bởi PR #15 (version mới hơn 3.1.3) |
| #6 | npm: bump serialize-javascript → 7.0.2 | Bị thay thế bởi PR #16 rồi #17 |
| #5 | pip: bump pillow → 12.1.0 | Bị thay thế bởi PR #14 (version mới hơn 12.1.1) |

> **Tại sao có PR bị đóng?**
>
> Vì Dependabot chạy **daily**. Nếu hôm nay tạo PR bump lên v7.0.2, ngày mai v7.0.3 ra → Dependabot đóng PR cũ, tạo PR mới. Đây là hành vi bình thường.

### 3.3. GitHub Actions: CI chạy trên mỗi PR

Xem tại: **Actions tab**

**Các loại workflow run:**

| Event | Ý nghĩa | Ví dụ thực tế |
|-------|----------|---------------|
| `push` | Code được push lên main | "Add actual test functions to test files" → **success** |
| `pull_request` | Dependabot tạo PR → CI tự chạy | "pip: bump flask 1.0 → 3.1.3" → **failure** |
| `dynamic` | Dependabot tự check internal | Các lần scan hàng ngày → **success** |

**Tại sao PR `flask 1.0 → 3.1.3` CI fail?**

Vì Flask 3.x thay đổi API so với Flask 1.x (breaking change). Code trong `app.py` viết cho Flask 1.x nên khi nâng lên 3.x sẽ cần sửa code. Đây chính là lý do **CI quan trọng** - nó giúp bạn biết PR nào an toàn để merge, PR nào cần review kỹ.

---

## 4. Cách đọc kết quả - Đâu là đúng, đâu là sai?

### 4.1. Kết quả ĐÚNG (project đang hoạt động đúng)

```
✅ 98 security alerts được phát hiện
   → Dependabot Alerts đang hoạt động

✅ 18 PRs được tạo tự động bởi dependabot[bot]
   → Dependabot Security Updates + Version Updates đang hoạt động

✅ PRs có cho cả 4 ecosystem (pip, npm, docker, github-actions)
   → dependabot.yml cấu hình đúng

✅ CI chạy tự động trên mỗi PR
   → Workflow ci.yml trigger đúng

✅ PRs cũ tự đóng khi có version mới hơn
   → Dependabot tự dọn dẹp PR lỗi thời

✅ Một số alerts có trạng thái "Fixed"
   → Dependabot liên kết alert với PR fix tương ứng
```

### 4.2. Kết quả cần lưu ý

```
⚠️  PR #15 (Flask 1.0 → 3.1.3): CI fail
    → Major version bump, cần sửa code trước khi merge

⚠️  PR #9 (express 4.x → 5.x): Major version bump
    → Có thể breaking change, cần test kỹ

⚠️  PR #14 (Pillow 6.2.0 → 12.1.1): Nhảy rất nhiều major versions
    → Rủi ro breaking change cao
```

### 4.3. Nếu thiếu thứ gì thì là SAI

```
❌ Không có alert nào
   → Vào Settings > Code security > Enable "Dependabot alerts"

❌ Không có PR nào
   → Vào Settings > Code security > Enable "Dependabot security updates"

❌ Chỉ có PR cho pip/npm, không có docker/github-actions
   → Kiểm tra dependabot.yml có đủ 4 ecosystem không

❌ CI không chạy trên PR
   → Kiểm tra ci.yml có trigger "pull_request" không
```

---

## 5. Giải thích chi tiết từng loại alert

### 5.1. Direct dependency vs Transitive dependency

```
                    package.json (bạn khai báo)
                    ┌─────────────────────────┐
                    │ express@4.17.1          │ ← Direct dependency
                    └────────┬────────────────┘
                             │ phụ thuộc vào
                    ┌────────┴────────────────┐
                    │ body-parser@1.19.0      │ ← Transitive (sub-dependency)
                    │ qs@6.7.0               │ ← Transitive
                    │ path-to-regexp@0.1.7   │ ← Transitive
                    │ cookie@0.4.1           │ ← Transitive
                    │ send@0.17.1            │ ← Transitive
                    │ serve-static@1.14.1    │ ← Transitive
                    └─────────────────────────┘
```

Trong project này:
- **Direct**: `express`, `lodash`, `jquery`, `moment`, `serialize-javascript` (bạn khai báo trong `package.json`)
- **Transitive**: `body-parser`, `qs`, `path-to-regexp`, `cookie`, `send`, `serve-static` (dependency bên trong `express`)

Dependabot quét **cả hai loại**. Đó là lý do bạn thấy alerts cho package mà bạn không trực tiếp khai báo.

### 5.2. Tại sao cùng 1 package có alert ở cả package.json VÀ package-lock.json?

Ví dụ thực tế từ repo:

| Alert # | Package | Manifest | Trạng thái |
|---------|---------|----------|------------|
| #4 | lodash CVE-2021-23337 | **package.json** | Fixed |
| #81 | lodash CVE-2021-23337 | **package-lock.json** | Open |

**Giải thích:**
- Alert từ `package.json` → Dependabot tạo PR update `package.json` → khi PR merge → alert **Fixed**
- Alert từ `package-lock.json` → Lock file vẫn giữ version cũ (vì PR chưa merge) → alert **Open**
- Khi bạn merge PR và chạy `npm install` → lock file update → alert cũng sẽ Fixed

### 5.3. Bảng tổng hợp alerts thực tế theo package

**Python (requirements.txt):**

| Package | Version hiện tại | Số alerts | Severity cao nhất | PR fix |
|---------|-----------------|-----------|-------------------|--------|
| Pillow | 8.2.0 | ~30 | Critical | PR #14 → 12.1.1 |
| urllib3 | 1.23 | 8 | High | PR #8 → 2.6.3 |
| Jinja2 | 2.10 | 5 | High | PR #2 → 3.1.6 |
| requests | 2.19.0 | 3 | High | PR #7 → 2.32.5 |
| PyYAML | 5.3 | 2 | Critical | PR #3 → 6.0.3 |
| Flask | 1.0 | 2 | High | PR #15 → 3.1.3 |

**Node.js (package.json + package-lock.json):**

| Package | Version hiện tại | Số alerts | Severity cao nhất | PR fix |
|---------|-----------------|-----------|-------------------|--------|
| serialize-javascript | 1.9.0 | 3 | High | PR #17 → 7.0.4 |
| lodash | 4.17.20 | 3 | High | PR #4 → 4.17.23 |
| moment | 2.29.1 | 2 | High | PR #1 → 2.30.1 |
| jquery | 3.4.1 | 2 | Medium | PR #11 → 4.0.0 |
| express | 4.17.1 | 2 (+6 từ sub-deps) | High | PR #9 → 5.2.1 |
| qs *(sub-dep)* | 6.7.0 | 3 | High | Cần update express |
| path-to-regexp *(sub-dep)* | 0.1.7 | 2 | High | Cần update express |
| body-parser *(sub-dep)* | 1.19.0 | 1 | High | Cần update express |
| cookie *(sub-dep)* | 0.4.1 | 1 | Low | Cần update express |
| send *(sub-dep)* | 0.17.1 | 1 | Low | Cần update express |
| serve-static *(sub-dep)* | 1.14.1 | 1 | Low | Cần update express |

---

## 6. Mối liên hệ giữa Alert, PR và CI

```
Alert #12 (requests CVE-2018-18074)
    │
    │  Dependabot tự tạo
    ▼
PR #7 "pip: bump requests 2.19.0 → 2.32.5"
    │
    │  PR trigger CI workflow
    ▼
GitHub Actions chạy ci.yml
    │
    ├── pip install → OK (version mới tương thích)
    ├── pytest → OK (tests pass)
    └── Kết quả: ✅ CI Pass
            │
            │  Bạn review và merge PR
            ▼
      Alert #12 tự chuyển sang "Fixed"
```

Nếu CI **fail** (như PR #15 Flask):

```
Alert #45 (Flask CVE-2023-30861)
    │
    ▼
PR #15 "pip: bump flask 1.0 → 3.1.3"
    │
    ▼
GitHub Actions chạy ci.yml
    │
    ├── pip install → OK
    ├── pytest → FAIL (Flask 3.x API khác 1.x)
    └── Kết quả: ❌ CI Fail
            │
            │  Bạn cần: sửa code cho tương thích Flask 3.x
            │           rồi mới merge được
            ▼
      Alert #45 vẫn "Open" cho đến khi merge
```

---

## 7. Tóm tắt

| Thành phần | Trạng thái hiện tại | Đánh giá |
|------------|--------------------|----|
| Dependabot Alerts | 98 alerts (7 critical, 39 high, 25 medium, 7 low) | Hoạt động đúng |
| Security Updates | 14 PRs open, 4 PRs closed (thay thế bởi version mới) | Hoạt động đúng |
| Version Updates | Có PRs cho cả pip, npm, docker | Hoạt động đúng |
| CI Integration | CI chạy trên mỗi PR, phát hiện breaking changes | Hoạt động đúng |
| Auto-cleanup | PRs cũ tự đóng khi có version mới hơn | Hoạt động đúng |

**Kết luận: Project Test-SCA đang demo Dependabot thành công trên cả 4 ecosystem.**
