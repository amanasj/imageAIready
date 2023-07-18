
##########################################################################################
######################## Mosaic all patches back together again ##########################
##########################################################################################

mosaicR <- function(patches_folder, 
                    destin=dirname(patches_folder))
  {
  
  
  
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
  # install and load tidyverse
  if (!require("tidyverse")){
    install.packages("tidyverse")
    library(tidyverse)
    suppressPackageStartupMessages({library(tidyverse)})
  }
  # install and load magick
  if (!require("magick")){
    install.packages("magick")
    library(magick)
    suppressPackageStartupMessages({library(magick)})
  }
  # install and load imager
  if (!require("imager")){
    install.packages("imager")
    library(imager)
    suppressPackageStartupMessages({library(imager)})
  }
  
  
  
  

  ## create a bunch of folders to store images, masks and overlays for mosaicked images
  dir.create(paste0(destin, "/full_images/"))
  predictions_full_folder <- paste0(destin, "/full_images/") 
  
  dir.create(paste0(predictions_full_folder, "images/"))
  predictions_full_images_folder <- paste0(predictions_full_folder, "images/") 
  
  dir.create(paste0(predictions_full_folder, "masks/"))
  predictions_full_masks_folder <- paste0(predictions_full_folder, "masks/") 
  
  dir.create(paste0(predictions_full_folder, "overlay/"))
  predictions_full_overlay_folder <- paste0(predictions_full_folder, "overlay/") 
  
  
  
  
  
  mosaic_all <- function(folder=folder, destination=destination, mask=mask){
    
    
      patches_list <- list.files(folder, pattern = ".tif", full.names = T)
  
  
  ### identify common filenames to mosaic together
  filenames <- basename(patches_list)
  #splits each string into a list using "_" as a delimiter and returns the first element
  filenames0 <- lapply(strsplit(filenames, "_"), "[", 1)
  #filenames <- unique(filenames)
  filenames0 <- unique(unlist(filenames0))
  
  
  
  
##### create lists for later use

  pr_images <- list()

  
  
#### cycle through all images
  for (i in 1:length(filenames0)){        ### cycles through each patient 
    i#=2
    patch_list_by_filename <- list.files(folder, 
                                         pattern = paste0(filenames0[i]),
                                         full.names = T)
    
    

  list_temp <- list()
    for(j in 1:(length(patch_list_by_filename))){   ### cycles through each image patch for patient
      #j=3
  
  

  rx <- suppressWarnings(raster::brick(patch_list_by_filename[j]))
  if(rx@file@nbands==4){
    rx <- suppressWarnings(raster::brick(rx[[1]],rx[[2]],rx[[3]]))
    }else{
      rx <- suppressWarnings(raster::brick(rx[[1]]))
    }
      
      list_temp[[j]] <- rx
      ## extract the patch position
      position <- stringr::str_extract_all(basename(patch_list_by_filename[j]), 
                              ('(?<=\\(|,)[0-9]+(?=\\)|-?)'))[[1]] 
      row_no <- as.numeric(position[1])
      col_no <- as.numeric(position[2])
      raster::extent(list_temp[[j]]) <- raster::extent(c((col_no-1)*256, (col_no)*256, (-row_no-1)*256, (-row_no)*256))

      
      
    }


  

    # mosaic them, plot mosaic & save output
    list_temp$fun  <- max
    rast.mosaic <- suppressWarnings(do.call(terra::mosaic, list_temp))
    
    #rast.mosaic
    
    terra::writeRaster(rast.mosaic, filename=paste0(destination, filenames0[i]), 
                overwrite=TRUE, datatype='INT1U', format="GTiff")
    
    
      
    
    
    # create a grayscale color palette to use for the image.
    grayscale_colors <- gray.colors(100,            # number of different color levels 
                                    start = 0.0,    # how black (0) to go
                                    end = 1.0,      # how white (1) to go
                                    gamma = 1,    # correction between how a digital 
                                    # camera sees the world and how human eyes see it
                                    alpha = NULL)   #Null=colors are not transparent
    pr_images[[i]] <- rast.mosaic
    
    if(rast.mosaic@class[1]=="RasterBrick"){
      pr_images[[i]] <- rast.mosaic
      terra::plotRGB(pr_images[[i]])
    }
    
  
    


    
    }

  
      
  }


  
  ###patches_folder <- "C:\\Users\\ajosan\\OneDrive - Nexus365\\Desktop\\R_scripts\\U-net\\images\\potential_images\\CHM_scans\\19.RS80\\timepoint\\bboxcropped_images\\patches_folder\\AI_predictions\\patches"
  patched_images_folder <- paste0(patches_folder, "images/")
  patched_overlay_folder <- paste0(patches_folder, "overlay/")
  patched_masks_folder <- paste0(patches_folder, "masks/")
  
  mosaic_all(folder = patched_images_folder, destination = predictions_full_images_folder, mask=FALSE)
  mosaic_all(folder = patched_overlay_folder, destination = predictions_full_overlay_folder, mask=FALSE)
  mosaic_all(folder = patched_masks_folder, destination = predictions_full_masks_folder, mask=TRUE)

  

  
}

