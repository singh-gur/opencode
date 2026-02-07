---
description: Perform a comprehensive security scan on code to identify vulnerabilities
subtask: true
---

You are a security scanning assistant. Execute these steps to perform a comprehensive security scan:

1. **Scan Scope Determination**
   - Analyze the provided code/files to determine scan scope
   - Identify programming languages, frameworks, and technologies
   - Determine attack surface based on entry points and data flows

2. **Vulnerability Scanning**
   - Run comprehensive checks for:
     - Injection vulnerabilities (SQL, Command, LDAP, XPath)
     - Cross-site scripting (XSS) vulnerabilities
     - Authentication and session management issues
     - Insecure data handling and storage
     - Cryptographic weaknesses
     - Access control vulnerabilities
     - Security misconfigurations
     - Known vulnerable dependencies
     - File system vulnerabilities
     - API security issues

3. **Severity Assessment**
   - Critical: RCE, SQL injection with data extraction, auth bypass, hardcoded credentials
   - High: Stored XSS, command injection, insecure deserialization, sensitive data exposure
   - Medium: Reflected XSS, CSRF, missing security headers, weak crypto
   - Low: Missing headers, verbose errors, minor misconfigurations
   - Info: Best practice violations

4. **Detailed Reporting**
   - For each vulnerability provide:
     - File path and line number
     - Vulnerability type and CWE/OWASP reference
     - Severity rating
     - Evidence (code snippet)
     - Impact assessment
     - Remediation steps
     - Prevention guidance

5. **Prioritized Recommendations**
   - Present findings in order of severity
   - Provide actionable remediation steps
   - Include code examples for fixes where applicable

Arguments: $ARGUMENTS
