# whoisd

A recursive WHOIS server, it gets the data from whomever owns it.

Made with https://github.com/likexian/whois. Whatever they support, we support.

Supported queries:

- domain
- IPv6
- IPv4
- ASN

## Installation

Binaries are provided for a wide range of systems in GitLab and GitHub releases.

Docker images are available at
https://gitlab.com/lama-corp/infra/tools/whoisd/container_registry.

## Configuring

Available environment variables:

- `WHOISD_LISTEN`: defaults to `:43`
- `WHOISD_LOG_LEVEL`: defaults to `warn`
