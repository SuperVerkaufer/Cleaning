#1. Downloading and unzipping dataset

if(!file.exists("./data")){dir.create("./data")}
fileUrl <- "https://d396qusza40orc.cloudfront.net/getdata%2Fprojectfiles%2FUCI%20HAR%20Dataset.zip"
download.file(fileUrl,destfile="./data/Dataset.zip")

# Unzip dataSet to /data directory
unzip(zipfile="./data/Dataset.zip",exdir="./data")
################################################################################

#2. Merging the training and the test sets to create one data set:
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
#2.2 Assigning column names:

colnames(xVARtrain) <- FEATURES[,2] 
colnames(yVARtrain) <-"activityId"
colnames(subjectVARtrain) <- "subjectId"

colnames(xVARtest) <- FEATURES[,2] 
colnames(yVARtest) <- "activityId"
colnames(subjectVARtest) <- "subjectId"

colnames(ACTIVITYLABELS) <- c('activityId','activityType')

################################################################################
#2.3 Merging all data in one set:

mergeVARtrain <- cbind(yVARtrain, subjectVARtrain, xVARtrain)
mergeVARtest <- cbind(yVARtest, subjectVARtest, xVARtest)
mergeTrainTest <- rbind(mergeVARtrain, mergeVARtest)

################################################################################
#3. Extracting only the measurements on the mean and standard deviation for each measurement
#3.1 Reading column names:
#3.2 Create vector for defining ID, mean and standard deviation:
#3.3 Making nessesary subset from setAllInOne:

COLnames <- colnames(mergeTrainTest)
selectCOL <- (grepl("activityId" , COLnames) | 
                   grepl("subjectId" , COLnames) | 
                   grepl("mean.." , COLnames) | 
                   grepl("std.." , COLnames) 
)
selectMeanAndStd <- mergeTrainTest[ , selectCOL == TRUE]
################################################################################
#4. Using descriptive activity names to name the activities in the data set:

selectMeanAndStdACTIVITY <- merge(selectMeanAndStd, ACTIVITYLABELS,
                              by='activityId',
                              all.x=TRUE)

################################################################################
#5. Creating a second, independent tidy data set with the average of each variable for each activity and each subject:
#5.1 Making second tidy data set
#5.2 Writing second tidy data set in txt file

aggFINAL <- aggregate(. ~subjectId + activityId, selectMeanAndStdACTIVITY, mean)
aggFINAL <- aggFINAL[order(aggFINAL$subjectId, aggFINAL$activityId),]

write.table(aggFINAL, "aggFINAL.txt", row.name=FALSE)

