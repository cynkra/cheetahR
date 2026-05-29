## Submission summary

This is a minor release of cheetahR, version 0.4.0.

### New features

- New `"autocomplete"` column action for typeahead-style cell editing
  (`column_def(action = "autocomplete", auto_complete_opts = ...)`).
- New `get_grid_data()` Shiny helper that exposes the current grid contents
  as a reactive data frame.

### Bug fixes

- Fix `renderCheetah()` appending a new grid on re-render instead of
  replacing the previous one (GitHub issue #51).

## Test environments

- macOS (local), R 4.5.1
- GitHub Actions: ubuntu-latest, macOS-latest, windows-latest (R-release, R-devel)

## R CMD check results

0 errors | 0 warnings | 0 notes

## Reverse dependencies

cheetahR has no reverse dependencies on CRAN at the time of this submission.
