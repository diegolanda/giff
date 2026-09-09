# gififier

LICEcap for the command line. `gififier` records a window, a screen region, or the whole
screen on macOS, encodes the result as an animated GIF, and can attach it to a GitHub
pull request. It is meant for coding agents that need to show visual proof of a
frontend change.

## Requirements

- macOS (uses the built-in `screencapture`)
- `ffmpeg` (`brew install ffmpeg`)
- Xcode Command Line Tools for `swiftc` (`xcode-select --install`). It is used once to
  build a small window-lookup helper.
- `gh` (`brew install gh`, then `gh auth login`) for `gififier attach`
- Screen Recording permission, see below

## Install

```sh
git clone <this repo> ~/GitHub/gififier
~/GitHub/gififier/install.sh            # links into /usr/local/bin or ~/.local/bin
gififier doctor
```

## Uninstall

```sh
~/GitHub/gififier/uninstall.sh            # removes the symlink
~/GitHub/gififier/uninstall.sh --purge    # also removes ~/.cache/gififier
```

The uninstaller stops a running recording first. Pass the install directory as an
argument if you installed somewhere other than `/usr/local/bin` or `~/.local/bin`.
The `gififier-assets` branches in your repositories are not touched.

## Screen Recording permission

macOS only lets applications with Screen Recording permission capture the screen.
The permission belongs to the application that hosts the shell, for example
Terminal.app, iTerm, VS Code, or an agent runner.

`gififier` tries two routes:

1. Direct. The host application has the permission. This is the fastest route.
2. Through Terminal.app. If the host lacks the permission, the capture runs inside a
   minimized Terminal.app window, because Terminal usually has the permission already.
   This adds about one second per recording and requires that the host is allowed to
   control Terminal.app (System Settings > Privacy & Security > Automation).

`gififier doctor` reports which route is available and names the host application.
To grant the permission, open System Settings > Privacy & Security > Screen & System
Audio Recording, enable the application, and restart it. The route is cached for ten
minutes. Run `doctor` after changing permissions.

Window titles are only visible through a route with the permission. If no route has
it, `gififier windows` still lists app names and ids, with empty titles.

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
has no shared history with your source branches.

The printed image URL renders inside GitHub for everyone who can see the repository.
For a private repository the URL does not work with `curl` or an API token. Use the
contents API (`gh api repos/OWNER/REPO/contents/PATH?ref=gififier-assets`) to download
the file from a script.

Convert an existing recording:

```sh
gififier convert clip.mov -o clip.gif --width 800 --fps 12
```

Run `gififier --help` for every option.

## Output defaults

| Setting | Default |
| --- | --- |
| Output path | `~/.cache/gififier/out/gififier-<timestamp>.gif` (`-o` or `GIFIFIER_OUT`) |
| Duration (`record`) | 5 seconds |
| Frame rate | 10 fps (`GIFIFIER_FPS`) |
| Size | Same as the on-screen point size. Retina recordings are halved. `--scale 1` keeps full pixels. |
| Cursor | Captured. `--no-cursor` hides it, `--clicks` highlights clicks. |
| Window shadow | Not captured |
| Asset branch | `gififier-assets` (`GIFIFIER_ASSET_BRANCH`) |

`gififier` prints the output path on stdout and everything else on stderr, so a script
can capture the path with `out=$(gififier record ...)`.

## Agent workflow

`SKILL.md` describes the workflow for coding agents. Copy or link it into your agent's
skill directory, for example `~/.claude/skills/gififier/SKILL.md`.
