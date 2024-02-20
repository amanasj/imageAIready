
#############################################################################
######################## Find ORT  ##########################
#############################################################################


findORT <- function(predictions,
                    heyex_images_folder, 
                    bbox_full_images_folder,
                    ORT_size_min = 100){
  
  
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
  # install and load imager
  if (!require("sp")){
    install.packages("sp")
    library(sp)
    suppressPackageStartupMessages({library(sp)})
  }
  
  
    
  
  
  ##### create lists for later use
  ORT <- list()
  ORT_df <- data.frame()
  ORT_DF <- data.frame()
  ORT_data_F <- list()
    

  
#### cycle through all images

  for (i in 1:length(predictions$summary$filename)){        ### cycles through all patches
        #i=4 #troubleshooting

      
      ################################################################
      #################### find ORT positions ########################
        
        ################ find location of binary ORT
        img <- magick::image_read(predictions$summary$filename[i])
        binary <- magick::image_read(predictions$prediction_binary[[i]])
        filei <- basename(predictions$summary$filename[i])
        ExamURL <- stringr::str_extract(filei, "[^_]+")
        ExamURL <- paste0(ExamURL, ".tif")
        ExamURL_full <- paste0(heyex_images_folder, "\\", ExamURL)
        ### find how wide original image was
        meta_orig <- magick::image_read(ExamURL_full)
        w_orig <- as.numeric(magick::image_info(meta_orig)[2])
        h_orig <- as.numeric(magick::image_info(meta_orig)[3])
        ExamURL_bbox <- paste0(bbox_full_images_folder, ExamURL)
        meta_bbox <- magick::image_read(ExamURL_bbox)
        w_bbox <- as.numeric(magick::image_info(meta_bbox)[2])
        h_bbox <- as.numeric(magick::image_info(meta_bbox)[3])
        px <- as.raster(binary)
        px <- suppressWarnings(imager::as.cimg(px)) %>% plot()
        px <- threshold(px, thr = "95%") %>% plot
        px <- px>0.1
        w <- as.numeric(magick::image_info(img)[2])
        h <- as.numeric(magick::image_info(img)[3])
        if (sum(px)==0) {
          ORT[i] <- list(list(list(c(0,0,0))))
        } else { 
          sp <- imager::split_connected(px)
            if(length(sp)!=0){
          ### loop over all split connected regions (masks) to apply bounding box to each
          ORT_coords_bbox <- list()
          ORT_coords_bbox_temp <- list() 
          ORT_coords_temp <- list() 
          ORT_coords <- list()
          for (k in 1:length(sp)){  
            #k=1   #troubleshooting
            highlight(sp[[k]], col="yellow")
            #imager::bbox(sp[[k]]) %>% highlight(col="yellow")
            box <- where(imager::bbox(sp[[k]]))
            box <- box[c(box$cc==1),]
            box_width <- max(box$x) - min(box$x)
            box_height <- max(box$y) - min(box$y)
            box_size <- box_width * box_height
            if(is.null(ORT_size_min)==TRUE || box_size > ORT_size_min){
            box_x_centre <- min(box$x) + ((max(box$x) - min(box$x)) / 2)
            box_y_centre <- min(box$y) + ((max(box$y) - min(box$y)) / 2)
            }else{box_x_centre <- NA
                  box_y_centre <- NA}
          
          ### isolate patch position
          # Get the parenthesis and what is inside
          brackets <- stringr::str_extract(filei, "(?<=\\().*(?=\\))")
          brackets <- scan(text = brackets, sep = ",", what = "")
          brackets <- as.numeric(brackets)
          patch_vert <- brackets[1]
          patch_horiz <- brackets[2]
          ### infer no. of tiles horiz and vert from the top left (remember images were possibly resized
          ### so figures won't necessarily be integer values - so round off)
          tiles_horiz <- w_bbox / w 
          tiles_vert <-  h_bbox / h
          ### so ORT position in overall image given by
          ORT_horiz_bbox <- ((w_bbox/tiles_horiz)*(patch_horiz-1))+box_x_centre
          ORT_vert_bbox <- ((h_bbox/tiles_vert)*(patch_vert-1))+box_y_centre
          ORT_horiz_orig <- (ORT_horiz_bbox/w_bbox) * w_orig
          ORT_vert_orig <-  (ORT_vert_bbox/h_bbox) * h_orig
          ORT_coords_one <- cbind(file=ExamURL, x=ORT_horiz_orig, y=ORT_vert_orig)
          ORT_coords_temp <- list(ORT_coords_one)
          ORT_coords_temp <- ORT_coords_temp[lapply(ORT_coords_temp,length)>0]
          

          ORT_coords[k] <- list(ORT_coords_temp) 
          
                    }    ## loop over k ORTs per patch   
      
               ORT[i] <- list(ORT_coords) 
            }else{ORT[i] <- list(list(list(c(0,0,0))))}
          } 
          

  


  ORT_df <- data.frame(matrix(unlist(ORT), nrow=sum(lengths(ORT)), byrow=TRUE))
  colnames(ORT_df) <- c("ExamURL", "ORT_x","ORT_y")
  ORT_df[2:3] <- sapply(ORT_df[2:3],as.numeric)

      
      
      } ## loop over i patches
  
  

  ORT_DF <- ORT_df
  ### remove blank or NA or zero rows
  ORT_DF[ORT_DF == ""] <- NA
  ORT_DF <- na.omit(ORT_DF)
  ORT_DF <- ORT_DF[ORT_DF$ExamURL != 0, ]

  
  image_dat <- cbind(x=w_orig, y=h_orig)
  
  ORT_data_F <- list(ORT_coords=ORT_DF, image_data=image_dat)
  
  
  
  return(ORT_data_F)
  
  
} ## end findORT function 

