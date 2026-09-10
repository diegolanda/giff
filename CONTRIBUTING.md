# Contributing

- `bin/giff` must run on the stock macOS `/bin/bash` 3.2. Run `/bin/bash -n bin/giff`
  and `shellcheck bin/giff` before a pull request.
- Keep the contract: recording commands print exactly one path on stdout. Everything else
  goes to stderr.
- The tool records. Sharing the file is the caller's job. Keep integrations out of this repository.
- `skills/giff/SKILL.md` is the single source for every harness. Do not edit generated
  files. Change the skill and rerun `install-skill.sh`.
- Test captures from the host you care about. Screen Recording permission is per application.
