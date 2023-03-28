rm(list = ls(all = TRUE))
gc()
library(tidyverse)
library(imager)
library(here)
library(raster)




######################################################################################################
####################  Function to Greyscale, threshold then crop and resize  #########################
######################################################################################################



###############################################
#### use a single image
#img <- file.path("")
#mapply(img, FUN=crop)
###############################################
###########################################
#### OR  loop over all images in folder
imgs = list.files(paste0(here(),"/images","/training_images","/ORT_training","/train","/images"), pattern=".tif", full.names=T)
masks = list.files(paste0(here(),"/images","/training_images","/ORT_training","/train","/masks"), pattern=".tif", full.names=T)
###########################################





#####
####
##
#
#
#
############################################### bounding box ##########################################################
###########################################################################################################
####  if arguments not included the defaults to: masks=NULL, w=500, h=200, clean=1, fill=10
####  Arguments: "Clean" and "fill":  Cleaning up a pixel set here means removing small isolated elements (speckle)
####  Filling in means removing holes. 
###   set desired width and height of cropped images along with clean and fill arguments for thresholding
w=1000
h=500
clean=1
fill=10

######################################################
#### call my function to crop image to remove everything but the retina
source(paste0(here(), "/Rscripts/bounding_box.R"))
######################################################

#imgs <- imgs[c(1:5)]
#masks <- masks[c(1:5)]

mapply(imgs, masks, w=w, h=h, clean=clean, fill=fill, FUN = crop)

###########################################################################################################
###########################################################################################################







##############
##############
##############





############################################### patchify ####################################################################
train_images = list.files(paste0(here(),"/cropped_images"), pattern="tif", full.names=T)
train_masks = list.files(paste0(here(),"/cropped_masks"), pattern="tif", full.names=T)



#### set desired patch size
patch_size=200

######################################################
#### call my function to split image into patches ready for training 
source(paste0(here(), "/Rscripts/patchifyR.R"))
######################################################

##### arguments are "training images", "training mask images" and "patch size" 
mapply(train_images[[7]], train_masks[[7]], patch_size=patch_size, FUN = patchifyR)





#############################################################################################################################








