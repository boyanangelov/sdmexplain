#' Plot interactive explainable SDM map
#'
#' Create an interactive map, showing the feature explanations for every observation.
#'
#' @importFrom magrittr %>%
#' @param input_data A DataFrame containing the lime explanations and data point coordinates.
#' @param processed_plots A list of plots processed for leaflet map.
#' @param use_selected_feature A logical indicating if a feature is extracted for plotting.
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
#' plot_explainable_sdm(explainable_data$processed_data, processed_plots)
#' }
#' @export
plot_explainable_sdm <- function(input_data, processed_plots,
    use_selected_feature = FALSE)
    {

    if (use_selected_feature)
    {
        pal <- leaflet::colorNumeric(palette = colorRamp(c("#f44242",
            "#ffffff"), interpolate = "linear", bias = 0.8),
            input_data$model_prediction_correct)
        pal2 <- leaflet::colorBin(palette = "Blues",
                                  domain = as.numeric(input_data$label))

        leafIcons <- leaflet::icons(iconUrl = ifelse(input_data$label ==
            "1", paste(system.file(package = "sdmexplain"), "icon_folder/eye.png",
            sep = "/"), paste(system.file(package = "sdmexplain"),
            "icon_folder/x.png", sep = "/")), iconWidth = 15,
            iconHeight = 15)

        leaflet::leaflet(df) %>%
            leaflet::addProviderTiles("Stamen.TerrainBackground") %>%
            leaflet::addMarkers(input_data$lng, input_data$lat,
                icon = leafIcons) %>% leaflet::addCircleMarkers(input_data$lng,
            input_data$lat,
            radius = input_data$feature_value/20, weight = 1,
            popup = paste0("<img src = ", processed_plots, ">"),
            popupOptions = leaflet::popupOptions(minWidth = 500,
                maxWidth = 500))
    } else
    {
        pal <- leaflet::colorNumeric(palette = colorRamp(c("#f44242",
            "#ffffff"), interpolate = "linear", bias = 0.8),
            input_data$model_prediction_correct)
        pal2 <- leaflet::colorBin(palette = "Blues",
                                  domain = as.numeric(input_data$label))


        leafIcons <- leaflet::icons(iconUrl = ifelse(input_data$label ==
            "1", paste(system.file(package = "sdmexplain"), "icon_folder/eye.png",
            sep = "/"), paste(system.file(package = "sdmexplain"),
            "icon_folder/x.png", sep = "/")), iconWidth = 15,
            iconHeight = 15)

        leaflet::leaflet(df) %>%
            leaflet::addProviderTiles("Stamen.TerrainBackground") %>%
            leaflet::addMarkers(input_data$lng, input_data$lat,
                icon = leafIcons) %>% leaflet::addCircleMarkers(input_data$lng,
            input_data$lat,
            radius = rep(15, length(input_data)), weight = 1,
            popup = paste0("<img src = ", processed_plots, ">"),
            popupOptions = leaflet::popupOptions(minWidth = 500,
                maxWidth = 500))
    }
}
