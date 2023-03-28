

######################################################################################################
####################  Simple resize function  #########################
######################################################################################################


resize <- function(image_path, mask_path, dir, height=256, width=256){
  
  # install and load raster
  if(!require("raster")){
    install.packages("raster")
    library(raster)
    suppressPackageStartupMessages({library(raster)})
  }

  
  resized_folder <- paste0(dir, "/resized_images/") 
  dir.create(paste0(resized_folder))
  resized_images_folder <- paste0(dir, "/resized_images/images/")
  dir.create(paste0(resized_images_folder)) 
  resized_masks_folder <- paste0(dir, "/resized_images/masks/")
  dir.create(paste0(resized_masks_folder)) 

  
#filepath <- file_path_as_absolute(dir)

new_size <- paste0(width, "x", height, "!") 



#### resize images or masks and save in new respective folders
for (z in 1:length(images_path)){
  #z=1
  resized_img <- image_read(images_path$info$filename[z])
  resized_img <- image_resize(resized_img, new_size)
  image_write(resized_img, format <- "tif", path=paste0(resized_images_folder, "/", images_filenames[z]))
}

for (q in 1:length(mask_path)){
  #q=1
  resized_mask <- image_read(mask_path$info$filename[q], strip = T)
  resized_mask <- image_resize(resized_mask, new_size)
  image_write(resized_mask, depth = 16, format <- "tif", path=paste0(resized_masks_folder, "/",images_filenames[q]))
}


}
###########################################################################################
###########################################################################################
################################### End of resize #########################################
#############

