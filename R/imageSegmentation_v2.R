###### I have modified this imageseg function as I was getting map_depth errors



imageSegmentation_v2 <- function (model, x, dirOutput, dirExamples, subsetArea, threshold = 0.5, 
          returnInput = FALSE) 
{
  
  # install and load tidyverse
  if (!require("tidyverse")){
    install.packages("tidyverse")
    library(tidyverse)
    suppressPackageStartupMessages({library(tidyverse)})
  }
  
  
  if (!is.null(attr(x, "info"))) {
    info_df <- attr(x, "info")
  }
  if (dim(x)[1] == 1) 
    stop("Please provide 2 or more images in x")
  if (hasArg(subsetArea)) {
    if (inherits(subsetArea, "character")) {
      if (subsetArea != "circle") 
        stop("subsetArea is character, but not 'circle'")
      if (dim(x)[2] != dim(x)[3]) 
        stop("subsetArea can only be 'circle' if the images in x are square")
      subsetArea <- circular.weight(dim(x)[2])
    }
    else {
      if (inherits(subsetArea, "matrix")) {
        tmp <- table(subsetArea)
        if (length(names(tmp)) > 2) 
          stop("subsetArea is a matrix but has more values than 0 and 1")
        if (!all(c("0", "1") %in% names(tmp))) 
          stop("subsetArea does not contain 0 and 1")
        if (paste(dim(subsetArea), collapse = ",") != 
            paste(dim(x)[2:3], collapse = ",")) 
          stop(paste0("subsetArea has different dimensions than x (", 
                      paste(dim(subsetArea), collapse = ","), 
                      " vs ", paste(dim(x)[2:3], collapse = ","), 
                      ")"))
      }
      else {
        if (is.numeric(subsetArea)) {
          subsetArea <- circular.weight(dim(x)[2], ratio = subsetArea)
        }
        else {
          stop("subsetArea can only be 'circle', or a matrix of 1 and 0 in the dimensions of the input images (x), or a number between 0 and 1")
        }
      }
    }
  }
  predictions <- model %>% predict(x)
  n_class <- dim(predictions)[4]
  n_cells <- prod(dim(x)[c(2, 3)])
  . <- NULL
  if (n_class == 1) {
    if (threshold == 0.5) {
      predictions_binary <- round(predictions)
    }
    else {
      predictions_binary <- (predictions >= threshold) * 
        1
    }
    if (dim(x)[4] >= 2) 
      margin_x <- c(1)
    if (dim(x)[4] == 1) 
      margin_x <- c(1, 4)
    max_x <- max(x)
    if (max_x > 1 & max_x <= 255) 
      x <- x/255
    
source("C:\\Users\\ajosan\\OneDrive - Nexus365\\Desktop\\R_scripts\\Unet_ort\\Rscripts\\imageseg_modified_funcs\\map_depth_v2.R")
    images_from_prediction <- tibble(image = x %>% array_branch(margin_x), 
                                     prediction = predictions[, , , 1] %>% array_branch(1), 
                                     prediction_binary = predictions_binary[, , , 1] %>% 
                                       array_branch(1)) %>% map_depth(.ragged = T, 2, function(x) {
                                         as.raster(x) %>% magick::image_read()
                                       }) %>% map(~do.call(c, .x))
  }
  if (n_class != 1) {
    predictions_list <- predictions %>% array_tree(c(1))
    prediction_most_likely <- lapply(predictions_list, apply, 
                                     c(1, 2), which.max)
    images_from_prediction1 <- tibble(image = x %>% array_branch(1), 
                                      prediction_most_likely = prediction_most_likely %>% 
                                        array_branch(1) %>% map(~./n_class)) %>% map_depth(.ragged = T, 2, 
                                                                                           function(x) {
                                                                                             as.raster(x) %>% magick::image_read()
                                                                                           }) %>% map(~do.call(c, .x))
    images_from_prediction2 <- predictions %>% array_tree(c(1, 
                                                            4)) %>% map_depth(.ragged = T, 2, function(x) {
                                                              as.raster(x) %>% magick::image_read()
                                                            }) %>% pmap(., c)
    names(images_from_prediction2) <- paste0("class", seq(1, 
                                                          n_class))
    images_from_prediction <- c(images_from_prediction1, 
                                images_from_prediction2)
  }
  if (n_class == 1) {
    predictions_binary_list <- predictions_binary[, , , 
                                                  1] %>% array_branch(1)
    if (hasArg(subsetArea)) {
      for (i in 1:length(predictions_binary_list)) {
        predictions_binary_list[[i]][subsetArea == 0] <- NA
      }
    }
    mean_predicted <- round(sapply(predictions_binary_list, 
                                   FUN = function(x) mean(x, na.rm = T)), 3)
    mean_not_predicted <- round(sapply(predictions_binary_list, 
                                       FUN = function(x) 1 - mean(x, na.rm = T)), 3)
    if (exists("info_df")) {
      if (nrow(info_df) != length(mean_not_predicted)) 
        stop("mismatch in length of file info attributes in x and predictions based on x")
      if (nrow(info_df) != length(images_from_prediction$image)) 
        stop("mismatch in length of file info attributes in x and input images in x")
    }
  }
  if (n_class > 1) {
    if (hasArg(subsetArea)) {
      for (i in 1:length(prediction_most_likely)) {
        prediction_most_likely[[i]][subsetArea == 0] <- NA
      }
    }
    prediction_percentages <- sapply(prediction_most_likely, 
                                     table)
    if (inherits(prediction_percentages, "matrix")) {
      prediction_percentages3 <- data.frame(t(prediction_percentages))/n_cells
    }
    if (inherits(prediction_percentages, "list")) {
      prediction_percentages2 <- sapply(prediction_percentages, 
                                        FUN = function(x) data.frame(rbind(x)))
      prediction_percentages3 <- data.frame(dplyr::bind_rows(prediction_percentages2), 
                                            row.names = 1:length(prediction_most_likely))/n_cells
    }
    colnames(prediction_percentages3) <- paste0("class", 
                                                1:ncol(prediction_percentages3))
    prediction_percentages3 <- round(prediction_percentages3, 
                                     3)
    prediction_percentages3[is.na(prediction_percentages3)] <- 0
    if (exists("info_df")) {
      if (nrow(info_df) != nrow(prediction_percentages3)) 
        stop("mismatch in length of file info attributes in x and predictions based on x")
      if (nrow(info_df) != length(images_from_prediction$image)) 
        stop("mismatch in length of file info attributes in x and input images in x")
    }
  }
  if (hasArg(subsetArea)) {
    subsetArea_img <- as.raster(subsetArea) %>% magick::image_read()
    subsetArea_img2 <- magick::image_transparent(magick::image_negate(subsetArea_img), 
                                                 color = "white")
    images_from_prediction <- lapply(images_from_prediction, 
                                     FUN = magick::image_composite, image = subsetArea_img2, 
                                     operator = "atop")
    images_from_prediction <- lapply(images_from_prediction, 
                                     FUN = magick::image_background, color = "white")
    images_from_prediction$mask <- subsetArea_img
  }
  if (hasArg(dirExamples)) {
    if (!dir.exists(dirExamples)) 
      dir.create(dirExamples, recursive = TRUE)
    saveExamples <- TRUE
  }
  n_samples_per_image <- 8
  out_list <- list()
  if (n_class == 1) {
    for (i in 1:ceiling(nrow(x)/n_samples_per_image)) {
      in_this_sample <- seq(1:n_samples_per_image) + (n_samples_per_image * 
                                                        (i - 1))
      in_this_sample <- in_this_sample[in_this_sample <= 
                                         length(images_from_prediction$image)]
      out <- magick::image_append(c(magick::image_append(images_from_prediction$image[in_this_sample], 
                                                         stack = TRUE), magick::image_append(images_from_prediction$prediction[in_this_sample], 
                                                                                             stack = TRUE), magick::image_append(images_from_prediction$prediction_binary[in_this_sample], 
                                                                                                                                 stack = TRUE)))
      out_list[[i]] <- out
      if (hasArg(dirExamples)) {
        if (saveExamples) {
          magick::image_write(out, path = file.path(dirExamples, 
                                                    paste0("classification_example", i, ".png")))
        }
      }
    }
  }
  if (n_class > 1) {
    for (i in 1:ceiling(nrow(x)/n_samples_per_image)) {
      in_this_sample <- seq(1:n_samples_per_image) + (n_samples_per_image * 
                                                        (i - 1))
      in_this_sample <- in_this_sample[in_this_sample <= 
                                         length(images_from_prediction$image)]
      out <- magick::image_append(c(magick::image_append(images_from_prediction$image[in_this_sample], 
                                                         stack = TRUE), magick::image_append(images_from_prediction$prediction_most_likely[in_this_sample], 
                                                                                             stack = TRUE), map(images_from_prediction[startsWith(names(images_from_prediction), 
                                                                                                                                                  "class")], ~.x[in_this_sample]) %>% map(., magick::image_append, 
                                                                                                                                                                                          stack = TRUE)))
      out_list[[i]] <- out
      if (hasArg(dirExamples)) {
        if (saveExamples) {
          magick::image_write(out, path = file.path(dirExamples, 
                                                    paste0("classification_example", i, ".png")))
        }
      }
    }
  }
  images_from_prediction$examples <- Reduce(c, out_list)
  if (hasArg(dirOutput)) {
    if (!dir.exists(dirOutput)) 
      dir.create(dirOutput, recursive = TRUE)
    if (n_class == 1) 
      output <- "prediction_binary"
    if (n_class > 1) 
      output <- "prediction_most_likely"
    if (exists("info_df")) {
      filenames_orig <- strsplit(info_df$filename, .Platform$file.sep, 
                                 fixed = TRUE)
      filenames_orig <- sapply(filenames_orig, FUN = function(x) x[length(x)])
      filenames_out <- sapply(strsplit(filenames_orig, 
                                       split = ".", fixed = TRUE), FUN = function(x) x[1])
      if (anyDuplicated(filenames_out) != 0) {
        warning("Output file names are not unique. Attempting to make them unique by adding data augmentation information.")
        if ("rotation" %in% colnames(info_df)) 
          filenames_out <- paste0(filenames_out, "_rot", 
                                  info_df$rotation)
        if ("flip" %in% colnames(info_df)) 
          filenames_out <- paste0(filenames_out, ifelse(info_df$flip, 
                                                        "_flip", ""))
        if ("flop" %in% colnames(info_df)) 
          filenames_out <- paste0(filenames_out, ifelse(info_df$flop, 
                                                        "_flop", ""))
        if (anyDuplicated(filenames_out) != 0) 
          stop("Failed to make file names unique. Please check attr(x, 'info') and ensure there are no duplicates. First duplicate was:\n", 
               filenames_orig[anyDuplicated(filenames_out)])
      }
      filenames_out_class <- paste0(filenames_out, "_classified", 
                                    ".png")
      filenames_out <- paste0(filenames_out, ".png")
    }
    else {
      filenames_out <- paste0(seq(1, length(images_from_prediction[[output]])), 
                              ".png")
      filenames_out_class <- paste0(seq(1, length(images_from_prediction[[output]])), 
                                    "_classified.png")
    }
    for (i in 1:length(images_from_prediction[[output]])) {
      if (returnInput) {
        magick::image_write(image = images_from_prediction$image[i], 
                            path = file.path(dirOutput, filenames_out[i]))
      }
      magick::image_write(image = images_from_prediction[[output]][i], 
                          path = file.path(dirOutput, filenames_out_class[i]))
    }
  }
  if (n_class == 1) {
    image_summary <- data.frame(not_predicted = mean_not_predicted, 
                                predicted = mean_predicted)
  }
  if (n_class > 1) {
    image_summary <- prediction_percentages3
  }
  if (exists("info_df")) {
    images_from_prediction$summary <- cbind(info_df, image_summary)
  }
  else {
    images_from_prediction$summary <- image_summary
  }
  return(images_from_prediction)
}
