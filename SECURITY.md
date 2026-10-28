# Security Policy

## Supported versions

| Version | Supported |
| --- | --- |
| 1.x | Yes |

## Scope

Lidless asks you to install a sudoers rule that lets your user run exactly two commands as root without a password:

```text
/usr/bin/pmset disablesleep 0
/usr/bin/pmset disablesleep 1
```

Anything that could widen that privilege is in scope. Examples include a way to make Lidless run other commands as root, or a flaw in how `make sudoers` generates or installs the rule.

## Reporting a vulnerability

Do not open a public issue. Report the vulnerability privately through [GitHub security advisories](https://github.com/iamsaad640/lidless/security/advisories/new).

Include a description of the issue, the steps to reproduce it and the potential impact. Reports are reviewed promptly, and you will be kept informed until a fix is released.
