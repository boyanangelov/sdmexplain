#' Process LIME plots
#'
#' Process LIME plots to make them usable in an interactive map
#'
#' @param explanation DataFrame containing LIME explained data
#'
#' @return list containing processed plots
#' @examples
#' \dontrun{
#' # build and train a machine learning model
#' task <- makeClassifTask(id = "model", data = data.train, target = "label")
#' lrn <- makeLearner("classif.lda", predict.type = "prob")
#' mod <- train(lrn, task)
#'
#' # prepare explainable data
#' explainable_data <- prepare_explainable_data(data.test, mod, coordinates.df)
#'
#' # process lime plots to make them suitable for leaflet
#' processed_plots <- process_lime_plots(explainable_data$explanation)
#' }
#' @export
process_lime_plots <- function(explanation) {
    plots <- plyr::dlply(explanation,
                         .variables = "case",
                         function(x) lime::plot_features(x))

    processed_plots <- list()
    for (i in 1:length(plots)) {
        temp <- makePlotURI({
            print(plots[i])
        }, 500, 500, bg = "transparent")
        processed_plots[[i]] <- temp
    }

    return(processed_plots)
}