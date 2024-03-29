
##########################################################################################
######################## Find ORT and overlay onto original images ##########################
##########################################################################################

enfaceORTplot <- function(ORT_coords,
                          heyex_images_folder,
                          destin=dirname(heyex_images_folder))
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
  # install and load gtools
  if (!require("gtools")){
    install.packages("gtools")
    library(gtools)
    suppressPackageStartupMessages({library(gtools)})
  }
  # install and load ggforce
  if (!require("ggforce")){
    install.packages("ggforce")
    library(ggforce)
    suppressPackageStartupMessages({library(ggforce)})
  }
  # install and load readheyexxml
  if (!require("readheyexxml")){
    install.packages("devtools")
    library(devtools)
    install_github("amanasj/readheyexxml")
    library(readheyexxml)
  }
  # install and load grid
  if (!require("grid")){
    install.packages("grid")
    library(grid)
    suppressPackageStartupMessages({library(grid)})
  }
  
  



#### use readheyexxml function
#source("C:\\Users\\ajosan\\OneDrive - Nexus365\\Desktop\\R_scripts\\readheyexxml\\Rscripts\\readheyexxml.R")
heyex_data <- readheyexxml::readheyexxml(folder = heyex_images_folder)

### find bscan number (y-position) by matching to first dataframe created by readheyex function
df_ORT <- merge(heyex_data$data, ORT_coords, by=c("ExamURL"))
df_ORT <- df_ORT[gtools::mixedorder(df_ORT$ID),]
df_ORT[c(2:5,7:18)] <- sapply(df_ORT[c(2:5,7:18)],as.numeric)
df_ORT$x_coord <- (df_ORT$ORT_x * df_ORT$scalex_enface[1]) + df_ORT$plot_start_x[1]

ORT_count <- nrow(df_ORT)

 ######
 ######
 # Note that the first bscan starts at the bottom of the enface image even though the (0,0) coord 
 # is the top left corner. 
 ######
 ######

### Display enface image
enface_image <- EBImage::readImage(df_ORT$ExamURL_enface[1])
dim <- dim(enface_image)
h <- dim[1]
w <- dim[2]
plot(enface_image)
h1 <- df_ORT$h1[1]
h2 <- df_ORT$h2[1]
v1 <- df_ORT$v1[1]
v2 <- df_ORT$v2[1]
abline(h = h1, v = v1, col= "ivory")
abline(h = h2, v = v2, col= "ivory")

###############################################################
################## prepare enface image #######################
###############################################################
### prepare enface image - add an alpha term to enface image
enface_image = abind::abind(enface_image, enface_image[,,1])
### set transparency with alpha 
enface_image[,,4] = 0.75
#EBImage::display(enface_img_crop)
### weird matrix rotation occurs in rasterGrob below so pre-rotate
enface_img_rotated <- EBImage::transpose(enface_image)
#enface_img_rotated <- enface_image
### use rasterGrob to prepare image for overlaying with ggplot
### using annotation_custom
### calc image centring positions x & y in rasterGrob
g <- grid::rasterGrob(enface_img_rotated, 
                      x = unit(0.5, "npc"), 
                      y = unit(0.5, "npc"),
                      height = 1, width = 1)



coord_cartesian <- coord_cartesian(
  xlim = c(0, w*heyex_data$data$scalex_enface[1]),
  ylim = c(h*heyex_data$data$scaley_enface[1], 0),
  expand = F, clip="on")
#############################################################
######################## ggplot #############################
ORT_plot <- 
  ggplot(data=df_ORT) +
  geom_circle(aes(x0 = x_coord, 
                  y0 = y_coord, 
                  r=0.06), fill="green4") +
  coord_fixed() +
  #geom_polygon(data=df_ort)+
  labs(x = "x (mm)", y = "y (mm)") +
  ggtitle(paste0("ORT - ", eye)) +
  coord_cartesian +
  theme(aspect.ratio=1) +
  theme(panel.grid.major = element_blank(), 
        panel.grid.minor = element_blank(),
        panel.background = element_blank(),
        plot.title = element_text(size=22)) +


  
  geom_hline(yintercept = df_ORT$plot_start_y[1], linewidth=1, col="black") +
  geom_hline(yintercept = df_ORT$plot_end_y[1], linewidth=1, col="black") +
  geom_vline(xintercept = df_ORT$plot_start_x[1], linewidth=1, col="black")+
  geom_vline(xintercept = df_ORT$plot_end_x[1], linewidth=1, col="black")


### add semi-transparent enface image to ggplot
ORT_plot <- ORT_plot+annotation_custom(g)

plot(ORT_plot)

#predictions_folder <- "C:\\Users\\ajosan\\OneDrive - Nexus365\\Desktop\\R_scripts\\imageAIready"
ggsave(paste0("ORT_enface_", eye, "_", timepoint, ".png"), dpi=300, path = paste0(destin,"\\",eye), 
       width = 2500, height = 2500, units = "px")




} ## closes enfaceORTplot func 



