#' Explain SDM models
#'
#' Prepare data for plotting interactive explainable SDM.
#'
#' @param test_dataset DataFrame containing the test data
#' @param mlr_model Trained MLR model
#'
#' @return list containing data necessary for the interactive map
#' @examples
#' \dontrun{
#' # build and train a machine learning model
#' task <- makeClassifTask(id = "model", data = data.train, target = "label")
#' lrn <- makeLearner("classif.lda", predict.type = "prob")
#' mod <- train(lrn, task)
#'
#' # prepare explainable data
#' explainable_data <- prepare_explainable_data(data.test, mod, coordinates.df)
#' }
#' @export
prepare_explainable_data <- function(test_dataset, mlr_model, coordinates_df) {

    explainer <- lime::lime(test_dataset, mlr_model)

    explanation <- lime::explain(test_dataset[1:100,], explainer,
                                 n_labels = 1, n_features = 19)

    explanation_coordinates <- subset(coordinates_df,
                                      row.names(coordinates_df) %in%
                                          as.integer(explanation$case))
    explanation_coordinates$case <- row.names(explanation_coordinates)

    map_df <- merge(explanation, explanation_coordinates, by = "case")

    names(map_df)[names(map_df) == 'x'] <- 'lng'
    names(map_df)[names(map_df) == 'y'] <- 'lat'

    return(list("map_df" = map_df, "explanation" = explanation,
                "explanation_coordinates" = explanation_coordinates))
}