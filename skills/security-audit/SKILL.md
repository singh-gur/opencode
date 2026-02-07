---
name: security-audit
description: Security expertise for vulnerability scanning, OWASP Top 10, CWE references, secure coding patterns, and security remediation across all languages and frameworks
---

## Security Audit Expertise

Load this skill when performing security reviews, vulnerability scanning, or implementing secure coding patterns.

## Core Principles

- **Defense in Depth**: Layered security controls, assume any component may be compromised
- **Zero Trust**: Verify everything, trust nothing - including internal code and dependencies
- **Shift Left**: Identify and fix vulnerabilities early in the development lifecycle
- **Least Privilege**: Applications operate with minimum necessary permissions
- **Secure by Default**: Default configurations should be the most secure option

## Vulnerability Categories

### 1. Injection (CWE-89, CWE-78, CWE-90)
- **SQL Injection**: Unsafe string concatenation in queries, ORM misuse, dynamic query construction
- **Command Injection**: system()/exec() with unsanitized input, shell metacharacters, eval()
- **LDAP/XPath Injection**: Unsanitized query construction from user input

### 2. Cross-Site Scripting - XSS (CWE-79)
- **Reflected**: Unsanitized user input in HTTP responses
- **Stored**: Database storage without output encoding, file uploads allowing script execution
- **DOM-based**: Dangerous sinks (innerHTML, document.write), unsafe URL parsing, postMessage without origin validation

### 3. Authentication & Session Management (CWE-287)
- Hardcoded credentials or API keys in source code
- Missing or weak password hashing (MD5, SHA1 for passwords)
- Session fixation, overly long timeouts, predictable tokens
- Missing MFA for sensitive operations

### 4. Insecure Data Handling (CWE-200, CWE-310)
- Logging of sensitive information (passwords, PII, credit cards)
- Weak crypto algorithms (DES, 3DES, RC4, ECB mode)
- Missing TLS enforcement, weak TLS versions (1.0, 1.1)
- Insufficient key sizes, hardcoded crypto keys
- Predictable random number generation (Math.random, rand())

### 5. Access Control (CWE-639, CWE-862)
- Missing authorization checks, predictable resource identifiers (IDOR)
- Horizontal and vertical privilege escalation
- Admin endpoints without authentication
- Missing RBAC checks on API endpoints

### 6. Security Misconfiguration (CWE-16)
- Missing security headers (CSP, X-Frame-Options, HSTS, X-Content-Type-Options)
- Debug/error modes enabled in production
- CORS misconfiguration (wildcard origins)
- Default credentials, verbose error messages exposing stack traces
- Missing rate limiting

### 7. Vulnerable Dependencies
- Outdated packages with known CVEs
- Deprecated or abandoned libraries
- License compliance issues

### 8. File System Vulnerabilities (CWE-22, CWE-98)
- Path traversal with user-controlled paths
- Missing path normalization and validation
- Unrestricted file upload, symlink following
- Remote/local file inclusion

### 9. API Security
- **REST**: Missing rate limiting, mass assignment, improper error handling, broken function-level authz
- **GraphQL**: Excessive data exposure, missing query depth limiting, introspection in production

### 10. Business Logic
- Price manipulation, integer overflow in financial calculations
- Race conditions in critical operations
- Workflow bypass, insufficient business rule validation

## Severity Ratings

| Level | Examples |
|-------|---------|
| **Critical** | RCE, SQL injection with data extraction, auth bypass, hardcoded credentials, path traversal with read/write |
| **High** | Stored XSS with session theft, command injection, insecure deserialization, sensitive data exposure |
| **Medium** | Reflected XSS, CSRF, missing security headers, weak crypto, info disclosure via errors |
| **Low** | Missing HTTP headers, verbose errors, info leakage in headers, minor misconfigurations |
| **Info** | Best practice violations, code quality issues with security implications |

## Scanning Methodology

1. **Initial Assessment**: Identify languages, frameworks, entry points, attack surface, trust boundaries
2. **Static Analysis**: Scan for vulnerability patterns, check configs, review coding practices, audit dependencies
3. **Dynamic Analysis**: Test input validation, verify security controls are enforced at runtime
4. **Reporting**: Prioritize by severity and exploitability, provide CWE/OWASP references, remediation steps

## Remediation Framework

For each finding, provide:
1. **Description**: Clear explanation of the vulnerability
2. **Impact**: Potential consequences if exploited
3. **Evidence**: Code snippets with `file_path:line_number` references
4. **Remediation**: Specific steps to fix the issue
5. **Prevention**: How to prevent similar issues in the future
6. **References**: CWE, OWASP, and security advisory links

## Language-Specific Patterns

- **Python**: pickle, yaml.load, SQLAlchemy misuse, template injection, subprocess with shell=True
- **JavaScript/Node.js**: Prototype pollution, command injection, regex DoS, eval(), unvalidated redirects
- **Java**: Unsafe deserialization, XXE, EL injection, JNDI injection
- **Go**: SQL injection in database/sql, command execution, path traversal
- **Ruby**: YAML.load, ERB injection, unsafe deserialization, mass assignment
- **PHP**: eval(), include vulnerabilities, unserialize, SQL injection

## Framework-Specific Checks

- **React/Vue/Angular**: DOM XSS through dangerous sinks, SSR vulnerabilities
- **Express/Django/Flask**: Missing security middleware, unsafe routing, CSRF bypass
- **Spring**: EL injection, deserialization, authorization bypass
- **Rails**: Mass assignment, unsafe deserialization, SQL injection

## When to Use This Skill

- Performing security audits or code reviews
- Implementing authentication, authorization, or crypto
- Reviewing dependencies for vulnerabilities
- Hardening application or infrastructure configuration
- Responding to security incidents or CVE disclosures
