
###########################################################################################
############################ Patching program #############################################
###########################################################################################

patchifyR <- function(images_path, 
                      masks_path, 
                      patch_size=256, 
                      destin=dirname(dirname(images_path)),
                      heyex_xml_file = FALSE){
  
  
  
  
  # install and load raster
  if (!require("raster")){
    install.packages("raster")
    library(raster)
    suppressPackageStartupMessages({library(raster)})
  }
  # install and load raster
  if (!require("xml2")){
    install.packages("xml2")
    library(xml2)
    suppressPackageStartupMessages({library(xml2)})
  }
  # install and load raster
  if (!require("tidyverse")){
    install.packages("tidyverse")
    library(tidyverse)
    suppressPackageStartupMessages({library(tidyverse)})
  }
  
  
  
  eye <- substring(images_path, nchar(images_path)-1)
  
  
  patches_folder <- paste0(destin, "/image_patches/")
  dir.create(patches_folder)
  img_output_directory <- paste0(patches_folder, "/images/")
  dir.create(img_output_directory)
    
  if(missing(masks_path)){}else{
  mask_output_directory <- paste0(patches_folder, "/masks/")
  dir.create(mask_output_directory)
  } 
  
  
  
  ### read the heyex xml file
  if (heyex_xml_file == TRUE) {
    file <- list.files(images_path, full.names = T, pattern = "\\.xml$")
    xml <- read_xml(file)
    ### get attributes from xml file
    ID = xml_find_all(xml, ".//Image/ID") %>% xml_text( "ID" )
    ExamURL = xml_find_all(xml, ".//Image/ImageData/ExamURL" ) %>%  xml_text( "ExamURL" )
    ## identify the 0th image - this is the enface image
    ExamURL_enface <- basename(ExamURL[c(1)])

    images <- list.files(images_path, full.names = T, pattern = ".tif")
    #### remove the enface image from the list
    to_be_deleted <- list.files(images_path, full.names = T, pattern = ExamURL_enface)
    images <- images[images != to_be_deleted]
    imgs_list <- list()
    for(i in seq_along(images)){ 
    img = suppressWarnings(raster(images[i]))
    imgs_list[[i]] <- img
    }
    if(missing(masks_path)){}else{
    masks <- list.files(masks_path, full.names = T)
    masks_list <- list()
    for(i in seq_along(masks)){ 
      mask = suppressWarnings(raster(masks[i]))
      masks_list[[i]] <- mask 
    }
  }
  
  }else{
    images <- list.files(images_path, full.names = T, pattern = ".tif")
    imgs_list <- list()
    for(i in seq_along(images)){ 
      img = suppressWarnings(raster(images[i]))
      imgs_list[[i]] <- img
    }
    if(missing(masks_path)){}else{
      masks <- list.files(masks_path, full.names = T)
      masks_list <- list()
      for(i in seq_along(masks)){ 
        mask = suppressWarnings(raster(masks[i]))
        masks_list[[i]] <- mask 
      }
    }
    
  }
  
  
  ############## Patchify function ################
  process_image <- function(input_images, patch_size){
    patchify_list <- list()
    for (k in 1:length(input_images)){
      #k=1
      img <- input_images[[k]]
      filename <- basename(img@file@name)
      filename <- tools::file_path_sans_ext(filename)
      
      ## create image divisible by the patch_size
      #message(paste0("WARNING: Cropping original image to make it divisible by ", patch_size, "."))
      #x_max <- patch_size*trunc(ncol(img)/patch_size)
      #y_max <- patch_size*trunc(nrow(img)/patch_size)
      #img <- crop(img, extent(0, x_max, 0, y_max))
      
      ## Stop and return error if not divisible by patch size this time. Cropping loses too much information
      if((ncol(img)/patch_size)%%1!=0){
        unlink(patches_folder, recursive = T)
        stop(paste0("\n \n ERROR: original image NOT divisible by ", 
                    patch_size, " - ", "Please resize images first using the resize() function", "."))}
      if((nrow(img)/patch_size)%%1!=0){
        unlink(patches_folder, recursive = T)
        stop(paste0("\n \n ERROR: original image NOT divisible by ", 
                    patch_size, " - ", "Please resize images first using the resize() function", "."))}
      
      
      # initializers
      lx = 1; ly = 1; p = 1
      ls.patches <- list()
      ls.coordinates <- list()
      # extract patches
      for(i in 1:(nrow(img)/patch_size)){
        for(j in 1:(ncol(img)/patch_size)){
          ls.patches[[p]] <- suppressWarnings(crop(img, extent(img, lx, (lx+patch_size)-1, ly, (ly+patch_size)-1)))
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
    if(missing(masks_path)){}else{
  my_patches_mask <- process_image(input_images=masks_list, patch_size=patch_size)
  }
  
  ############# print out patches ##################
  for(i in 1:length(my_patches_img)){
    for(j in 1:length(my_patches_img[[i]]$patches)){
      
      writeRaster(my_patches_img[[i]]$patches[[j]], 
                  paste0(img_output_directory, my_patches_img[[i]]$names[[j]], ".tif"), 
                  drivername="Gtiff", overwrite=TRUE, datatype='INT1U')

                if(missing(masks_path)){}else{

      writeRaster(my_patches_mask[[i]]$patches[[j]], 
                  paste0(mask_output_directory, my_patches_mask[[i]]$names[[j]], ".tif"), 
                  drivername="Gtiff", overwrite=TRUE, datatype='INT1U')
            
      }
    }
  }
  
  
  
}






