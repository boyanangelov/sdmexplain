context("Test preparation of explainable data")

library(dplyr)
library(mlr)

occ_data_raw <- sdmbench::get_benchmarking_data("Lynx lynx")
occ_data <- occ_data_raw$df_data
occ_data$label <- as.factor(occ_data$label)

coordinates.df <- rbind(occ_data_raw$raster_data$coords_presence,
                        occ_data_raw$raster_data$background)
occ_data <- cbind(occ_data, coordinates.df)

train_test_split <- rsample::initial_split(occ_data, prop = 0.7)
data.train <- rsample::training(train_test_split)
data.test  <- rsample::testing(train_test_split)

train.coords <- data.train %>% select(c("x", "y"))
data.train$x <- NULL
data.train$y <- NULL

test.coords <- data.test %>% select(c("x", "y"))
data.test$x <- NULL
data.test$y <- NULL

task <- makeClassifTask(id = "model", data = data.train, target = "label")
lrn <- makeLearner("classif.lda", predict.type = "prob")
mod <- train(lrn, task)

# Explainable Package Use -------------------------------------------------

explainable_data <- prepare_explainable_data(data.test, mod, test.coords, randomize = TRUE, randomize_proportion = 0.1)


test_that("Explainable data is prepared", {
    expect_equal(length(explainable_data), 3)
    expect_equal(dim(explainable_data$processed_data), c(6270, 6))
    expect_equal(dim(explainable_data$explanation), c(6270, 12))
})
