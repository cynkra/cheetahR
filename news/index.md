# Changelog

## cheetahR 0.4.0

- Add `"autocomplete"` column action for typeahead-style cell editing
  over a fixed list of suggestions, configured via
  `column_def(action = "autocomplete", auto_complete_opts = ...)`
- Add [`get_grid_data()`](../reference/get_grid_data.md) Shiny helper to
  retrieve the current grid data as a reactive data frame
- Fix [`renderCheetah()`](../reference/cheetah-shiny.md) appending a new
  grid on re-render instead of replacing the previous one (#51)

## cheetahR 0.3.0

CRAN release: 2025-07-21

- Implement Shiny proxy functions
- Implement column formatter:
  - Numeric formatter
  - Date formatter
- Fix issue with datetime object

## cheetahR 0.2.0

CRAN release: 2025-05-12

- Implement menu column options
- Add filtering and sorting functions
- Add cell messages
- Implement column grouping

## cheetahR 0.1.0

CRAN release: 2025-04-18

- Initial release to CRAN.
- Provides a fast HTML widget wrapping the Cheetah Grid JS library.
- Supports column customization and integration with Shiny.
