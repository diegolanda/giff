# giff

LICEcap for the command line. `giff` records a window, a screen region, or a
display on macOS and encodes the result as an animated GIF. It prints the output path
and stops there. What happens to the file, for example posting it on a pull request,
is up to the caller.

It is built for coding agents that need to show visual proof of a frontend change, and
it ships an agent skill for Claude Code, Codex, Cursor, Copilot, and `AGENTS.md`.

```sh
id=$(giff find "localhost:3000")
giff start -i "$id"
# drive the UI
gif=$(giff stop)
```

## Install

Homebrew:

```sh
brew install diegolanda/tap/giff
```

One line, without Homebrew for the tool itself (ffmpeg still comes from Homebrew):

```sh
curl -fsSL https://raw.githubusercontent.com/diegolanda/giff/main/install.sh | bash
```

From a checkout:

```sh
git clone https://github.com/diegolanda/giff.git
cd giff && ./install.sh
```

The installer script ends with `giff doctor --fix`, which installs ffmpeg through
Homebrew, starts the Xcode Command Line Tools installer if `swiftc` is missing, and
asks macOS for the Screen Recording permission. Pass `--no-fix` to only report. After a
Homebrew install, run `giff doctor --fix` yourself. See the permission section below.

Installer options work on the curl route too: `curl ... | bash -s -- --skill claude`.

Uninstall with `./uninstall.sh` from the checkout (`~/.giff/uninstall.sh` for the
curl route). Add `--purge` to remove `~/.cache/giff`. Copied or generated skill
files stay in place.

## Requirements

- macOS. The tool uses the built-in `screencapture`.
- `ffmpeg`, installed by `doctor --fix` or `brew install ffmpeg`.
- Xcode Command Line Tools, for a one-time compile of a small Swift helper that lists
  windows and displays. Homebrew installs ship the helper prebuilt.
- Screen Recording permission for the application that hosts the shell.

## Screen Recording permission

macOS only lets applications with Screen Recording permission capture the screen. The
permission belongs to the application that hosts the shell, for example Terminal.app,
iTerm, VS Code, or an agent runner. No tool can grant it to itself.

`giff` tries two routes:

1. Direct. The host application has the permission. This is the fastest route.
2. Through Terminal.app. If the host lacks the permission, the capture runs inside a
   minimized Terminal.app window, because Terminal usually has the permission already.
   This adds one to two seconds per recording and requires that the host is allowed to
   control Terminal.app (System Settings > Privacy & Security > Automation).

`giff doctor` reports which route is available and names the host application.
`giff doctor --fix` asks macOS to show the permission dialog for that application
and opens the settings pane. Enable the application there and restart it. The route is
cached for ten minutes per host application. `doctor` clears the cache.

## Usage

```sh
giff record -w "Google Chrome" -d 8 -o proof.gif    # fixed length
giff start -i 8836 && ... && giff stop -o proof.gif
giff record -r 0,80,1200,800 -d 5                   # region: x,y,w,h in points
giff record --display 2 -d 5                        # another display
giff convert clip.mov -o clip.gif --width 800 --fps 12
```

Find what to record:

```sh
giff windows            # id, app, title, bounds for every on-screen window
giff windows --json
giff find "localhost:3000"          # prints the id that -w would pick
giff find "Google Chrome" --json
giff screens            # displays with bounds and scale
```

`-w` and `find` match app names first, then window titles, case-insensitively, and pick
the first window in front-to-back order. With several windows of the same app, use the
id.

Run `giff --help` for every option.

## Output

| Setting | Default |
| --- | --- |
| Output path | `~/.cache/giff/out/giff-<timestamp>.gif` (`-o` or `GIFF_OUT`) |
| Duration (`record`) | 5 seconds |
| Frame rate | 10 fps (`--fps`, `GIFF_FPS`) |
| Size | The on-screen point size. Retina recordings are halved. `--scale 1` keeps full pixels, `--width` sets a width. |
| Cursor | Captured. `--no-cursor` hides it, `--clicks` highlights clicks. |
| Window shadow | Not captured |
| Extras | `--mp4` writes an mp4 next to the GIF, `--keep-video` keeps the source `.mov` |

Recording commands print exactly one path on stdout. Everything else goes to stderr.
Errors exit 1 with one line on stderr.

## Agent skill

`skills/giff/SKILL.md` is the workflow for coding agents, in the Agent Skills format
(a Markdown file with `name` and `description` frontmatter). It is the single source for
every harness. `install-skill.sh` places it where each harness looks:

```sh
./install-skill.sh claude                     # ~/.claude/skills/giff
./install-skill.sh codex                      # ~/.codex/skills/giff
./install-skill.sh cursor  --project ~/app    # ~/app/.cursor/rules/giff.mdc
./install-skill.sh copilot --project ~/app    # ~/app/.github/instructions/giff.instructions.md
./install-skill.sh agents  --project ~/app    # a marked section in ~/app/AGENTS.md
./install-skill.sh all     --project ~/app    # everything above, project-scoped
```

Claude Code and Codex read `SKILL.md` directly and get a symlink to the checkout, so
updates apply without reinstalling. Pass `--copy` for a copy instead. Cursor and Copilot
get a generated file with the same body and their own frontmatter. The `AGENTS.md`
section is wrapped in markers and replaced on reinstall.

`install.sh --skill claude` does the tool and the skill in one step. The installer never
replaces a skill directory it did not create unless you pass `--force`.

Homebrew installs keep these scripts under `$(brew --prefix)/opt/giff/libexec`.

## Posting a GIF on a pull request

This is outside the tool on purpose. `examples/attach-to-pr.sh` shows one verified way:
it uploads the file to an orphan `giff-assets` branch through the GitHub API and
comments on the PR with the image, so binaries stay out of the source history. Use it
as is, or adapt it. The image URL renders inside GitHub. For a private repository the
URL does not work with `curl` or an API token.

## Development

- `bin/giff` runs on the stock macOS `/bin/bash` 3.2. CI checks syntax, shellcheck,
  the Swift helper build, a conversion, and every skill installer on a macOS runner.
- Captures cannot run in CI. Test them from the host application you care about, since
  the permission is per application.
- See `CONTRIBUTING.md`.

## License

MIT. See `LICENSE`.
