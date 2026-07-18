# Claude Usage

Sleek macOS menu bar app that shows your Claude usage limits in real-time.

- Menu bar shows your current session usage %
- Dropdown with progress bars for session, weekly, and per-model limits
- Live reset countdowns and extra usage credits
- Auto-refreshes every 5 minutes, and on open

## How it works

Reads your Claude Code OAuth token from the macOS Keychain (`Claude Code-credentials`) and fetches usage from Anthropic's `api.anthropic.com/api/oauth/usage` endpoint. No data leaves your machine.

## Requirements

- macOS 14+
- [Claude Code](https://claude.com/claude-code) signed in with a Claude subscription

## Install

```sh
make install   # builds and copies to /Applications
```

Or just run it:

```sh
make run
```

If macOS prompts for keychain access on first launch, click **Always Allow**.

## License

[MIT](LICENSE)
