# Security Policy

## Supported Versions

We actively maintain and provide security updates for the following versions of `smart_refresher`:

| Version | Supported          |
| ------- | ------------------ |
| 1.1.x   | ✅ Yes             |
| 1.0.x   | ❌ No              |
| < 1.0.0 | ❌ No              |

## Reporting a Vulnerability

**Please do not open a public GitHub issue for security vulnerabilities.**

We take the security of this project seriously. If you believe you have found a security vulnerability, please report it privately by emailing the maintainers at [appatil595@gmail.com](mailto:appatil595@gmail.com).

### Our Process

1. **Acknowledgment:** You will receive an acknowledgment of your report within **48 hours**.
2. **Investigation:** We will investigate the issue and may contact you for further details.
3. **Response SLA:** We aim to provide a detailed response and a proposed fix/mitigation plan within **7 business days**.
4. **CVE Assignment:** If the vulnerability is confirmed, we will coordinate with you to assign a CVE identifier and determine a public disclosure date.
5. **Disclosure:** Once a fix is released, we will publish a security advisory.

## Secret Scanning

This repository uses GitHub's native secret scanning and local pre-commit hooks to prevent the accidental commitment of sensitive credentials (API keys, tokens, etc.).

## Responsible Disclosure

We appreciate the community's help in keeping `smart_refresher` secure. We ask that you give us a reasonable amount of time to resolve the issue before any public disclosure.
