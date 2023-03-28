
##############################################################################
########### use bbox to find retina and crop everything else out ############
#############################################################################

##### Function to input x=images to crop  and z=corresponding masks to crop
bbox_crop <- function(image_path, mask_path, w=500, h=200, clean=1, fill=10, dir) {
  
  # install and load raster
  if(!require("raster")){
    install.packages("raster")
    library(raster)
    suppressPackageStartupMessages({library(raster)})
  }
  if(!require("EBImage")){
    install.packages("EBImage")
    library(EBImage)
    suppressPackageStartupMessages({library(EBImage)})
  }
  
  dir.create(paste0(dir, "/bboxcropped_images/"))
  dir.create(paste0(dir, "/bboxcropped_images/images/")) 
  
  #### use to temporarily suppress warnings arising from raster extent
  warn = getOption("warn")
  options(warn=-1)
   
#################### debugging line ####################
#  image <- file.path("C:\\Users\\ajosan\\OneDrive - Nexus365\\Desktop\\R_scripts\\U-net\\images\\training_images\\ORT_training\\train\\images_grey\\2AE7A320.tif")
########################################################
images <- list.files(image_path, full.names = T)
for (i in 1:length(images)){
xx <- raster(images[i])
filename_image <- basename(images[i])
xx <- as.cimg(xx) %>% plot()
px <- threshold(xx) %>% plot
px <- clean(px,clean) %>% imager::fill(fill)    ####### TWEAK this if retina not segmenting properly
plot(px)
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
min_x <- min(box$x)-1
max_x <- max(box$x)
min_y <- min(box$y)
max_y <- max(box$y)
#### crop image according to bbox y coords
cropped <- imager::imsub(xx, x>min_x & x<max_x+1, y>min_y-5 & y<max_y+1) %>% plot()
p <- as.raster(cropped) 
p <- plot(cropped)
p <- EBImage::resize(p, w=w, h=h)
p <- lidaRtRee::cimg2Raster(p)

writeRaster(p, paste0(dir,"/bboxcropped_images/images/", filename_image), overwrite=T, datatype='INT1U')




##################################################
###### now crop equivalent masks to same extent
##################################################
if(missing(mask_path)){print(paste0("You have no masks so only cropping the image: ", filename_image))}else{
masks <- list.files(mask_path, full.names = T)
zz <- raster(masks[i])
#plot(zz)
filename_mask <- basename(masks[i])
#### crop image according to bbox y coords
zz <- as.cimg(zz)
cropped <- imager::imsub(zz, x>min_x & x<max_x+1, y>min_y-5 & y<max_y+1) %>% plot()
q <- as.raster(cropped) 
q <- plot(cropped)
q <- EBImage::resize(q, w=w, h=h)
q <- lidaRtRee::cimg2Raster(q)
cat(paste("----------------------------",
          paste0("cropped image : ", filename_image),
          paste0("cropped mask  : ", filename_mask), 
          "----------------------------", "", sep="\n"))


dir.create(paste0(dir, "/bboxcropped_images/masks/")) 
writeRaster(q, paste0(dir, "/bboxcropped_images/masks/" ,filename_mask), overwrite=T, datatype='INT1U')



  }
options(warn=warn)
 
  }

}



