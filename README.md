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
### Example useage 
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

##############################################################
<br>
################# input patient file below ###################
<br>
##############################################################
<br>
patient_folder <- ""
<br>
timepoint <- ""
<br>
eye <- "OD"
<br>


<br>

###############################
<br>
####### filepath to patient 
<br>
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
#       apply a load of my custom imageAIready packages
<br>
#-------------------------------------------------------------


<br><br>

##########################################################
<br>
####### read heyex xml folder along with metadata ########
<br>
##########################################################
<br>
readheyexxml <- readheyexxml(images_path)
<br>
#readheyexxml[3]
<br>
#####################################################



<br><br>


#################################
<br>
######### resize images #########
<br>
#################################
<br>
resize <- imageAIready::resize(images_path, 
  <br>
                               width = 1024, 
  <br>
                               height = 512,
  <br>
                               destin = dirname(images_path))
  <br>
##########################################################



<br><br>


#############################################################################################
<br>
################## apply a bounding box function to remove black areas ######################
<br>
#############################################################################################
<br>
bbox <- imageAIready::bbox_crop(images_path = images_path, 
<br>
                                width = 1024, 
<br>
                                height = 512, 
<br>                                
                                heyex_xml_file = T,
<br>                                
                                destin = dirname(images_path))
<br>
############################################################################################



<br>


#####################################################################################
############################### split into patches ##################################
#####################################################################################
bbox_images_folder <- paste0(filepath, "\\bboxcropped_images\\",eye,"\\cropped_images\\images\\")
patches <- imageAIready::patchifyR(images_path = bbox_images_folder,
                                   patch_size = 256,
                                   heyex_xml_file = F,
                                   destin = dirname(bbox_images_folder))

#####################################################################################
#####################################################################################


<br>


###########################################################################################
#################################### AI predictions #######################################
###########################################################################################
##### Load in images to test 
bbox_images_folder <- paste0(filepath, "\\bboxcropped_images\\",eye,"\\cropped_images\\image_patches\\images\\")
images <- imageseg::loadImages(bbox_images_folder)
images <- imageseg::imagesToKerasInput(images, type = "image", grayscale = F)
model <- keras::load_model_hdf5("C:\\Users\\ajosan\\OneDrive - Nexus365\\Desktop\\R_scripts\\Unet_ort\\Rscripts\\trained_models\\ort_model_unet_from_scratch.hdf5", compile = F)

###  NOTE: imageSegementation from imageseg package not working for me, so edited package
###        by adding .ragged=TRUE and saved new function as v2
predictions <- imageAIready::imageSegmentation_v2(model=model, x=images, threshold = 0.9)
#predictions
############################################################################################
############################################################################################


<br>


###########################################################################################################
###################### save predicted images as overlay images using ######################################
######################      the predictions_overlay function         ######################################
###########################################################################################################
images_folder <- paste0(filepath, "\\bboxcropped_images\\",eye,"\\cropped_images\\image_patches\\images\\")
ORT <- imageAIready::predictions_overlay(images_folder=images_folder, 
                                         predictions=predictions, 
                                         destin = dirname(dirname(images_folder)))
###########################################################################################################
###########################################################################################################


<br>


#########################################################################################
########################### Mosaic patches back together ################################
########################################################################
patches_folder <- paste0(filepath,"/bboxcropped_images/",eye,"/cropped_images/AI_predictions/patches/")
mosaic <- imageAIready::mosaicR(patches_folder = patches_folder)
########################################################################################
########################################################################################


<br>


###############################################################################################
##################### Find ORT positions directly from predictions ############################
###############################################################################################
heyex_images_folder <- file.path(paste0(filepath,"\\",eye))
bbox_full_images_folder <- paste0(filepath, "\\bboxcropped_images\\",eye,"\\cropped_images\\images\\")
ORT_data_F    <-  imageAIready::findORT(predictions,
                                        heyex_images_folder = heyex_images_folder,
                                        bbox_full_images_folder = bbox_full_images_folder,
                                        ORT_size_min = 200)

save(ORT_data_F, file = paste0(heyex_images_folder, "//ORT_data_F.Rdata"))
##############################################################################################
##############################################################################################


<br>


#################################################################################
####################### overlay ORT onto enface image  ##########################
#################################################################################
heyex_images_folder <- file.path(paste0(filepath,"\\",eye))
enfaceORTplot <- imageAIready::enfaceORTplot(ORT_data_F = ORT_data_F,
                                             heyex_images_folder = heyex_images_folder)
#################################################################################
#################################################################################


<br>


##################################################################################
###################### remove bbox and resize folders ############################
##################################################################################
root <- dirname(images_path)
unlink(file.path(paste0(root,"/bboxcropped_images/")), recursive = T)
unlink(file.path(paste0(root,"/resized_images/")), recursive = T)
##################################################################################
##################################################################################


<br><br>
