# Test day 2026

# Security Testing in Practice

Security testing belongs in everyday software engineering. Developers shape security through architecture, code, and dependency choices. Testers challenge assumptions and verify that systems remain secure when users provide unexpected inputs or attempt unauthorized actions.

This material covers application security testing, AI-assisted development, software supply-chain risks, and how engineering evidence can support product-security requirements.

## Testing beyond the happy path

Functional testing asks whether an intended user can complete an intended task. Security testing also asks whether someone can access data or perform actions they should not be allowed to. Define both what the system must allow and what it must reject.

For example, viewing your own shopping basket tests functionality. Confirming that you cannot view another user’s basket tests access control.

Abuse stories help teams describe behavior they need to prevent, especially around permissions, sensitive data, and important operations. These stories can guide security requirements and test cases.

## Attack surface

The attack surface includes every place where external actors or untrusted data can interact with a system, including user interfaces, APIs, network services, files, databases, and external integrations. Authentication, authorization, sessions, and key handling also deserve explicit attention.

Reducing unnecessary exposure can remove entire categories of risk. Review whether the system needs each exposed service, endpoint, dependency, and privilege. Repeat this review as the product evolves.

## Common weaknesses

- **Injection:** Untrusted input becomes part of an executable query or command.
- **Authentication and access-control failures:** Missing identity or permission checks allow unauthorized access.
- **Sensitive-data exposure:** Weak encryption, poor key management, or insecure storage leaves information insufficiently protected.
- **Security misconfiguration:** Default credentials, unnecessary ports, debug tools, and detailed error messages expose the system.
- **Cross-site scripting (XSS):** Unsafe content handling allows untrusted scripts to execute in a browser.
- **Vulnerable dependencies:** Third-party components introduce security risks that require ongoing monitoring.

Password storage also matters. Use a slow, salted password-hashing algorithm such as Argon2, bcrypt, or scrypt rather than unsalted MD5.

## Complementary testing approaches

| Approach | Purpose |
| --- | --- |
| Static Application Security Testing (SAST) | Analyze source code without running the application to identify potential vulnerabilities early. |
| Dynamic Application Security Testing (DAST) | Test a running application through its exposed interfaces. |
| Software Composition Analysis (SCA) | Identify third-party components and assess known vulnerabilities and license risks. |
| Manual and exploratory testing | Investigate business-logic flaws and interactions that automated tools may miss. |

Zed Attack Proxy (ZAP) supports web-application testing through passive and active scanning, crawling, API testing, and an intercepting proxy. It complements source-code and dependency analysis.

### Training exercises

The presentation uses OWASP Juice Shop to demonstrate SQL injection and broken access control. A central lesson is that APIs must check whether the authenticated user has permission to access the requested resource. Client-side restrictions alone cannot enforce authorization.

Run exercises only in an isolated training environment or against systems you have explicit permission to test.

## AI-assisted development

AI-generated code and automated fixes can appear correct while introducing vulnerabilities or changing intended behavior. Passing the tests visible to an agent does not establish that a patch is safe.

Treat AI-generated patches like third-party code: require human review, check behavior against requirements, run regression and integration tests, and apply relevant security scans. Pay particular attention to changes involving authorization, input validation, dependencies, and error handling.

## Dependency and supply-chain security

Supply-chain risks affect every software ecosystem. Common threats include vulnerable components, malicious updates, compromised maintainers, typosquatting, and dependency confusion.

Recommended practices include:

- Minimize external dependencies and prefer suitable built-in functionality.
- Pin reviewed versions, commit lockfiles, and use deterministic installation in CI.
- Control installation scripts and avoid adopting newly published packages without review.
- Use approved repositories and scan dependencies continuously.

A **Software Bill of Materials (SBOM)** records the components included in a product, including direct and indirect dependencies. It supports vulnerability analysis and traceability, but does not by itself prevent malicious code from running during installation.

The presentation describes a workflow using JFrog to generate a CycloneDX SBOM and Dependency-Track to analyze component vulnerabilities and risk.

## Requirements, verification, and compliance evidence

**OWASP ASVS** provides application-security requirements. **OWASP WSTG** provides guidance for testing their implementation. Together, they help connect security requirements to verification evidence.

The broader frameworks address different concerns:

| Framework | Focus |
| --- | --- |
| IEC 62443 | Industrial system security, secure development processes, and component security requirements. |
| IACS UR E27 | Cyber resilience of in-scope onboard systems and equipment. |
| EU Cyber Resilience Act (CRA) | Product cybersecurity obligations, including vulnerability handling, updates, and reporting. |

The presentation recommends considering ASVS Level 2 as an application-security baseline, using WSTG for verification, and maintaining a threat model, SBOM, vulnerability-handling process, and secure-update process. Map relevant requirements and test evidence to the standards that apply to the product.

ASVS and WSTG can support compliance work, but using them does not automatically establish certification or type approval.

## Key takeaway

Security requires ongoing collaboration across development and testing. Start with security checks in ordinary test plans, integrate automated scanning into the build pipeline, and improve coverage over time. Treat security as a core quality attribute alongside functionality and performance.


## Referances

* https://owasp.org/projects/juice-shop
* https://cheatsheetseries.owasp.org/
* https://owasp.org/projects
* https://owasp.org/projects/asvs
