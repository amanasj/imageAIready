# imageAIready


Set of functions which may be helpful for image manipulation prior to training a deep learning algorithm.

<br>

install using:

<br>

library(devtools)


install_github("amanasj/imageAIready")


library(imageAIready)

<br>



#################################################################################################
####################################### Example useage ##########################################
#################################################################################################

#############################################################
#############################################################
#devtools::install_github("amanasj/imageAIready", force=T)
library(imageAIready)
library(readheyexxml)
library(keras)
##############################################################
##############################################################


##############################################################
################# input patient file below ###################
##############################################################
patient_folder <- ""
timepoint <- ""
eye <- "OD"
###########################
### filepath to patient 
###########################
filepath <- paste0("",
                   patient_folder,"\\",timepoint)
### file path for OD or OS images
images_path <- file.path(paste0(filepath,"\\",eye))
###############################################################






#----------------------------------------------------------------------
#----------------------------------------------------------------------
#             apply a load of my custom imageAIready packages
#----------------------------------------------------------------------
#----------------------------------------------------------------------
#
#
#
#
#
#
#
#
#
#############################################################################################
################### read heyex xml folder along with metadata ###############################
#############################################################################################
readheyexxml <- readheyexxml(images_path)
#readheyexxml[3]
#############################################################################################
#############################################################################################






###############################################################################
################################ resize images ################################
###############################################################################
resize <- imageAIready::resize(images_path, 
                               width = 1024, 
                               height = 512,
                               destin = dirname(images_path))
##############################################################################
##############################################################################





#############################################################################################
################## apply a bounding box function to remove black areas ######################
#############################################################################################
bbox <- imageAIready::bbox_crop(images_path = images_path, 
                                width = 1024, 
                                height = 512, 
                                heyex_xml_file = T,
                                destin = dirname(images_path))
############################################################################################
############################################################################################





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





#########################################################################################
########################### Mosaic patches back together ################################
########################################################################
patches_folder <- paste0(filepath,"/bboxcropped_images/",eye,"/cropped_images/AI_predictions/patches/")
mosaic <- imageAIready::mosaicR(patches_folder = patches_folder)
########################################################################################
########################################################################################





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




#################################################################################
####################### overlay ORT onto enface image  ##########################
#################################################################################
heyex_images_folder <- file.path(paste0(filepath,"\\",eye))
enfaceORTplot <- imageAIready::enfaceORTplot(ORT_data_F = ORT_data_F,
                                             heyex_images_folder = heyex_images_folder)
#################################################################################
#################################################################################




##################################################################################
###################### remove bbox and resize folders ############################
##################################################################################
root <- dirname(images_path)
unlink(file.path(paste0(root,"/bboxcropped_images/")), recursive = T)
unlink(file.path(paste0(root,"/resized_images/")), recursive = T)
##################################################################################
##################################################################################


