# Required GitHub Secrets

These must be added to your GitHub repo Settings > Secrets and variables > Actions for automated deployment.

| Secret Name           | Description                          | Source/Example Value                                  |
| --------------------- | ------------------------------------ | ----------------------------------------------------- |
| `GCP_PROJECT_ID`      | riderwin-flarum              | From GCP Console > Project Info                       |
| `GCP_SSH_PRIVATE_KEY` | Private SSH key for VM access        | Generate via `ssh-keygen`; add public to GCP Metadata |
| `DB_PASSWORD`         | RiderWin123!@# | User-defined strong password (e.g., auto-generate)    |

**Notes**:

- Minimal GCP-sourced: Only `GCP_PROJECT_ID` and `GCP_SSH_PRIVATE_KEY` from GCP.
- `DB_PASSWORD` is arbitrary (set once during initial Terraform apply).
- Never commit these to repo; use for CI/CD only.
