## Getting and Cleaning Data Course Project
## David Lazaroff
##2016-12-15

## Download the data
download.file("https://d396qusza40orc.cloudfront.net/getdata%2Fprojectfiles%2FUCI%20HAR%20Dataset.zip", "dataset.zip")
## unzip the file
unzip("dataset.zip")

## Requirement 1 is to merge all training and test data.
## set the working directory to that for the dataset.
setwd("./UCI HAR Dataset")
## read the test data
xtest <- read.table("test/X_test.txt")
ytest <- read.table("test/y_test.txt")
subjecttest <- read.table("test/subject_test.txt")

## read the training data
xtrain <- read.table("train/X_train.txt")
ytrain <- read.table("train/y_train.txt")

## merge all the training data with subject as first column, activity as second
## column followed by sensor data columns
subjecttrain <- read.table("train/subject_train.txt")

## merge all the test data with subject as first column, activity as second column
##followed by sensor data columns
testall <- cbind(subjecttest, ytest, xtest)
## Now merge the training data as we did the test data
trainall <- cbind(subjecttrain, ytrain, xtrain)

## Combine the test and training data into one table
alldata <- rbind(testall, trainall)

## Read the data column labels from features.txt. Use the entire line with 
## index number to avoid duplicates that exist if the first digits are excluded.
## Using the separator "~" will cause end of line to separate fields because the
## file has no "~" characters in it.

features <- scan("features.txt", what = "character", sep = "~")

## Add the column names to the combined data. "gsub()" is used to 
## remove commas from column names (otherwise these interfere with
## the "select()" command in future steps).
colnames(alldata) <- c("subject", "activity", gsub(",", "", features))

## Requirement 2 is to select mean and std data for subjects and activity
## Select the data for our final table. According to the features_info.txt file, 
## we take our data with "mean()" for measurement means and "std()" for standard
## deviation of measurements. "grep" gives the column numbers that match the regular
## expression.

selectdata <- select(alldata, 1, 2, grep("([-]mean[(])|([-]std[(])", names(alldata)))

## Requirement 3.
## Read in the descriptive activity names from activity_labels.txt. 

activitylabels <- read.table("activity_labels.txt", stringsAsFactors = FALSE)

## create a vector for activityname. This code looks up the activity name based on the 
## activity number 
activityname <- activityLabels[selectdata$activity, 2]

## replace the activity number with the activity name
selectdata$activity <- activityname

## for requirement 4: Make variable names more appropriate by removing the
## leading number and parentheses. "-" characters and mixed case are kept to
## improve readability.

names(selectdata) <- sub("^[0-9 ]*", "", names(selectdata))
names(selectdata) <- gsub("[()]*", "", names(selectdata))

## "selectdata" is now complete!


## Requirement 5: From the data set in step 4, creates a second, independent 
## tidy data set with the average of each variable for each activity and each subject.

## At this point I have factors in columns 1 and 2 for subject and activity, 
## respectively. Columns 3:68 contain values of mean() and std() for various sensor
## readings. We now want to calculate a mean() for columns 3:68 by all permutations of
## 30 subjects and 6 activities.

### Use aggregating
options(digits = 9)
meandata <- with(selectdata, 
                 aggregate(selectdata[3:68], # These are the rows with the measurements
                           by=list(subject=subject, activity=activity), # These are the factors
                           FUN = mean))

## Write the dataset
write.csv(meandata, "meandata.csv", row.names = FALSE)
