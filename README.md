<!-- README.md is generated from README.Rmd. Please edit that file -->
[![Build Status](https://travis-ci.org/boyanangelov/sdmexplain.svg?branch=master)](https://travis-ci.org/boyanangelov/sdmexplain)

sdmexplain
==========

`sdmexplain` is an R package to make Species Distribution Models more explainable.

Example
-------

Preparing training data.

``` r
occ_data_raw <- sdmbench::get_benchmarking_data("Lynx lynx")
#> [1] "Getting benchmarking data...."
#> [1] "Cleaning benchmarking data...."
#> Assuming 'decimalLatitude' is latitude
#> Assuming 'decimalLongitude' is longitude
#> Assuming 'latitude' is latitude
#> Assuming 'longitude' is longitude
#> Assuming 'latitude' is latitude
#> Assuming 'longitude' is longitude
#> [1] "Done!"
occ_data <- occ_data_raw$df_data
occ_data$label <- as.factor(occ_data$label)

coordinates.df <- rbind(occ_data_raw$raster_data$coords_presence,
                        occ_data_raw$raster_data$background)
occ_data <- cbind(occ_data, coordinates.df)

train_test_split <- rsample::initial_split(occ_data, prop = 0.7)
data.train <- rsample::training(train_test_split)
data.test  <- rsample::testing(train_test_split)

train.coords <- dplyr::select(data.train, c("x", "y"))
data.train$x <- NULL
data.train$y <- NULL

test.coords <- dplyr::select(data.test, c("x", "y"))
data.test$x <- NULL
data.test$y <- NULL
```

Training SDM.

``` r
task <- makeClassifTask(id = "model", data = data.train, target = "label")
lrn <- makeLearner("classif.lda", predict.type = "prob")
mod <- train(lrn, task)
#> Warning in lda.default(x, grouping, ...): variables are collinear
```

Preparing data for explainability.

``` r
explainable_data <- prepare_explainable_data(data.test, mod, test.coords)
```

Plotting explainable map.

``` r
plot_explainable_sdm(explainable_data$explanation_coordinates,
                     explainable_data$map_df,
                     processed_plots)
```

!(screenshots/screenshot\_1.png)\[\]
