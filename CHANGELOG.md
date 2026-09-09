# Changelog

## 0.3.0

- Renamed from gififier to giff. Command, cache directory, environment variables
  (`GIFF_*`), skill name, and repository all follow. An existing `~/.cache/gififier`
  is moved to `~/.cache/giff` on first run.

## 0.2.0

- Record a window, region, display, or the main screen to GIF, with optional mp4.
- Background `start`/`stop` and `convert`.
- `find`, `windows --json`, `screens` for scripted targeting.
- Terminal.app fallback when the host lacks Screen Recording permission.
- `doctor --fix` installs dependencies and requests the permission.
- Agent skill in `skills/giff` with installers for Claude Code, Codex, Cursor, Copilot, and AGENTS.md.
- PR upload moved out of the tool into `examples/attach-to-pr.sh`.
