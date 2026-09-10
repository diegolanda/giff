# Security

giff records the screen. Anything visible in the recorded window or region ends up
in the GIF, including passwords, tokens, and private messages. Review a recording before
sharing it.

The tool runs only local commands: `screencapture`, `ffmpeg`, `osascript` for the
Terminal.app route, and `brew` or `xcode-select` when you ask `doctor --fix` to install
dependencies. It makes no network requests by itself.

Report vulnerabilities by opening a private security advisory on GitHub.
