#' Helper functions
#'
makePlotURI <- function(expr, width, height, ...) {
    pngFile <- shiny::plotPNG(function() { expr },
                              width = width,
                              height = height, ...)
    on.exit(unlink(pngFile))

    base64 <- httpuv::rawToBase64(readBin(pngFile, raw(1), file.size(pngFile)))
    paste0("data:image/png;base64,", base64)
}
