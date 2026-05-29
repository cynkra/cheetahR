<!-- NEWS.md is maintained by https://cynkra.github.io/fledge, do not edit -->

# cheetahR 0.4.0

- Add `"autocomplete"` column action for typeahead-style cell editing over a fixed list of suggestions, configured via `column_def(action = "autocomplete", auto_complete_opts = ...)`
- Add `get_grid_data()` Shiny helper to retrieve the current grid data as a reactive data frame
- Fix `renderCheetah()` appending a new grid on re-render instead of replacing the previous one (#51)


# cheetahR 0.3.0

- Implement Shiny proxy functions
- Implement column formatter:
  - Numeric formatter
  - Date formatter
- Fix issue with datetime object


# cheetahR 0.2.0

- Implement menu column options
- Add filtering and sorting functions
- Add cell messages
- Implement column grouping


# cheetahR 0.1.0

* Initial release to CRAN.
* Provides a fast HTML widget wrapping the Cheetah Grid JS library.
* Supports column customization and integration with Shiny.
