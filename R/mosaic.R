
##########################################################################################
######################## Mosaic all patches back together again ##########################
##########################################################################################

mosaic <- function(patched_images_folder, dir=dirname(patched_images_folder)){
  
  # install and load raster
  if (!require("raster")){
    install.packages("raster")
    library(raster)
    suppressPackageStartupMessages({library(raster)})
  }
  # install and load terra
  if (!require("terra")){
    install.packages("terra")
    library(terra)
    suppressPackageStartupMessages({library(terra)})
  }
  
  
  img_output_directory <- paste0(dir, "/mosaicked_images/")
  dir.create(img_output_directory)
  
  patch_list <- list.files(patched_images_folder, pattern = ".tif", full.names = T)
  
  
  ### identify common filenames to mosaic together
  filenames <- basename(patch_list)
  #splits each string into a list using "_" as a delimiter and returns the first element
  filenames0 <- lapply(strsplit(filenames, "_"), "[", 1)
  #filenames <- unique(filenames)
  filenames0 <- unique(unlist(filenames0))
  
  
  for (i in length(filenames)){
    #i=1
    patch_list_by_filename <- list.files(patched_images_folder, 
                                         pattern = paste0(filenames0[i]),
                                         full.names = T)
    
    
    list2 <- list()
    for(j in 1:8){#(length(patch_list_by_filename))){ 
      #j=8
      rx <- raster(patch_list_by_filename[j])
      list2[[j]] <- rx
      ## extract the patch position
      library(stringr)
      position <- str_extract_all(basename(patch_list_by_filename[j]), 
                              ('(?<=\\(|,)[0-9]+(?=\\)|-?)'))[[1]] 
      row_no <- as.numeric(position[1])
      col_no <- as.numeric(position[2])
      extent(list2[[j]]) <- extent(c((col_no-1)*256, (col_no)*256, (-row_no-1)*256, (-row_no)*256))
    }

    # mosaic them, plot mosaic & save output
    list2$fun  <- max
    rast.mosaic <- do.call(terra::mosaic, list2)
    plot(rast.mosaic, axes=F, legend=F, bty="n", box=FALSE)
    writeRaster(rast.mosaic, filename=paste0(img_output_directory,"/", filenames0[i]), 
                format="GTiff", datatype='INT1U', overwrite=TRUE)
    
  
  }
  
}
