
#################################################################################################
####################  Simple predictions_overlay function  #########################
#################################################################################################

predictions_overlay <- function(images_folder, predictions, dir=dirname(images_folder)){
  for (i in 1:length(predictions$summary$filename)){
    #i=2
    dir.create(paste0(dir, "/AI_predictions"))
    predictions_folder <- paste0(dir, "/AI_predictions") 
    im_i <- paste0(images_folder, basename(predictions$summary$filename[i]), sep="")
    im_i <- image_read(im_i)
    w <- as.numeric(image_info(im_i)[2])
    h <- as.numeric(image_info(im_i)[3])
    pr <- predictions$prediction_binary[i]
    pr_white <- magick::image_transparent(pr, "white")
    pr <- magick::image_background(pr_white, "green", flatten = T)
    dimen <- as.character(paste0(w,"x",h,"!"))
    pr <- magick::image_resize(pr, dimen)
    combine <- c(im_i, pr)
    magick::image_append(combine, stack = T)
    overlay <- combine %>% magick::image_composite(combine, operator = "plus", 
                                                   compose_args = "70%", gravity = "center")
    i_name <- basename(out$summary$filename[i]) 
    image_write(overlay[2], format <- "tif", path = paste0(predictions_folder, "/", i_name, sep=""))
  }
  
}

###########################################################################################
###########################################################################################
############################### End of predictions_overlay ################################
#############

