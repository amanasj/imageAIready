
###########################################################################################
############################ Patching program #############################################
###########################################################################################

patchifyR <- function(images_path, masks_path, patch_size=256, dir){

  # install and load raster
  if (!require("raster")){
    install.packages("raster")
    library(raster)
    suppressPackageStartupMessages({library(raster)})
    }

  
  dir.create(paste0(dir, "/patched_images/"))
  img_output_directory <- paste0(dir, "/patched_images/images/")
  dir.create(img_output_directory)
  mask_output_directory <- paste0(dir, "/patched_images/masks/")
  dir.create(mask_output_directory) 
  
  
##### load in images and masks
images <- list.files(images_path, full.names = T)
imgs_list <- list()
for(i in seq_along(images)){ 
  img = raster(images[i])
  imgs_list[[i]] <- img
}
masks <- list.files(masks_path, full.names = T)
masks_list <- list()
for(i in seq_along(masks)){ 
  mask = raster(masks[i])
  masks_list[[i]] <- mask 
  }




############## Patchify function ################
process_image <- function(input_images, patch_size){
  patchify_list <- list()
  for (k in 1:length(input_images)){
  img <- input_images[[k]]
  # create image divisible by the patch_size
  message(paste0("Cropping original image. ", "Making it divisible by ", patch_size, "."))
  x_max <- patch_size*trunc(nrow(img)/patch_size)
  y_max <- patch_size*trunc(ncol(img)/patch_size)
  img <- crop(img, extent(img, 1, x_max, 1, y_max))
  # initializers
  lx = 1; ly = 1; p = 1
  ls.patches <- list()
  ls.coordinates <- list()
  # extract patches
  for(i in 1:(nrow(img)/patch_size)){
    for(j in 1:(ncol(img)/patch_size)){
      ls.patches[[p]] <- crop(img, extent(img, lx, (lx+patch_size)-1, ly, (ly+patch_size)-1))
      filename <- basename(filename(img))
      filename <- tools::file_path_sans_ext(filename)
      ls.coordinates[[p]] <- paste0((filename),"_patchify_", p, "_(", i, ",", j, ")")
      message(paste0((filename),"_patchify_", p, "_(", i, ",", j, ")"))
      
      p = p + 1
      ly = ly + patch_size
    }
    ly = 1
    lx = lx + patch_size
  }
  
  patchify <- list("patches"=ls.patches, "names"=ls.coordinates)
    
  message("Successfully completed.")
    
  patchify_list[[k]] <- patchify
    
  }
  
  patchify_list
    
  }




############## run above function for my lists ##############
my_patches_img <- process_image(input_images=imgs_list, patch_size=patch_size) 
my_patches_mask <- process_image(input_images=masks_list, patch_size=patch_size)

############# print out patches ##################

for(i in 1:length(my_patches_img)){
  for(j in 1:length(my_patches_img[[i]]$patches)){
  writeRaster(my_patches_img[[i]]$patches[[j]], paste0(img_output_directory, my_patches_img[[i]]$names[[j]], ".tif"), 
              drivername="Gtiff", overwrite=TRUE, datatype='INT1U')
  writeRaster(my_patches_mask[[i]]$patches[[j]], paste0(mask_output_directory, my_patches_mask[[i]]$names[[j]], ".tif"), 
                drivername="Gtiff", overwrite=TRUE, datatype='INT1U')
  }
}



}











