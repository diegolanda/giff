---
name: giff
description: Record a GIF of a frontend change with the giff CLI as visual proof for a pull request. Use after UI changes when a PR needs a screen recording.
---

# giff

Use `giff` to record visual proof of a frontend change. The tool only produces
the GIF and prints its path. You decide how to share it.

## Preconditions

1. Run `giff doctor`. If it fails, run `giff doctor --fix`. It installs missing
   dependencies and asks macOS to show the Screen Recording dialog for the named
   application. If the permission is still missing, stop and ask the user to enable it
   in System Settings and restart the application. You cannot grant it yourself.
2. Start the dev server and open the page in a browser window.

## Procedure

1. Find the browser window: `id=$(giff find "localhost:3000")`. The query matches
   an app name or a window title. Run `giff windows` to see every candidate.
2. Start the recording: `giff start -i "$id"`.
3. Drive the UI through the change you want to show. Keep it under 15 seconds.
4. Stop and encode: `gif=$(giff stop --keep-video)`. The GIF path is printed on
   stdout. Without `-o`, files go to `~/.cache/giff/out`, outside the project.
5. Check that the GIF is under a few MB. If it is large, re-encode the kept video:
   `giff convert "${gif%.gif}.mov" --width 800 --fps 8 -o "$gif"`.
6. Share it. The tool stops at the GIF path. Ask the user how they want it in the PR,
   unless the project already documents a way. Do not commit the GIF to the source branch.

For a short fixed clip, use one command: `gif=$(giff record -i <id> -d 6)`.

## Notes

- Do not write GIFs inside the project with `-o` unless the path is ignored by git.
- Never leave a recording running. `giff stop` also cleans up state.
- If the host lacks Screen Recording permission, recordings run through a minimized
  Terminal.app window. A Terminal window appears briefly. This is expected.
