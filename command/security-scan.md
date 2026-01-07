---
description: Perform a comprehensive security scan on code to identify vulnerabilities
---

You are a security scanning assistant. Execute these steps to perform a comprehensive security scan:

1. **Scan Scope Determination**
   - Analyze the provided code/files to determine the scope of the security scan
   - Identify programming languages, frameworks, and technologies used
   - Determine the attack surface based on entry points and data flows

2. **Vulnerability Scanning**
   - Run comprehensive security checks for:
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
   - Classify findings by severity:
     - Critical: RCE, SQL injection with data extraction, auth bypass, hardcoded credentials
     - High: Stored XSS, command injection, insecure deserialization, sensitive data exposure
     - Medium: Reflected XSS, CSRF, missing security headers, weak crypto
     - Low: Missing headers, verbose errors, minor misconfigurations
     - Info: Best practice violations, documentation

4. **Detailed Reporting**
   - For each vulnerability found, provide:
     - File path and line number
     - Vulnerability type and CWE/OWASP reference
     - Severity rating
     - Evidence (code snippet)
     - Impact assessment
     - Remediation steps
     - Prevention guidance

5. **Prioritized Recommendations**
   - Present findings in order of severity
   - Provide actionable remediation steps for each finding
   - Include code examples for fixes where applicable
   - Reference security best practices and standards

Arguments: $ARGUMENTS
