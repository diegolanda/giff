# gififier

LICEcap for the command line. `gififier` records a window, a screen region, or the whole
screen on macOS and encodes the result as an animated GIF. It prints the output path
and stops there. What happens to the file, for example posting it on a pull request,
is up to the caller. It is meant for coding agents that need to show visual proof of a
frontend change.

## Requirements

- macOS (uses the built-in `screencapture`)
- `ffmpeg` (`brew install ffmpeg`)
- Xcode Command Line Tools for `swiftc` (`xcode-select --install`). It is used once to
  build a small window-lookup helper.
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
Asset branches created by `examples/attach-to-pr.sh` are not touched.

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
`gififier doctor --fix` installs ffmpeg with Homebrew, starts the Xcode Command Line
Tools installer, and asks macOS to show the Screen Recording dialog for the host
application. No tool can grant the permission by itself. You still enable the switch
and restart the application.
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

`-w` matches app names first, then window titles, and picks the first window in
front-to-back order. With several windows of the same app, use `-i <id>` from
`gififier windows` instead.

Record while a script drives the UI:

```sh
gififier start -w Chrome
# ...click through the feature...
gififier stop -o proof.gif
```

Record a region, a specific window id, or another display:

```sh
gififier windows                          # list ids, apps, titles, bounds
gififier record -i 8836 -d 5
gififier record -r 0,80,1200,800 -d 5     # x,y,w,h in points, global coordinates
gififier screens                          # list displays with bounds and scale
gififier record --display 2 -d 5
```

Region coordinates are global, so a region on a second display uses that display's
bounds from `gififier screens`.

Find a window id for a script:

```sh
id=$(gififier find "localhost:3000")     # app name or title, same rules as -w
gififier find "localhost:3000" --json
gififier windows --json
```

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

`gififier` prints the output path on stdout and everything else on stderr, so a script
can capture the path with `out=$(gififier record ...)`.

## Agent workflow

`SKILL.md` describes the workflow for coding agents. Copy or link it into your agent's
skill directory, for example `~/.claude/skills/gififier/SKILL.md`.

## Posting a GIF on a pull request

This is outside the tool. `examples/attach-to-pr.sh` shows one way: it uploads the
file to an orphan `gififier-assets` branch through the GitHub API and comments on the
PR with the image, so binaries stay out of the source history. Use it as is, or adapt
it. The image URL it prints renders inside GitHub. For a private repository the URL
does not work with `curl` or an API token.
