###
### create animation from en-face images
###
rm(list = ls(all = TRUE))
gc()
library(magick)
library(gtools)
library(stringr)
library(tidyverse)





# display enface images

enface_ordered <- mixedsort(list.files(path = ".", full.names = T, pattern = ".png", recursive = T))

all_files <- as.data.frame(enface_ordered)

all_files %>%
  filter(str_detect(enface_ordered, "OD")) -> OD_ordered

all_files %>%
  filter(str_detect(enface_ordered, "OS")) -> OS_ordered


OD_images <- image_read(OD_ordered$enface_ordered)
OS_images <- image_read(OS_ordered$enface_ordered)






gif_OD <- image_animate(OD_images, fps = 0.5, dispose = "previous")
gif_OS <- image_animate(OS_images, fps = 0.5, dispose = "previous")


#gif_OD


image_write(gif_OD, "movie_OD.gif")
image_write(gif_OS, "movie_OS.gif")


