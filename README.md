# Test-SCA - Dependabot Demo Project

A proof-of-concept project that intentionally uses outdated and vulnerable dependencies to demonstrate three key Dependabot features:

1. **Dependabot Alerts** - Detects known vulnerabilities (CVEs) in dependencies
2. **Dependabot Security Updates** - Automatically creates PRs to fix vulnerable dependencies
3. **Dependabot Version Updates** - Automatically creates PRs to keep dependencies up to date

> **Warning:** This project contains intentionally vulnerable dependencies. Do NOT use in production.

## Vulnerable Dependencies

### Python (`requirements.txt`)

| Package | Version | CVE | Vulnerability |
|---------|---------|-----|---------------|
| requests | 2.19.0 | CVE-2018-18074 | Authorization header leak on redirect |
| PyYAML | 5.3 | CVE-2020-1747 | Arbitrary code execution via FullLoader |
| Flask | 1.0 | CVE-2019-1010083 | Denial of Service |
| Jinja2 | 2.10 | CVE-2019-10906 | Sandbox escape |
| Pillow | 6.2.0 | CVE-2021-23437 | Buffer overflow in image processing |
| urllib3 | 1.24.1 | CVE-2019-11324 | Certificate verification bypass |

### Node.js (`package.json`)

| Package | Version | CVE | Vulnerability |
|---------|---------|-----|---------------|
| lodash | 4.17.20 | CVE-2021-23337 | Prototype Pollution |
| moment | 2.29.1 | CVE-2022-31129 | ReDoS |
| jquery | 3.4.1 | CVE-2020-11022 | XSS |
| serialize-javascript | 1.9.0 | CVE-2020-7660 | Code injection |
| express | 4.17.1 | - | Outdated (triggers version update) |

### Docker (`Dockerfile`)

| Image | Tag | Issue |
|-------|-----|-------|
| python | 3.8-slim | Outdated base image |

## How to Demo

### Step 1: Push to GitHub

```bash
git add -A
git commit -m "Add vulnerable dependencies for Dependabot demo"
git push origin main
```

### Step 2: Enable Dependabot

1. Go to your repository on GitHub
2. Navigate to **Settings** > **Code security and analysis**
3. Enable the following:
   - **Dependency graph** (usually enabled by default)
   - **Dependabot alerts** - Click "Enable"
   - **Dependabot security updates** - Click "Enable"
4. Dependabot version updates are configured via `.github/dependabot.yml` (already included)

### Step 3: Observe Results

After enabling, Dependabot will:

- **Alerts tab** (`Security` > `Dependabot alerts`): Show CVE alerts for all vulnerable packages
- **Pull Requests tab**: Automatically create PRs to fix security vulnerabilities
- **Pull Requests tab**: Create PRs to update outdated dependencies (based on `dependabot.yml` schedule)

### Expected Outcome

- ~10+ security alerts (from both Python and Node.js vulnerabilities)
- Multiple auto-generated PRs for security fixes
- Version update PRs for outdated (but not necessarily vulnerable) packages
- Docker base image update PR

## Project Structure

```
Test-SCA/
├── .github/
│   └── dependabot.yml      # Dependabot configuration (4 ecosystems)
├── app.py                   # Flask web app using vulnerable deps
├── requirements.txt         # Python deps with known CVEs
├── package.json             # Node.js deps with known CVEs
├── Dockerfile               # Outdated Python base image
├── test_hello.py            # Unit tests
├── test_math.py             # Unit tests
└── README.md                # This file
```

## Dependabot Configuration

The `.github/dependabot.yml` file monitors 4 package ecosystems:

- **pip** - Python packages from `requirements.txt`
- **npm** - Node.js packages from `package.json`
- **docker** - Docker base images from `Dockerfile`
- **github-actions** - GitHub Actions workflow versions

All are configured with **daily** checks for faster demo results.
