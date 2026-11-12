# Archived Docker images

Retired PHP image definitions and their former GitHub Actions workflows.

| Path | Former workflow |
|------|-----------------|
| `php7.4-apache/` | `workflows/php7.4-apache.yml` |
| `php8.0-apache/` | `workflows/php8.0-apache.yml` |
| `php8.1-apache/` | `workflows/php8.1-apache.yml` |
| `php8.1-cli/` | `workflows/php8.1-cli.yml` |

Workflows under `archive/workflows/` are **not** loaded by GitHub Actions (only `.github/workflows/` is). To rebuild manually, restore a workflow to `.github/workflows/` or run `docker build` against the archived context.
