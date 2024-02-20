# imageAIready


Set of functions which may be helpful for image manipulation prior to training a deep learning algorithm.

<br>

install using:

<br>

library(devtools)


install_github("amanasj/imageAIready")


library(imageAIready)

<br><br><br>




############################
## Example useage 
############################

<br><br>

################################################
<br>
#devtools::install_github("amanasj/imageAIready", force=T)
<br>
library(imageAIready)
<br>
library(readheyexxml)
<br>
library(keras)
<br>
################################################

<br><br>


#### input patient file below 
##############################################################
<br>
patient_folder <- ""
<br>
timepoint <- ""
<br>
eye <- "OD"
<br>


<br>


#### filepath to patient 
###############################

<br>
filepath <- paste0("", patient_folder,"\\",timepoint)
<br>
### file path for OD or OS images
<br>
images_path <- file.path(paste0(filepath,"\\",eye))
<br>
#############################################################


<br><br>




#-------------------------------------------------------------
<br>
###   apply a load of my custom imageAIready packages
<br>
#-------------------------------------------------------------


<br><br>


#### read heyex xml folder along with metadata 
##########################################################
<br>
readheyexxml <- readheyexxml(images_path)
<br>
#readheyexxml[3]
<br>
#####################################################



<br><br>



#### resize images 
#################################
<br>
resize <- imageAIready::resize(images_path,  width = 1024, height = 512, destin = dirname(images_path))
<br>
##########################################################



<br><br>



#### apply a bounding box function to remove black areas 
###########################################################################
<br>
bbox <- imageAIready::bbox_crop(images_path = images_path, width = 1024, height = 512, heyex_xml_file = T, destin = dirname(images_path))
<br>
############################################################################



<br><br>



#### split into patches 
##########################################
<br>
bbox_images_folder <- paste0(filepath, "\\bboxcropped_images\\",eye,"\\cropped_images\\images\\")
<br>
patches <- imageAIready::patchifyR(images_path = bbox_images_folder, patch_size = 256, heyex_xml_file = F, destin = dirname(bbox_images_folder))
<br>
###################################################################



<br><br>



#### AI predictions 
#################################
<br>

###### Load in images to test 
<br>
bbox_images_folder <- paste0(filepath, "\\bboxcropped_images\\",eye,"\\cropped_images\\image_patches\\images\\")
<br>
images <- imageseg::loadImages(bbox_images_folder)
<br>
images <- imageseg::imagesToKerasInput(images, type = "image", grayscale = F)
<br>
model <- keras::load_model_hdf5("", compile = F)
<br>
  
######  (NOTE: imageSegementation from imageseg package not working for me, so edited package by adding .ragged=TRUE and saved new function as v2)

<br>

predictions <- imageAIready::imageSegmentation_v2(model=model, x=images, threshold = 0.9)
<br>
#####################################################################



<br><br>



#### save predicted images as overlay images using the predictions_overlay function    
######################################################################################
<br>
images_folder <- paste0(filepath, "\\bboxcropped_images\\",eye,"\\cropped_images\\image_patches\\images\\")
<br>
ORT <- imageAIready::predictions_overlay(images_folder=images_folder, predictions=predictions, destin = dirname(dirname(images_folder)))
<br>                                         
#######################################################################################


<br><br>



#### Mosaic patches back together 
##################################################
<br>
patches_folder <- paste0(filepath,"/bboxcropped_images/",eye,"/cropped_images/AI_predictions/patches/")
<br>
mosaic <- imageAIready::mosaicR(patches_folder = patches_folder)
<br>
#######################################################


<br><br>



#### Find ORT positions directly from predictions 
##############################################################
<br>
heyex_images_folder <- file.path(paste0(filepath,"\\",eye))
<br>
bbox_full_images_folder <- paste0(filepath, "\\bboxcropped_images\\",eye,"\\cropped_images\\images\\")
<br>
ORT_data_F    <-  imageAIready::findORT(predictions, heyex_images_folder = heyex_images_folder, bbox_full_images_folder = bbox_full_images_folder, ORT_size_min = 200)
<br>
save(ORT_data_F, file = paste0(heyex_images_folder, "//ORT_data_F.Rdata"))
<br>
#################################################################


<br><br>



#### overlay ORT onto enface image  
#####################################################
<br>
heyex_images_folder <- file.path(paste0(filepath,"\\",eye))
<br>
enfaceORTplot <- imageAIready::enfaceORTplot(ORT_data_F = ORT_data_F, heyex_images_folder = heyex_images_folder)
<br>
######################################################


<br><br>



#### remove bbox and resize folders 
################################################
<br>
root <- dirname(images_path)
<br>
unlink(file.path(paste0(root,"/bboxcropped_images/")), recursive = T)
<br>
unlink(file.path(paste0(root,"/resized_images/")), recursive = T)
<br>
#####################################################

<br>

<br><br>
