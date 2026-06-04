# Security Policy

## Supported Scope

This repository is a public reference architecture and demo model. It is not a validated GxP system and is not intended for regulated production use as-is.

Security reports are welcome for:

- exposed secrets or credentials beyond documented local demo passwords;
- unsafe defaults that could mislead users deploying beyond localhost;
- dependency vulnerabilities in the Laravel agent;
- Cypher or shell script behavior that could cause unintended data loss outside the documented demo refresh flow;
- documentation that could encourage unsafe regulated use.

## Reporting A Vulnerability

Please report security concerns privately to NOSWAD CONSULTING LTD through the repository owner's preferred GitHub security reporting channel if enabled, or by contacting the maintainer directly.

Do not open a public issue containing exploit details, secrets, or sensitive data.

Include:

- affected file or component;
- steps to reproduce;
- impact;
- suggested mitigation, if known.

## Demo Credentials

The repository includes documented local demo credentials for Neo4j and the constrained agent account. These are intentionally included for local demonstration only.

Do not use the demo passwords in production, shared environments, client systems, or internet-exposed deployments.

## Production Use

Any production or regulated use would require a separate security design, including at minimum:

- secret management;
- network isolation;
- least-privilege access controls;
- Neo4j Enterprise RBAC or equivalent controls where required;
- audit logging;
- backup and recovery controls;
- SDLC and change control;
- GxP validation where applicable.
