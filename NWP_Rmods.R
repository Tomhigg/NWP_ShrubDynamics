library(caret)
library(randomForest)
library(e1071)
library(maptools)
library(raster)
library(RStoolbox)

samples  <- readShapePoints("G:\\NWP\\samples\\nwp_merge")
proj4string(samples)   <- "+proj=utm +zone=35 +ellps=WGS84 +towgs84=0,0,0,0,0,0,0 +units=m +no_defs"

#samps  <- readOGR("G:\\NWP\\samples",layer = "nwp_merge")
landsat_mos <- stack(x = "mosaic\\n99.img")


plot(landsat_mos,1)
plot(samps,add=TRUE)


classified.mod <- superClass(landsat_mos, 
           samples, 
           valData = NULL, 
           responseCol = "Id",
           nSamples = 2000, 
           areaWeightedSampling = FALSE,
           polygonBasedCV = FALSE,
           trainPartition = 0.5,
           model = "rf",
           tuneLength = 3,
           kfold = 5,
           #minDist = 2,
           mode = "classification",
           predict = FALSE,
           predType = "raw", 
           #filename = "G:\\NWP\\classified1.tif", 
           #overwrite = TRUE
           )


classified.mod2 <- superClass(landsat_mos, 
                             samples, 
                             valData = NULL, 
                             responseCol = "Id",
                             nSamples = 5000, 
                             areaWeightedSampling = FALSE,
                             polygonBasedCV = FALSE,
                             trainPartition = 0.5,
                             model = "rf",
                             tuneLength = 3,
                             kfold = 5,
                             mode = "classification",
                             predict = FALSE,
                             predType = "raw", 
                             #filename = "G:\\NWP\\classified1.tif", 
                             #overwrite = TRUE
)



cl <- makeCluster(mc <- getOption("cl.cores",10 ))
varlist  <- c("landsat_mos","samples")
clusterExport(cl=cl, varlist, envir=environment())
clusterEvalQ(cl, library(RStoolbox))


classified.mod3 <- superClass(landsat_mos, 
                              samples, 
                              valData = NULL, 
                              responseCol = "Id",
                              nSamples = 8000,                               areaWeightedSampling = FALSE,
                              polygonBasedCV = FALSE,
                              trainPartition = 0.6,
                              model = "parRF",
                              tuneLength = 3,
                              kfold = 5,
                              mode = "classification",
                              predict = FALSE,
                              predType = "raw", 
                              #filename = "G:\\NWP\\classified1.tif", 
                              #overwrite = TRUE
)


classified.mod4 <- superClass(landsat_mos, 
                              samples, 
                              valData = NULL, 
                              responseCol = "Id",
                              nSamples = 8000,                               
                              polygonBasedCV = FALSE,
                              trainPartition = 0.5,
                              model = "rf",
                              tuneLength = 3,
                              kfold = 5,
                              mode = "classification",
                              predict = TRUE,
                              predType = "raw", 
                              filename = "G:\\NWP\\probs.mod4.tif", 
                              #overwrite = TRUE
)



samples.5class  <- subset(samples, samples$Id <6)


classified.mod5 <- superClass(landsat_mos, 
                              samples.5class, 
                              valData = NULL, 
                              responseCol = "Id",
                              nSamples = 8000,                               
                              polygonBasedCV = FALSE,
                              trainPartition = 0.5,
                              model = "rf",
                              tuneLength = 3,
                              kfold = 5,
                              mode = "classification",
                              predict = FALSE,
                              predType = "raw", 
                              filename = "G:\\NWP\\probs.mod5.tif", 
                              #overwrite = TRUE
)





