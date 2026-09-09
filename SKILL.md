---
name: gififier
description: Record a GIF of a frontend change with the gififier CLI and attach it to the pull request as visual proof. Use after UI changes when a PR needs a screen recording.
---

# gififier

Use `gififier` to record visual proof of a frontend change and attach it to the PR.

## Preconditions

1. Run `gififier doctor`. If it reports a Screen Recording failure, stop and ask the
   user to grant the permission to the named application. You cannot grant it yourself.
2. Start the dev server and open the page in a browser window.

## Procedure

1. Find the browser window: `gififier windows`. Pick the id whose title matches the page.
2. Start the recording: `gififier start -i <id>` (or `-w "Google Chrome"`).
3. Drive the UI through the change you want to show. Keep it under 15 seconds.
4. Stop and encode: `gif=$(gififier stop --keep-video)`. The GIF path is printed on
   stdout. Without `-o`, files go to `~/.cache/gififier/out`, outside the project.
5. Check that the GIF is under a few MB. If it is large, re-encode the kept video:
   `gififier convert "${gif%.gif}.mov" --width 800 --fps 8 -o "$gif"`.
6. Attach it: `gififier attach "$gif" --message "<what the recording shows>"`.
   The current branch must have an open PR. Create the PR first with `gh pr create`,
   or pass `--pr <n>`.

For a short fixed clip, use one command: `gif=$(gififier record -i <id> -d 6)`.

## Notes

- Do not write GIFs inside the project with `-o` unless the path is ignored by git.
  `attach` stores the file on the `gififier-assets` branch, so GIFs never need to be
  committed.
- `attach` prints the image URL. Use `--body` to put the image in the PR description
  instead of a comment.
- Never leave a recording running. `gififier stop` also cleans up state.
- If the host lacks Screen Recording permission, recordings run through a minimized
  Terminal.app window. A Terminal window appears briefly. This is expected.
