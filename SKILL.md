---
name: gififier
description: Record a GIF of a frontend change with the gififier CLI as visual proof for a pull request. Use after UI changes when a PR needs a screen recording.
---

# gififier

Use `gififier` to record visual proof of a frontend change. The tool only produces
the GIF and prints its path. You decide how to share it.

## Preconditions

1. Run `gififier doctor`. If it reports a Screen Recording failure, stop and ask the
   user to grant the permission to the named application. You cannot grant it yourself.
2. Start the dev server and open the page in a browser window.

## Procedure

1. Find the browser window: `id=$(gififier find "localhost:3000")`. The query matches
   an app name or a window title. Run `gififier windows` to see every candidate.
2. Start the recording: `gififier start -i "$id"`.
3. Drive the UI through the change you want to show. Keep it under 15 seconds.
4. Stop and encode: `gif=$(gififier stop --keep-video)`. The GIF path is printed on
   stdout. Without `-o`, files go to `~/.cache/gififier/out`, outside the project.
5. Check that the GIF is under a few MB. If it is large, re-encode the kept video:
   `gififier convert "${gif%.gif}.mov" --width 800 --fps 8 -o "$gif"`.
6. Share it in the PR. One verified way is `examples/attach-to-pr.sh "$gif" --message
   "<what the recording shows>"` from the gififier repo, which uploads the file to an
   orphan `gififier-assets` branch and comments on the PR of the current branch. Any
   other method is fine, for example a dedicated screenshots branch or an external host.
   Do not commit the GIF to the source branch.

For a short fixed clip, use one command: `gif=$(gififier record -i <id> -d 6)`.

## Notes

- Do not write GIFs inside the project with `-o` unless the path is ignored by git.
- Never leave a recording running. `gififier stop` also cleans up state.
- If the host lacks Screen Recording permission, recordings run through a minimized
  Terminal.app window. A Terminal window appears briefly. This is expected.
