

##########################################################################################
######################## Mosaic all patches back together again ##########################
##########################################################################################

mosaic <- function(patched_images_folder_path, dir){
  
  # install and load raster
  if (!require("raster")){
    install.packages("raster")
    library(raster)
    suppressPackageStartupMessages({library(raster)})
  }
  
  
  img_output_directory <- paste0(dir, "/mosaicked_images/")
  dir.create(img_output_directory)
  
patch_list <- list.files(patched_images_folder_path, pattern = ".tif", full.names = T)


### identify common filenames to mosaic together
filenames <- basename(patch_list)
#splits each string into a list using "_" as a delimiter and returns the first element
filenames <- lapply(strsplit(filenames, "_"), "[", 1)
#filenames <- unique(filenames)
filenames <- unique(unlist(filenames))


for (i in length(filenames)){
patch_list_by_filename <- list.files(patched_images_folder_path, 
                                     pattern = paste0(filenames[i]),
                                     full.names = T)


list2 <- list()
for(j in 1:(length(patch_list_by_filename))){ 
  rx <- raster(patch_list_by_filename[j])
  list2[[j]] <- rx
  }


# mosaic them, plot mosaic & save output
list2$fun  <- max
rast.mosaic <- do.call(terra::mosaic, list2)
#plot(rast.mosaic,axes=F,legend=F,bty="n",box=FALSE)
writeRaster(rast.mosaic,filename=paste0(img_output_directory,"/", filenames[i]), format="GTiff",datatype='INT1U',overwrite=TRUE)

  }

}
















