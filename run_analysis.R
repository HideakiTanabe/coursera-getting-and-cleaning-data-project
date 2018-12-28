library(dplyr)


# Initialize some initial values
targetFolder <- 'UCI HAR Dataset'
filename <- 'getdata_dataset.zip'

# Check if the user has already the file
fileUrl <- "https://d396qusza40orc.cloudfront.net/getdata%2Fprojectfiles%2FUCI%20HAR%20Dataset.zip"
if(!file.exists(targetFolder)){
        if(!file.exists(filename)){
                download.file(fileUrl, filename)
                }
        if(!file.exists("UCI HAR Dataset")){
                unzip(filename)
                }}

# Load activity labels & features
activityLabels <- read.table("UCI HAR Dataset/activity_labels.txt",stringsAsFactors = FALSE)
features <- read.table("UCI HAR Dataset/features.txt",stringsAsFactors = FALSE)

# Extract only the data on mean and standard deviation
featuresNeeded <- grep(".*mean.*|.*std.*",features[,2])
featuresNeeded.names <- features[featuresNeeded,2]
featuresNeeded.names <- gsub("-mean","Mean",featuresNeeded.names)
featuresNeeded.names <- gsub("-std","Std",featuresNeeded.names)
featuresNeeded.names <- gsub("[-()]","",featuresNeeded.names)

# Load the datasets
test.subject <- read.table(file.path(targetFolder,"test","subject_test.txt"))
test.activity <- read.table(file.path(targetFolder,"test","Y_test.txt"))
test.data <- read.table(file.path(targetFolder,"test","X_test.txt"))[featuresNeeded]

train.subject <- read.table(file.path(targetFolder,"train","subject_train.txt"))
train.activity <- read.table(file.path(targetFolder,"train", "Y_train.txt"))
train.data <- read.table(file.path(targetFolder,"train", "X_train.txt"))[featuresNeeded]

# Bind the rows for each of the datasets together
data.subject <- rbind(test.subject,train.subject)
data.activity <- rbind(test.activity,train.activity)
data.data <- rbind(test.data,train.data)

# Combine all of the colomns together into one table
data <- cbind(data.subject,data.activity,data.data)
colnames(data ) <- c("subject","activity",featuresNeeded.names)

# turn activities & subjects into factors
data$subject <- as.factor(data$subject)
data$activity <- factor(data$activity,levels = activityLabels[,1], labels = activityLabels[,2])

# Create the tidy data
data.mean <- data %>%
        group_by(subject,activity) %>%
        summarise_all(mean,.keep_All = TRUE)

# Emit the data out to a file
write.table(data.mean, file=file.path("tidy.txt"), row.names = FALSE, quote = FALSE)
