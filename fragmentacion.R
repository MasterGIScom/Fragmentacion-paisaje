rm(list = ls())

library(RStoolbox)
library(raster)
library(dplyr)
library(sf)
library(rgdal)
library(rgeos)

###### índice Espectral de Vegetación(EVI)

setwd('C:/Users/user/Desktop/Fragmentación del paisaje/datos/cov2017/')


lts<- brick('C:/Users/user/Desktop/Fragmentación del paisaje/datos/cov2017/Sentinel2017.tif')



evi      <- ( 2.5 * (lts[[7]] - lts[[3]]) )/ (( lts[[7]] + 6 * lts[[3]]- 7.5 * lts[[1]] ) +1 )



#2.5 * (B8 - B4) / ((B8 + 6 * B4 - 7.5 * B2) + 1))

writeRaster(lts, 'C:/Users/user/Desktop/Fragmentación del paisaje/datos/cov2017/lts.tif')
writeRaster(evi,'C:/Users/user/Desktop/Fragmentación del paisaje/datos/cov2017/evi.tif')


cov <- list.files('C:/Users/user/Desktop/Fragmentación del paisaje/datos/cov2017',pattern = '.tif',full.names = T)
CovStack <- stack(cov)
writeRaster(CovStack,'C:/Users/user/Desktop/Fragmentación del paisaje/datos/cov2017/CovStack.tif')



img <- brick('C:/Users/user/Desktop/Fragmentación del paisaje/datos/cov2017/CovStack.tif')

names(img) <- c(paste('B',c(2:8),sep = ''),'evi')

writeRaster(img,'C:/Users/user/Desktop/Fragmentación del paisaje/datos/cov2017/img.tif')

img <- brick('C:/Users/user/Desktop/Fragmentación del paisaje/datos/cov2017/img.tif')

#Asignar proyección UTM a imagen 

imga <- projectRaster(img, crs = crs(train))



########## 

#CLASIFICACIÓN NO SUPERVISADA


#CLASIFICACIÓN SUPERVISADA
#En este caso se utilizan muestras según la clasificación requerida

clas_nosup <- unsuperClass(imga,nSamples = 200,nClasses = 6,nStarts = 5)
#Método Kmeans 

class(clas_nosup)

ggR(clas_nosup$map,geom_raster = TRUE,forceCat = TRUE)



#CLASIFICACIÓN SUPERVISADA 
campos <- st_read("C:/Users/user/Desktop/Fragmentación del paisaje/datos/train/campos2017.shp")

train <- st_transform(campos, 32719)

nc <- as_Spatial(train) 

#Asignar proyeccióN UTM al shapefile 


clas_sup <- superClass(imga,trainData = nc, responseCol = "clases" , model = "mlc")#rf

ggR(clas_sup$map,geom_raster = TRUE,forceCat = TRUE)

writeRaster(clas_sup$map, filename='C:/Users/user/Desktop/Fragmentación del paisaje/datos/clasificacion/clasificacion2017.tif', format="GTiff", overwrite=TRUE)





