# Migration: dotfiles scripts → standalone Python packages

Each CLI tool in `~/.local/bin/` is being extracted into its own Python package
under `~/dev/`, with its own repo.

## Paths

- **Dotfiles repo:** `~/.config/dotfiles`
- **Original scripts:** `~/.config/dotfiles/.local/bin/`
- **New packages:** `~/dev/<tool>/` (each with `src/<tool>/`, `pyproject.toml`)
- **Config files:** `~/.config/<tool>/config.toml`

## Migration status

- [x] `diary` — date↔filepath resolution, natural language parsing → `~/dev/today` ([KUKARAF/diary](https://github.com/KUKARAF/diary))
- [x] `diary week` — weekly diary view (subcommand of `diary`)
- [x] `diary month` — monthly diary view (subcommand of `diary`)
- [ ] `todo` — todo management (standalone repo, will depend on `today`)

## Notes

- Original scripts stay in dotfiles until each package is installed and verified.
- `today` package has zero base deps; `timefhuman` is behind `[cli]` extra.
- `week` and `month` are subcommands of `diary` (`diary week`, `diary month`).
