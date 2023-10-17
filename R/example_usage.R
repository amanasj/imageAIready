#############################################################
#############################################################
rm(list = ls(all = TRUE))
gc()
#devtools::install_github("amanasj/imageAIready", force=T)
library(imageAIready)
library(readheyexxml)
library(keras)
##############################################################
##############################################################




##############################################################
################# input patient file below ###################
##############################################################
patient_folder <- "19.RS80"
timepoint <- "timepoint"
eye <- "OD"
###########################
### filepath to patient 
###########################
filepath <- paste0("C:\\Users\\ajosan\\OneDrive - Nexus365\\Desktop\\R_scripts\\U-net\\images\\potential_images\\CHM_scans\\",
                   patient_folder,"\\",timepoint)
### file path for OD or OS images
images_path <- file.path(paste0(filepath,"\\",eye))
###############################################################
###############################################################











############
#######################################################################
############  apply a load of my custom imageAIready packages
#######################################################################
############


#####################################################################
######## read heyex xml folder along with metadata
#####################################################################
#source("C:\\Users\\ajosan\\OneDrive - Nexus365\\Desktop\\R_scripts\\readheyexxml\\Rscripts\\readheyexxml.R")
readheyexxml <- readheyexxml(images_path)
#readheyexxml[3]
#####################################################################
#####################################################################







#####################################################################
######## resize images
#####################################################################
#source("C:\\Users\\ajosan\\OneDrive - Nexus365\\Desktop\\R_scripts\\imageAIready\\resize.R")
resize <- imageAIready::resize(images_path, 
                 width = 1024, 
                 height = 512,
                 destin = dirname(images_path))
#####################################################################
#####################################################################







#####################################################################
######## apply a bounding box function to remove black areas
#####################################################################
#source("C:\\Users\\ajosan\\OneDrive - Nexus365\\Desktop\\R_scripts\\imageAIready\\bbox_crop.R")
bbox <- imageAIready::bbox_crop(images_path = images_path, 
                  width = 1024, 
                  height = 512, 
                  heyex_xml_file = T,
                  destin = "C:\\Users\\ajosan\\OneDrive - Nexus365\\Desktop\\R_scripts\\U-net")
#####################################################################
#####################################################################







#####################################################################
######## split into patches
#####################################################################
#source("C:\\Users\\ajosan\\OneDrive - Nexus365\\Desktop\\R_scripts\\imageAIready\\patchifyR.R")
new_images_path <- "C:\\Users\\ajosan\\OneDrive - Nexus365\\Desktop\\R_scripts\\U-net\\bboxcropped_images\\OD\\cropped_images\\images"
patches <- imageAIready::patchifyR(images_path = new_images_path,
                     patch_size = 256,
                     heyex_xml_file = F,
                     destin = "C:\\Users\\ajosan\\OneDrive - Nexus365\\Desktop\\R_scripts\\U-net")

#####################################################################
#####################################################################








#####################################################################
####################### AI predictions ##############################
#####################################################################
##### Load in images to test 
images_folder <- paste0(filepath, "\\bboxcropped_images\\",eye,"\\cropped_images\\image_patches\\images\\")
images <- imageseg::loadImages(images_folder)
images <- imageseg::imagesToKerasInput(images, type = "image", grayscale = F)
model <- keras::load_model_hdf5("C:\\Users\\ajosan\\OneDrive - Nexus365\\Desktop\\R_scripts\\U-net\\Rscripts\\trained_models\\ort_model_unet_from_scratch.hdf5", compile = F)
###  NOTE: imageSegementation from imageseg package not working for me, so edited package
###        by adding .ragged=TRUE and saved new function as v2
source("C:\\Users\\ajosan\\OneDrive - Nexus365\\Desktop\\R_scripts\\U-net\\Rscripts\\imageseg_modified_funcs\\imageSegmentation_v2.R")
predictions <- imageSegmentation_v2(model=model, x=images, threshold = 0.9)
#predictions
#####################################################################
#####################################################################










#########################################################################################
###### save predicted images as overlay images using the predictions_overlay function
#########################################################################################
source("C:\\Users\\ajosan\\OneDrive - Nexus365\\Desktop\\R_scripts\\imageAIready\\predictions_overlay.R")
images_folder <- paste0(filepath, "\\bboxcropped_images\\",eye,"\\cropped_images\\image_patches\\images\\")
ORT <- predictions_overlay(images_folder=images_folder, 
                           predictions=predictions, 
                           destin = dirname(dirname(images_folder)))
#########################################################################################
#########################################################################################









########################################################################
######## Mosaic patches back together
########################################################################
patches_folder <- paste0(filepath,"/bboxcropped_images/",eye,"/cropped_images/AI_predictions/patches/")
source("C:\\Users\\ajosan\\OneDrive - Nexus365\\Desktop\\R_scripts\\imageAIready\\mosaicR.R")
mosaic <- mosaicR(patches_folder = patches_folder)
########################################################################
########################################################################








########################################################################
######## Find ORT positions directly from predictions 
########################################################################
heyex_images_folder <- file.path(paste0(filepath,"\\",eye))

source("C:\\Users\\ajosan\\OneDrive - Nexus365\\Desktop\\R_scripts\\imageAIready\\findORT.R")
ORT_data_F <- findORT(predictions,
                      heyex_images_folder = heyex_images_folder,
                      ORT_size_min = 100)

save(ORT_data_F, file = paste0(heyex_images_folder, "//ORT_data_F.Rdata"))
########################################################################
########################################################################









########################################################################
######## Find ORT from mask patches
########################################################################
heyex_images_folder <- file.path(paste0(filepath,"\\",eye))
patched_masks_folder <- paste0(filepath,"/bboxcropped_images/",eye,"/cropped_images/AI_predictions/patches/masks/")

source("C:\\Users\\ajosan\\OneDrive - Nexus365\\Desktop\\R_scripts\\imageAIready\\findORT.R")
findORT <- findORT(heyex_images_folder = heyex_images_folder,
                    patched_masks_folder = patched_masks_folder,
                    ORT_size_min = 80)

save(findORT, file = "ORT_df.Rdata")
########################################################################
########################################################################









########################################################################
######## overlay ORT onto enface image
########################################################################
heyex_images_folder <- file.path(paste0(filepath,"\\",eye))
source("C:\\Users\\ajosan\\OneDrive - Nexus365\\Desktop\\R_scripts\\imageAIready\\enfaceORTplot.R")
enfaceORTplot <- enfaceORTplot(ORT_data_F = ORT_data_F,
                               heyex_images_folder = heyex_images_folder)
########################################################################
########################################################################













