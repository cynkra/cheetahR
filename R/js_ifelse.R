#' Convert an R logical expression into a JS ternary expression
#'
#' @param condition An R logical expression (supports %in% / %notin% / grepl() / comparisons / & |)
#' @param if_true  String to return when the condition is TRUE. Default is an empty string, which interprets as `null` in JS.
#' @param if_false String to return when the condition is FALSE. Default is an empty string, which interprets as `null` in JS.
#' @return A single character string containing a JavaScript ternary expression.
#' @export
js_ifelse <- function(condition, if_true = "", if_false = "") {
  # 1) Capture the unevaluated condition as a single string
  txt <- paste(deparse(substitute(condition)), collapse = " ")

  # 2) Force all " to ' in the condition itself
  txt <- gsub("\"", "'", txt, fixed = TRUE)

  # 3) Handle %notin% and %in%
  handle_in <- function(text) {
    pat <- "(\\b[[:alnum:]_.]+)\\s*%(not)?in%\\s*c\\(([^)]+)\\)"
    matches <- gregexpr(pat, text, perl = TRUE)[[1]]
    if (matches[1] == -1) return(text)

    for (raw in regmatches(text, gregexpr(pat, text, perl = TRUE))[[1]]) {
      parts <- regmatches(raw, regexec(pat, raw, perl = TRUE))[[1]]
      var   <- parts[2]
      neg   <- !is.na(parts[3]) && nzchar(parts[3])
      vals  <- strsplit(parts[4], ",")[[1]]
      # Trim only whitespace, leave the single quotes intact:
      vals  <- trimws(vals)

      # Paste them back together (they already have their single quotes):
      arr   <- sprintf("[%s]", paste(vals, collapse = ","))
      expr  <- sprintf("%s.includes(rec['%s'])", arr, var)
      if (neg) expr <- paste0("!", expr)

      text <- sub(pat, expr, text, perl = TRUE)
    }
    text
  }
  txt <- handle_in(txt)

  # 4) Handle grepl() and !grepl(), capturing the inner regex
  handle_grep <- function(text) {
    pat <- "(!?)grepl\\((['\"])(.*?)\\2,\\s*([[:alnum:]_.]+)\\)"
    matches <- gregexpr(pat, text, perl = TRUE)[[1]]
    if (matches[1] == -1) return(text)

    for (raw in regmatches(text, gregexpr(pat, text, perl = TRUE))[[1]]) {
      parts <- regmatches(raw, regexec(pat, raw, perl = TRUE))[[1]]
      notp    <- nzchar(parts[2])
      pattern <- parts[4]
      var     <- parts[5]

      expr <- sprintf("%s/%s/.test(rec['%s'])",
                      if (notp) "!" else "", pattern, var)
      text <- sub(pat, expr, text, perl = TRUE)
    }
    text
  }
  txt <- handle_grep(txt)

  # 5) Replace R logical operators with JS equivalents
  txt <- gsub("!=", "!==", txt, fixed = TRUE)
  txt <- gsub("==", "===",  txt, fixed = TRUE)
  txt <- gsub(" & ", " && ", txt, fixed = TRUE)
  txt <- gsub(" | ", " || ", txt, fixed = TRUE)

  # 6) Prefix all remaining bare names with rec['...'], skipping 'rec' itself
  prefix_pat <- "(?<![\\w'\"/\\[\\]])\\b(?!rec\\b)([A-Za-z_][A-Za-z0-9_.]*)\\b(?![\\]\\('\"/])"
  txt <- gsub(prefix_pat, "rec['\\1']", txt, perl = TRUE)

  # 7) Wrap the true/false results in single quotes (or null)
  wrap <- function(x) {
    x2 <- gsub("\"", "'", x, fixed = TRUE)
    if (x2 == "") "null" else sprintf("'%s'", x2)
  }
  tval <- wrap(if_true)
  fval <- wrap(if_false)

  # 8) Assemble and return the JS ternary
  sprintf("%s ? %s : %s;", txt, tval, fval)
}
