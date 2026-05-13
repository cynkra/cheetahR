# Compare cheetahR, reactable, DT, and rhandsontable for table-widget render
# performance. R-side widget construction is timed with bench::mark; browser-side
# render time is measured by loading each saved widget in a headless Chromium
# via chromote and timing from page navigation to when the widget's expected
# DOM has been rendered for two consecutive frames.
#
# Run with: Rscript script/benchmark.R
# Output:   script/benchmark_results.csv

suppressPackageStartupMessages({
  library(cheetahR)
  library(reactable)
  library(DT)
  library(rhandsontable)
  library(htmlwidgets)
  library(chromote)
  library(bench)
})

# ---- Defaults ---------------------------------------------------------------

default_sizes <- c(1e3, 1e4, 1e5, 1e6)
default_engines <- c("cheetah", "reactable", "DT", "rhandsontable")
default_out_csv <- "script/benchmark_results.csv"
default_out_png <- "script/benchmark_plot.png"

# ---- Helpers ---------------------------------------------------------------

make_data <- function(n) {
  set.seed(1)
  data.frame(
    id   = seq_len(n),
    grp  = sample(letters[1:8], n, replace = TRUE),
    name = paste0("item_", seq_len(n)),
    x1 = rnorm(n), x2 = rnorm(n), x3 = rnorm(n),
    x4 = runif(n), x5 = runif(n), x6 = runif(n),
    x7 = rpois(n, 5), x8 = rpois(n, 5), x9 = rpois(n, 5),
    stringsAsFactors = FALSE
  )
}

# Per-widget DOM "ready" predicates injected into the saved HTML. The widget is
# considered painted when the predicate returns true for two consecutive frames.
ready_js <- list(
  cheetah = "() => { const c = document.querySelector('canvas'); return !!c && c.width > 0 && c.height > 0; }",
  reactable = "() => document.querySelectorAll('.rt-tbody .rt-tr').length > 0",
  DT = "() => document.querySelectorAll('table.dataTable tbody tr').length > 0",
  rhandsontable = "() => document.querySelectorAll('.handsontable .htCore tbody tr').length > 0"
)

# Build the widget for a given engine and dataset. Each is invoked with its
# default user-facing configuration: reactable and DT paginate client-side,
# rhandsontable renders all rows, cheetahR uses its canvas grid.
build_widget <- function(engine, data) {
  switch(engine,
    cheetah       = cheetah(data),
    reactable     = reactable::reactable(data),
    DT            = DT::datatable(data),
    rhandsontable = rhandsontable::rhandsontable(data)
  )
}

# Inject a timing harness into a self-contained widget HTML file. The harness
# records performance.now() at script start, polls requestAnimationFrame until
# the engine-specific ready predicate is satisfied for two consecutive frames,
# and stores the elapsed milliseconds in window.__benchTime.
inject_timer <- function(html_path, engine) {
  html <- readLines(html_path, warn = FALSE)
  predicate <- ready_js[[engine]]
  harness <- sprintf('<script>
(function(){
  const t0 = performance.now();
  const isReady = %s;
  let stable = 0;
  function tick(){
    try {
      if (isReady()) {
        stable++;
        if (stable >= 2) {
          window.__benchTime = performance.now() - t0;
          window.__benchDone = true;
          return;
        }
      } else {
        stable = 0;
      }
    } catch(e) { stable = 0; }
    requestAnimationFrame(tick);
  }
  if (document.readyState === "loading") {
    document.addEventListener("DOMContentLoaded", () => requestAnimationFrame(tick));
  } else {
    requestAnimationFrame(tick);
  }
})();
</script>', predicate)
  html <- sub("<body>", paste0("<body>\n", harness), html, fixed = TRUE)
  writeLines(html, html_path)
}

# Load a saved widget HTML in headless Chromium and wait until the injected
# harness reports a render time (or the timeout elapses).
measure_browser <- function(html_path, timeout_s = 60) {
  b <- ChromoteSession$new()
  on.exit(b$close(), add = TRUE)
  url <- paste0("file://", normalizePath(html_path))
  b$Page$navigate(url)
  deadline <- Sys.time() + timeout_s
  repeat {
    res <- b$Runtime$evaluate("window.__benchDone === true")
    if (isTRUE(res$result$value)) break
    if (Sys.time() > deadline) return(NA_real_)
    Sys.sleep(0.05)
  }
  val <- b$Runtime$evaluate("window.__benchTime")
  as.numeric(val$result$value)
}

# Time a single (engine, size) cell: R-side construction via bench::mark plus
# headless-browser render time. Returns a one-row data frame; failures are
# returned with NAs and an error message rather than aborting the run.
bench_cell <- function(engine, n, r_iterations = 5, browser_timeout_s = 60) {
  data <- make_data(n)
  message(sprintf("  %-14s n=%-8s ...", engine, format(n, big.mark = ",")))

  r_res <- tryCatch(
    bench::mark(
      build_widget(engine, data),
      iterations = r_iterations,
      check = FALSE,
      filter_gc = FALSE
    ),
    error = function(e) NULL
  )
  r_time_ms <- if (is.null(r_res)) NA_real_ else as.numeric(median(r_res$time[[1]])) * 1000

  browser_time_ms <- tryCatch({
    widget <- build_widget(engine, data)
    tmp_dir <- tempfile("bench_")
    dir.create(tmp_dir)
    on.exit(unlink(tmp_dir, recursive = TRUE), add = TRUE)
    tmp <- file.path(tmp_dir, "widget.html")
    htmlwidgets::saveWidget(widget, tmp, selfcontained = FALSE)
    inject_timer(tmp, engine)
    measure_browser(tmp, timeout_s = browser_timeout_s)
  }, error = function(e) {
    message("    browser error: ", conditionMessage(e))
    NA_real_
  })

  data.frame(
    engine = engine,
    n = n,
    r_time_ms = round(r_time_ms, 1),
    browser_time_ms = round(browser_time_ms, 1)
  )
}

# ---- Reporting -------------------------------------------------------------

# Render a faceted log-log line chart of R-side and browser render times.
# Returns the ggplot invisibly. Saves to `out_png` if provided.
plot_benchmark <- function(results, out_png = default_out_png) {
  if (!requireNamespace("ggplot2", quietly = TRUE)) {
    message("ggplot2 not installed; skipping plot.")
    return(invisible(NULL))
  }
  long <- rbind(
    data.frame(results[, c("engine", "n")],
               phase = "R-side construction",
               time_ms = results$r_time_ms),
    data.frame(results[, c("engine", "n")],
               phase = "Browser render (headless)",
               time_ms = results$browser_time_ms)
  )
  long <- long[!is.na(long$time_ms), ]
  long$phase <- factor(long$phase,
    levels = c("R-side construction", "Browser render (headless)"))

  p <- ggplot2::ggplot(long, ggplot2::aes(n, time_ms, color = engine)) +
    ggplot2::geom_line(linewidth = 0.8) +
    ggplot2::geom_point(size = 2) +
    ggplot2::scale_x_log10(labels = function(x) format(x, big.mark = ",", scientific = FALSE)) +
    ggplot2::scale_y_log10(labels = function(x) format(x, big.mark = ",", scientific = FALSE)) +
    ggplot2::facet_wrap(~ phase, scales = "free_y") +
    ggplot2::labs(
      title = "Table-widget render performance",
      subtitle = "Lower is better; log-log axes",
      x = "Rows", y = "Time (ms)", color = "Engine"
    ) +
    ggplot2::theme_minimal(base_size = 12)

  if (!is.null(out_png)) {
    ggplot2::ggsave(out_png, p, width = 9, height = 4.5, dpi = 120)
  }
  invisible(p)
}

# Print a markdown-formatted summary of the results — pastable into a GitHub
# issue, README, or NEWS entry without further editing.
report_benchmark <- function(results) {
  fmt <- function(x) ifelse(is.na(x), "—", format(round(x), big.mark = ","))
  for (phase in c("R-side construction (ms)", "Browser render, headless (ms)")) {
    col <- if (startsWith(phase, "R-side")) "r_time_ms" else "browser_time_ms"
    wide <- reshape(results[, c("engine", "n", col)],
                    idvar = "engine", timevar = "n", direction = "wide")
    sizes <- sort(unique(results$n))
    header <- c("engine", format(sizes, big.mark = ",", scientific = FALSE))
    cat(sprintf("\n**%s**\n\n", phase))
    cat("|", paste(header, collapse = " | "), "|\n")
    cat("|", paste(rep("---", length(header)), collapse = " | "), "|\n")
    for (i in seq_len(nrow(wide))) {
      vals <- vapply(wide[i, -1, drop = FALSE], fmt, character(1))
      cat("|", wide$engine[i], "|", paste(vals, collapse = " | "), "|\n")
    }
  }
}

# ---- Public entry point ----------------------------------------------------

run_benchmark <- function(sizes = default_sizes,
                          engines = default_engines,
                          r_iterations = 5,
                          browser_timeout_s = 60,
                          out_csv = default_out_csv,
                          out_png = default_out_png) {
  grid <- expand.grid(engine = engines, n = sizes, stringsAsFactors = FALSE)
  results <- do.call(rbind, Map(
    function(e, n) bench_cell(e, n, r_iterations, browser_timeout_s),
    grid$engine, grid$n
  ))

  if (!is.null(out_csv)) write.csv(results, out_csv, row.names = FALSE)
  plot_benchmark(results, out_png = out_png)
  report_benchmark(results)

  if (!is.null(out_csv)) cat(sprintf("\nCSV:  %s\n", out_csv))
  if (!is.null(out_png)) cat(sprintf("Plot: %s\n", out_png))
  invisible(results)
}

# Run with defaults when invoked via Rscript; sourced interactively, this is a
# no-op so the helper functions can be used directly.
if (sys.nframe() == 0L && !interactive()) {
  run_benchmark()
}
