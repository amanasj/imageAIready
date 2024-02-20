
#################################################################################################
####################  Simple predictions_overlay function  #########################
#################################################################################################

predictions_overlay <- function(images_folder, 
                                predictions, 
                                destin=dirname(dirname(images_folder))){
  
  
  # install and load magick
  if (!require("magick")){
    install.packages("magick")
    library(magick)
    suppressPackageStartupMessages({library(magick)})
  }
  # install and load tidyverse
  if (!require("tidyverse")){
    install.packages("tidyverse")
    library(tidyverse)
    suppressPackageStartupMessages({library(tidyverse)})
  }
  # install and load imager
  if (!require("imager")){
    install.packages("imager")
    library(imager)
    suppressPackageStartupMessages({library(imager)})
  }
  
  
    
    ## create a bunch of folders to store images, masks and overlays for patches
    predictions_folder <- paste0(destin, "/AI_predictions")
    dir.create(predictions_folder)

    dir.create(paste0(predictions_folder, "/patches"))
    prediction_patched_folder <- paste0(predictions_folder, "/patches") 
    
    dir.create(paste0(prediction_patched_folder, "/images"))
    prediction_patched_images_folder <- paste0(prediction_patched_folder, "/images") 
    
    dir.create(paste0(prediction_patched_folder, "/masks"))
    prediction_patched_masks_folder <- paste0(prediction_patched_folder, "/masks") 
    
    dir.create(paste0(prediction_patched_folder, "/overlay"))
    prediction_patched_overlay_folder <- paste0(prediction_patched_folder, "/overlay") 
    
    
    
    
    

    for (i in 1:length(predictions$summary$filename)){
    
    #i=2 #~~~~~ troubleshooting
    im_i <- paste0(images_folder, basename(predictions$summary$filename[i]), sep="")
    im_i <- image_read(im_i)
    w <- as.numeric(image_info(im_i)[2])
    h <- as.numeric(image_info(im_i)[3])
    pr <- predictions$prediction_binary[i]
    pr_white <- magick::image_transparent(pr, "white")
    pr <- magick::image_background(pr_white, "green", flatten = T)
    dimen <- as.character(paste0(w,"x",h,"!"))
    pr <- magick::image_resize(pr, dimen)
    #pr
    

    
    
    combine <- c(im_i, pr)
    magick::image_append(combine, stack = T)
    overlay <- combine %>% magick::image_composite(combine, operator = "plus", 
                                                   compose_args = "70%", gravity = "center")
    i_name <- basename(predictions$summary$filename[i]) 
    
    #predictions$prediction_binary[i]
    #overlay[2]
    
    
  
    image_write(predictions$image[i], format <- "tif", 
                path = paste0(prediction_patched_images_folder, "/", i_name, sep=""))
    image_write(predictions$prediction_binary[i], format <- "tif", 
                path = paste0(prediction_patched_masks_folder, "/", i_name, sep=""))
    image_write(overlay[2], format <- "tif", 
                path = paste0(prediction_patched_overlay_folder, "/", i_name, sep=""))
  }
  
    
  
    
  
}



###########################################################################################
###########################################################################################
############################### End of predictions_overlay ################################
###########################################################################################
###########################################################################################
