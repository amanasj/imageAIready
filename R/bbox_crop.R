
##############################################################################
########### use bbox to find retina and crop everything else out ############
#############################################################################

##### Function to input x=images to crop  and z=corresponding masks to crop
bbox_crop <- function(images_path, 
                      masks_path, 
                      width=500, 
                      height=200, 
                      clean=1, 
                      fill=10, 
                      destin = dirname(images_path),
                      heyex_xml_file = FALSE) {
  
  
  
  # install and load raster
  if(!require("raster")){
    install.packages("raster")
    library(raster)
    suppressPackageStartupMessages({library(raster)})
  }
  # install and load EBImage
  if (!require("EBImage")){
    if (!requireNamespace("BiocManager", quietly = TRUE))
      install.packages("BiocManager")
    BiocManager::install("EBImage")
    library(EBImage)
    suppressPackageStartupMessages({library(EBImage)})
  }
  # install and load xml2
  if(!require("xml2")){
    install.packages("xml2")
    library(xml2)
    suppressPackageStartupMessages({library(xml2)})
  }
  # install and load tidyverse
  if(!require("tidyverse")){
    install.packages("tidyverse")
    library(tidyverse)
    suppressPackageStartupMessages({library(tidyverse)})
  }
  # install and load imager
  if(!require("imager")){
    install.packages("imager")
    library(imager)
    suppressPackageStartupMessages({library(imager)})
  }
  
  
  
  eye <- substring(images_path, nchar(images_path)-1)
  
  dir.create(paste0(destin, "/bboxcropped_images/"))
  dir.create(paste0(destin, "/bboxcropped_images/", eye, "/"))
  dir.create(paste0(destin, "/bboxcropped_images/",eye,"/cropped_images/")) 
  dir.create(paste0(destin, "/bboxcropped_images/",eye,"/cropped_images/images/"))
  
  
  #### use to temporarily suppress warnings arising from raster extent
  warn = getOption("warn")
  options(warn=-1)
  
  
  
  
  
  
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
      img = raster(images[i])
      imgs_list[[i]] <- images
    }
    
    
  }else{
  
  
  images <- list.files(images_path, full.names = T)
  
  }
  

  
  
  for (i in 1:length(images)){
    #i=1
    xx <- suppressWarnings(raster(images[i])) 
    filename_image <- basename(images[i])
    xx <- suppressWarnings(as.cimg(xx)) %>% plot()
    px <- threshold(xx) #%>% plot
    px <- clean(px,clean) %>% imager::fill(fill)    ####### TWEAK this if retina not segmenting properly
    #plot(px)
    px <- px > 0.1
    sp <- split_connected(px) #returns an imlist 
    ### find the largest contiguous pixset (retina) and fit a bounding box
    size_df <- function(Data) {
      size <- sum(Data, na.rm = TRUE)
      size <- cbind.data.frame(size)
    }
    df <- lapply(sp, size_df)
    df <- do.call(rbind.data.frame, df)
    largest <- apply(df, 2, which.max)
    largest <- as.numeric(largest)
    bbox <- imager::bbox(sp[[largest]]) 
    bbox %>% imager::highlight(col="yellow")
    box <- where(bbox)
    min_x <- 0          #min(box$x)
    max_x <- nrow(xx)   #max(box$x)
    min_y <- min(box$y)
    max_y <- max(box$y)
    #### crop image according to bbox y coords
    #cropped <- imager::imsub(xx, x>min_x & x<max_x+1, y>min_y-5 & y<max_y+1) %>% plot()
    cropped <- imager::imsub(xx, y>min_y-5 & y<max_y+1) %>% plot()
    p <- as.raster(cropped) 
    p <- plot(cropped)
    p <- EBImage::resize(p, w=width, h=height)
    p <- lidaRtRee::cimg2Raster(p)

    
    writeRaster(p, paste0(destin,"/bboxcropped_images/", eye, "/cropped_images/images/", filename_image), 
                overwrite=T, 
                datatype='INT1U')
    
    
    
    
    ##################################################
    ###### now crop equivalent masks to same extent
    ##################################################
    if(missing(masks_path)){print(paste0("You have no masks so only cropping the image: ", filename_image))}else{
      masks <- list.files(masks_path, full.names = T)
      zz <- raster(masks[i])
      #plot(zz)
      filename_mask <- basename(masks[i])
      #### crop image according to bbox y coords
      zz <- as.cimg(zz)
      #cropped <- imager::imsub(zz, x>min_x & x<max_x+1, y>min_y-5 & y<max_y+1) %>% plot()
      cropped <- imager::imsub(zz, y>min_y-5 & y<max_y+1) %>% plot()
      q <- as.raster(cropped) 
      q <- plot(cropped)
      q <- EBImage::resize(q, w=width, h=height)
      q <- lidaRtRee::cimg2Raster(q)
      cat(paste("----------------------------",
                paste0("cropped image : ", filename_image),
                paste0("cropped mask  : ", filename_mask), 
                "----------------------------", "", sep="\n"))
      
      
      dir.create(paste0(destin, "/bboxcropped_images/", eye, "/masks/")) 
      writeRaster(q, paste0(destin, "/bboxcropped_images/", eye, "/masks/" ,filename_mask), overwrite=T, datatype='INT1U')
      
      
      
    }
    
    ## turn global warnings back on
    options(warn=warn)
    
  }
  
}




