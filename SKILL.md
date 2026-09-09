---
name: gififier
description: Record a GIF of a frontend change with the gififier CLI and attach it to the pull request as visual proof. Use after UI changes when a PR needs a screen recording.
---

# gififier

Use `gififier` to record visual proof of a frontend change and attach it to the PR.

## Preconditions

1. Run `gififier doctor`. If Screen Recording permission fails, stop and ask the user to
   grant it to the named application. You cannot grant it yourself.
2. Start the dev server and open the page in a browser window.

## Procedure

1. Find the browser window: `gififier windows`.
2. Start the recording: `gififier start -w "Google Chrome"` (or `-i <id>`).
3. Drive the UI through the change you want to show. Keep it under 15 seconds.
4. Stop and encode: `gififier stop -o proof.gif`.
5. Check the file exists and is under a few MB. Use `--width 800` or `--fps 8` if it is large.
6. Attach it: `gififier attach proof.gif --message "<what the recording shows>"`.
   Use `--pr <n>` if the current branch has no PR yet, or run it after `gh pr create`.

For a short fixed clip, use one command: `gififier record -w Chrome -d 6 -o proof.gif`.

## Notes

- `attach` prints the image URL. Put it in the PR body with `--body` when the PR
  description should carry the proof.
- Recordings and GIFs are ignored by git in this tool's repo. Do not commit GIFs to
  source branches. `attach` stores them on the `gififier-assets` branch.
- Never leave a recording running. `gififier stop` also cleans up state.
