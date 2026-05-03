# alumot-nets-sticker-pack-2026

Two simple websites deployed as subfolders of marklevi.com:

- `sites/consulting/`  -> https://marklevi.com/consulting
- `sites/nets-2026/`   -> https://marklevi.com/nets-2026

Hosted on RamNode shared hosting (cPanel). Deployed via FTP using `lftp`.

## One-time setup

1. **Get FTP credentials from cPanel:**
   - Log in to https://clientarea.ramnode.com -> Manage your Shared Hosting -> Login to cPanel
   - Open **FTP Accounts** -> create one (or use the main account)
   - Note: host, username, password, port

2. **Create your `.env` file:**
   ```
   cp .env.example .env
   ```
   Then open `.env` and paste in your real FTP credentials.

3. **Install lftp:**
   - Mac:   `brew install lftp`
   - Linux: `sudo apt install lftp`

## Deploying

```
./scripts/deploy.sh consulting     # push the consulting site
./scripts/deploy.sh nets-2026      # push the nets-2026 site
./scripts/deploy.sh all            # push both
```

Or just tell Claude Code: *"deploy consulting"* / *"deploy both"*.

Only changed files are uploaded.
