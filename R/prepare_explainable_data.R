#' Explain SDM models
#'
#' Prepare data for plotting interactive explainable SDM.
#'
#' @param test_dataset A DataFrame containing the test data.
#' @param mlr_model A trained MLR model
#' @param coordinates_df A Dataframe containing the coordinates.
#' @param selected_feature A character indicating if a feature should be extracted for plotting.
#' @param randomize Boolean deciding if a sample of the dataset should be taken
#' @param randomize_proportion Float deciding what proportion of the data should be sampled
#'
#' @return A list containing data necessary for the interactive map
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
prepare_explainable_data <- function(test_dataset, mlr_model,
                                     coordinates_df, selected_feature = "none", randomize = FALSE, randomize_proportion = .1) {

    final_processed_plots <- list()
    final_explanation <- data.frame()
    final_processed_data <- data.frame()

    # randomize dataset
    if (randomize == TRUE) {
        test_dataset <- sample_frac(test_dataset, randomize_proportion)
    }

    explainer <- lime::lime(test_dataset, mlr_model)

    for (i in 1:nrow(test_dataset))

    {
        explanation <- lime::explain(test_dataset[i,], explainer, n_labels = 1, n_features = 19)
        explanation_coordinates <- subset(coordinates_df,
                                          row.names(coordinates_df) %in%
                                              as.integer(explanation$case))
        explanation_coordinates$case <- row.names(explanation_coordinates)

        map_df <- merge(explanation, explanation_coordinates, by = "case")

        names(map_df)[names(map_df) == "x"] <- "lng"
        names(map_df)[names(map_df) == "y"] <- "lat"

        model_predictions <- map_df %>% dplyr::group_by(case) %>%
            dplyr::summarise(model_prediction_correct = mean(model_prediction))

        correct_classes <- map_df %>% dplyr::select(case, label) %>%
            dplyr::distinct()

        correct_coordinates <- map_df %>% dplyr::select(case, lng,
                                                        lat) %>% dplyr::distinct()


        if (selected_feature != "none")
        {
            selected_feature_data <- map_df %>% dplyr::filter(feature ==
                                                                  selected_feature) %>% dplyr::select(case, feature_value)
        } else
        {
            selected_feature_data <- map_df %>% dplyr::group_by(case) %>%
                dplyr::select(case)
            selected_feature_data$feature_value <- rep(NA, dim(map_df)[1])
        }


        # process plots
        temp_plot <- plyr::dlply(explanation, .variables = "case", function(x) lime::plot_features(x))


        temp <- makePlotURI({
            print(temp_plot)
        }, 500, 500, bg = "transparent")


        # append to processed plots
        final_processed_plots[[i]] <- temp

        # delete heavy column (data?)
        explanation$data <- NULL

        # append the rest to final explanation dataframe
        final_explanation <- rbind(final_explanation, explanation)

        # same for processed data
        processed_data <- plyr::join_all(list(model_predictions,
                                              correct_classes, correct_coordinates, selected_feature_data),
                                         by = "case", type = "left")
        final_processed_data <- rbind(final_processed_data, processed_data)

    }



    return(list(processed_data = final_processed_data,
                explanation = final_explanation,
                processed_plots = final_processed_plots))
}
