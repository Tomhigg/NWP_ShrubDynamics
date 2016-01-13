#Load libraries
require(maptools)
require(sp)
require(randomForest)
require(raster)



trainvals <- extract(landsat_mos, samples.5class,df=TRUE)
trainvals  <- cbind(samples.5class$Id,trainvals)
trainvals$Class  <- trainvals[,1]

# Remove NA values 
trainvals <- na.omit(trainvals)
trainvals  <- trainvals[,2:8]

randfor <- randomForest(as.factor(Class) ~., data=trainvals, importance=TRUE, na.action=na.omit)

# Calculate the image block size for processing
bs <- blockSize(satImage)

# Create the output raster block
outImage <- brick(satImage, values=FALSE, nl=numBands)
outImage <- writeStart(outImage, filename=outImageName, progress='text', format='GTiff', datatype='INT1U', overwrite=TRUE)



# Stop writing and close the file
outImage <- writeStop(outImage)

# Plotting variable importance plot
varImpPlot(randfor)

# Print error rate and confusion matrix for this classification
confMatrix <- randfor$confusion


marginData <- margin(randfor)
trainingAccuracy <- cbind(marginData[order(marginData)], trainvals[order(marginData),1])
  
# Add column names to attributes table
colnames(trainingAccuracy) <- c("margin", "classNum")  
# Calculate X and Y coordinates for training data points
xyCoords <- samples.5class@coords
xyCoords <- xyCoords[order(marginData),]
  
# Create and write point Shapefile with margin information to help improve training data
  pointVector <- SpatialPointsDataFrame(xyCoords, as.data.frame(trainingAccuracy), coords.nrs = numeric(0), proj4string = landsat_mos@crs)
  
writeOGR(pointVector, "C:\\Users\\55110140\\Desktop\\NWP_landcover\\pointProbs", "layer", driver="ESRI Shapefile", check_exists=TRUE)


