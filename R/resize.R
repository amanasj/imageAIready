######################################################################################################
####################  Simple resize function  #########################
######################################################################################################


resize <- function(images_path, 
                   masks_path, 
                   dir=dirname(images_path), 
                   height=256, 
                   width=256)  {
  
  
  
  # install and load raster
  if(!require("raster")){
    install.packages("raster")
    library(raster)
    suppressPackageStartupMessages({library(raster)})
  }
  # install and load raster
  if(!require("magick")){
    install.packages("magick")
    library(magick)
    suppressPackageStartupMessages({library(magick)})
  }
  
  

  
  resized_folder <- paste0(dir, "/resized_images/") 
  dir.create(paste0(resized_folder))
  resized_images_folder <- paste0(dir, "/resized_images/images/")
  dir.create(paste0(resized_images_folder)) 
  if(missing(mask_path)){}else{
  resized_masks_folder <- paste0(dir, "/resized_images/masks/")
  dir.create(paste0(resized_masks_folder)) 
  }
  
#filepath <- file_path_as_absolute(dir)

new_size <- paste0(width, "x", height, "!") 



img_list <- list.files(images_path, full.names = TRUE, pattern = ".tif")
if(missing(mask_path)){}else{
msk_list <- list.files(masks_path, full.names = TRUE, pattern = ".tif")
}


#### resize images or masks and save in new respective folders
for (z in 1:length(img_list)){
  filename <- basename(img_list[[z]])
  img <- image_read(img_list[[z]])
  resized_img <- image_resize(img, new_size)
  image_write(resized_img, format <- "tif", path=paste0(resized_images_folder, "/", filename))
}

if(missing(mask_path)){}else{
for (q in 1:length(msk_list)){
  filename <- basename(msk_list[[q]])
  msk <- image_read(msk_list[[q]], strip = TRUE)
  resized_mask <- image_resize(msk, new_size)
  image_write(resized_mask, depth = 16, format <- "tif", path=paste0(resized_masks_folder, "/",filename))
 }
}

}
###########################################################################################
###########################################################################################
################################### End of resize #########################################
#############

