# Global notes for agents

## Google accounts (Gmail, Drive, Docs, Sheets, Calendar)

Use the `gws` CLI through the `gwsa` wrapper — never bare `gws` for account-specific work. Accounts are defined as per-machine profiles: run `gwsa list` to see them, and read `profiles.local.csv` inside the `gws-multi-account` skill (linked in `~/.claude/skills/`) for the profile → email mapping, including send-as aliases. Load that skill for commands, login scopes, and troubleshooting.

If `gwsa` or the skill is missing on this machine, set them up from <https://github.com/hervenivon/skills> (`skills/gws-multi-account/scripts/bootstrap.sh`), then restore credentials by copying `~/.config/gws-accounts/` from an authenticated machine.
