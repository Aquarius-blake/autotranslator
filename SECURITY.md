Security Policy
Reporting a Vulnerability
Thank you for taking the time to report a security vulnerability in the auto_translate Flutter package. We take security seriously and appreciate your efforts to improve the security of our package and the Flutter ecosystem.
How to Report a Vulnerability
Please DO NOT publicly disclose vulnerabilities until they have been addressed. Instead, report them privately:

Email: Send a detailed report to blakeind72@gmail.com (replace with your contact email)

GitHub Security Advisories: 

Go to this repository's Security tab
Create a new security advisory with:
Title: Clear, descriptive title (e.g., "XSS in AutoTranslateText widget")
Description: Detailed explanation of the vulnerability
Impact: Potential consequences and affected users
Steps to reproduce: Clear, numbered steps
Suggested fix: Your proposed solution (optional)




Private GitHub Issue: Create a private issue marked as a security vulnerability via the GitHub interface.


What to Include in Your Report
Please provide:

Description: What the vulnerability is and how it works
Steps to Reproduce: Exact steps to trigger the vulnerability
Impact: What an attacker could achieve
Environment: Flutter version, package version, OS, device type
Proof of Concept: Code sample or minimal reproducible example
Affected Versions: Which versions are vulnerable
Your Contact Info: For follow-up questions

Example Report Template
Title: [Vulnerability Type] in [Component]

Description:
[Clear explanation of the issue]

Impact:
[What could go wrong for users]

Steps to Reproduce:
1. Create a Flutter app with auto_translate ^0.1.0
2. Add the following code: [...]
3. Run on [device/OS]
4. [Trigger condition]

Environment:
- Flutter: 3.16.0
- auto_translate: 0.1.0
- OS: Android 14
- Device: Pixel 8

Proof of Concept:
```dart
[Minimal code that demonstrates the issue]

Suggested Fix:[Your proposed solution]

---

## Triage and Response Process

### Timeline
| Stage | Timeframe |
|-------|-----------|
| **Acknowledgment** | Within 3 business days |
| **Initial Assessment** | Within 7 business days |
| **Fix Development** | Within 14 business days (critical) / 30 days (moderate) |
| **Release** | Within 7 days of fix completion |
| **Disclosure** | Coordinated with reporter |

### Severity Classification

| Severity | Criteria | Response Time |
|----------|----------|---------------|
| **Critical** | Remote code execution, data exfiltration, auth bypass | 14 days |
| **High** | XSS, CSRF, sensitive data exposure | 21 days |
| **Moderate** | DoS, configuration issues | 30 days |
| **Low** | Minor information disclosure | 60 days |

---

## Supported Versions

| Version | Status | Supported Until | Notes |
|---------|--------|-----------------|-------|
| `^0.1.0` | ✅ Supported | Ongoing | Latest stable |
| `<0.1.0` | ❌ Not Supported | N/A | Initial development |

**Note**: We support the latest stable version. Upgrade immediately when new versions are released with security fixes.

---

## Scope of Support

This security policy applies to:

### ✅ In Scope
- Core `auto_translate` package code (`lib/auto_translate.dart`)
- `AutoTranslateText` widget
- `LanguageProvider` class
- Offline translation map
- Integration with `translator`, `provider`, `connectivity_plus`

### ❌ Out of Scope
- Vulnerabilities in third-party dependencies:
  - `translator: ^0.1.7` (report to [translator repo](https://github.com/jnosdam/translator))
  - `provider: ^6.0.0` (report to [provider repo](https://github.com/rrousselGit/provider))
  - `connectivity_plus: ^6.0.0` (report to [connectivity_plus repo](https://github.com/fluttercommunity/plus_plugins))
- Misconfiguration by app developers
- Best practices violations (unless they create security issues)
- Theoretical attacks without practical impact

---

## Disclosure Policy

We follow a **60-day disclosure policy**:

1. **Private Disclosure**: Vulnerability reported privately to maintainers
2. **Fix Development**: We work on a patch
3. **Release**: Security fix published
4. **Public Disclosure**: CVE assigned and advisory published after 7 days

### Coordinated Disclosure
If you need more time or have disclosure requirements, contact us to coordinate timing.

---

## Common Vulnerability Types

### In `AutoTranslateText` Widget
- **XSS**: Malicious `text` parameter injection
- **DoS**: Infinite translation loops or memory leaks
- **Privacy**: Unintended logging of sensitive text

### In `LanguageProvider`
- **Race Conditions**: Concurrent `setLanguage` calls
- **Connectivity Leaks**: Improper disposal of connectivity streams
- **Timeout Bypass**: Circumventing translation timeouts

### In Offline Translations
- **Secrets Exposure**: Sensitive data in `_offlineTranslations`
- **Path Traversal**: Malicious translation keys

---

## For Maintainers

### When You Receive a Report
1. **Acknowledge** within 3 days: "Thank you for your report. We're reviewing it."
2. **Classify** severity using the table above
3. **Create** private branch: `security/[CVE-ID]`
4. **Fix** in private, test thoroughly
5. **Release** patch version immediately
6. **Document** in CHANGELOG.md: `## SECURITY`
7. **Coordinate** public disclosure with reporter

### Security Headers in Releases
```yaml
# In pubspec.yaml for security releases
version: 0.1.1+security.1


Credits
Security researchers who report vulnerabilities will be credited in:

CHANGELOG.md security section
GitHub Security Advisories
Package documentation


Legal Notice
By reporting vulnerabilities, you agree that:

Reports are confidential until coordinated disclosure
You won't publicly disclose without coordination
Maintainers aren't liable for issues in third-party dependencies


Contact

Security Email: blakeind72@gmail.com
Primary Maintainer: Aquarius Blake
Flutter Community: Flutter Security


Last Updated: October 15, 2025
