#Downloading + unzipping dataset
#Downloading dataset for merging
#Unzip dataSet to /data directory

if(!file.exists("./data")){dir.create("./data")}
fileUrl <- "https://d396qusza40orc.cloudfront.net/getdata%2Fprojectfiles%2FUCI%20HAR%20Dataset.zip"
download.file(fileUrl,destfile="./data/Dataset.zip")

# Unzip dataSet to /data directory
unzip(zipfile="./data/Dataset.zip",exdir="./data")
################################################################################

#Merging the training and the test sets to create one data set:
#Reading files

# Reading trainings tables:
xVARtrain <- read.table("./data/UCI HAR Dataset/train/X_train.txt")
yVARtrain <- read.table("./data/UCI HAR Dataset/train/y_train.txt")
subjectVARtrain <- read.table("./data/UCI HAR Dataset/train/subject_train.txt")

# Reading testing tables:
xVARtest <- read.table("./data/UCI HAR Dataset/test/X_test.txt")
yVARtest <- read.table("./data/UCI HAR Dataset/test/y_test.txt")
subjectVARtest <- read.table("./data/UCI HAR Dataset/test/subject_test.txt")

# Reading feature vector:
FEATURES <- read.table('./data/UCI HAR Dataset/features.txt')

# Reading activity labels:
ACTIVITYLABELS = read.table('./data/UCI HAR Dataset/activity_labels.txt')

################################################################################
#Assign column names:
#Filter in only useful elements. Remove all other columns

colnames(xVARtrain) <- FEATURES[,2] 
colnames(yVARtrain) <-"activityId"
colnames(subjectVARtrain) <- "subjectId"

colnames(xVARtest) <- FEATURES[,2] 
colnames(yVARtest) <- "activityId"
colnames(subjectVARtest) <- "subjectId"

colnames(ACTIVITYLABELS) <- c('activityId','activityType')

################################################################################
#Merging all data in one set:
#Merging all datasets both training and test before linking to activitylabels

mergeVARtrain <- cbind(yVARtrain, subjectVARtrain, xVARtrain)
mergeVARtest <- cbind(yVARtest, subjectVARtest, xVARtest)
mergeTrainTest <- rbind(mergeVARtrain, mergeVARtest)

################################################################################
#Extracting the mean and standard deviation for each measurement
#Reading column names:
# Create vector for defining ID, mean and standard deviation:
# Making nessesary subset from only key elements

COLnames <- colnames(mergeTrainTest)
selectCOL <- (grepl("activityId" , COLnames) | 
                   grepl("subjectId" , COLnames) | 
                   grepl("mean.." , COLnames) | 
                   grepl("std.." , COLnames) 
)
selectMeanAndStd <- mergeTrainTest[ , selectCOL == TRUE]
################################################################################
#Using descriptions to name the activities in the data set:

selectMeanAndStdACTIVITY <- merge(selectMeanAndStd, ACTIVITYLABELS,
                              by='activityId',
                              all.x=TRUE)

################################################################################
#Creating a second, independent tidy data set with the average of each variable for each activity and each subject:
#Making second tidy data set
#Writing second tidy data set in txt file

aggFINAL <- aggregate(. ~subjectId + activityId, selectMeanAndStdACTIVITY, mean)
aggFINAL <- aggFINAL[order(aggFINAL$subjectId, aggFINAL$activityId),]

write.table(aggFINAL, "aggFINAL.txt", row.name=FALSE)

