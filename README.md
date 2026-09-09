# gififier

LICEcap for the command line. `gififier` records a window, a screen region, or the whole
screen on macOS, encodes the result as an animated GIF, and can attach it to a GitHub
pull request. It is meant for coding agents that need to show visual proof of a
frontend change.

## Requirements

- macOS (uses the built-in `screencapture`)
- `ffmpeg` (`brew install ffmpeg`)
- Xcode Command Line Tools for `swiftc` (`xcode-select --install`), used once to build a
  small window-lookup helper
- `gh` (`brew install gh`, then `gh auth login`) for `gififier attach`
- Screen Recording permission for the application that runs the terminal

## Install

```sh
git clone <this repo> ~/GitHub/gififier
~/GitHub/gififier/install.sh            # links into /usr/local/bin
gififier doctor
```

`doctor` names the application that needs Screen Recording permission. Grant it under
System Settings > Privacy & Security > Screen & System Audio Recording, then restart that
application. Without the permission every capture fails.

## Usage

Record the Chrome window for 8 seconds:

```sh
gififier record -w "Google Chrome" -d 8 -o proof.gif
```

Record while a script drives the UI:

```sh
gififier start -w Chrome
# ...click through the feature...
gififier stop -o proof.gif
```

Record a region or a specific window id:

```sh
gififier windows                          # list ids, apps, titles, bounds
gififier record -i 8836 -d 5
gififier record -r 0,80,1200,800 -d 5
```

Attach the GIF to the pull request of the current branch:

```sh
gififier attach proof.gif --message "New modal animation"
```

`attach` uploads the file to an orphan branch named `gififier-assets` in the same
repository and posts a comment with the image. Use `--body` to append the image to the
PR description instead, or `--no-comment` to only print the image URL. The asset branch
never touches your source history.

Convert an existing recording:

```sh
gififier convert clip.mov -o clip.gif --width 800 --fps 12
```

Run `gififier --help` for every option.

## Output defaults

| Setting | Default |
| --- | --- |
| Duration (`record`) | 5 seconds |
| Frame rate | 10 fps (`GIFIFIER_FPS`) |
| Size | Retina recordings are halved, so the GIF matches the on-screen point size |
| Cursor | captured (`--no-cursor` to hide, `--clicks` to highlight clicks) |
| Asset branch | `gififier-assets` (`GIFIFIER_ASSET_BRANCH`) |

## Agent workflow

`SKILL.md` describes the workflow for coding agents. Copy or link it into your agent's
skill directory, for example `~/.claude/skills/gififier/SKILL.md`.
