#' Plot interactive explainable SDM map
#'
#' Create an interactive map, showing the feature explanations for every observation.
#' @importFrom magrittr %>%
#' @param explanation_coordinates DataFrame containing the coordinates of the data points.
#' @param map_df DataFrame containing lime explanations data.
#' @param processed_plots list List of plots processed for leaflet map
#'
#' @return Leaflet map
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
#'
#' # plot the interactive leaflet map
#' plot_explainable_sdm(explainable_data$explanation_coordinates,
#' explainable_data$map_df,
#' processed_plots)
#' }
#' @export
plot_explainable_sdm <- function(explanation_coordinates,
                                 map_df,
                                 processed_plots) {
    pal <- leaflet::colorNumeric(palette = grDevices::colorRamp(c('#4575B4',
                                                       '#D73027',
                                                       '#FFFFBF'),
                                            interpolate = "linear"),
                        domain = map_df$label_prob)


    leaflet::leaflet(df) %>%
        leaflet::addProviderTiles("Stamen.TerrainBackground") %>%
        leaflet::addCircleMarkers(explanation_coordinates$x,
                                  explanation_coordinates$y,
                         fillColor = pal(map_df$label_prob),
                         weight = 1,
                         popup = paste0("<img src = ", processed_plots, ">"),
                         popupOptions = leaflet::popupOptions(minWidth = 500,
                                                              maxWidth = 500))

}
