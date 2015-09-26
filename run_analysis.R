  library(data.table)
  library(stringr)
  library(utils)
  library(dplyr)

  # parameters  
  download   <- FALSE   ## TRUE if you need to download original compressed dataset for course project
  workingDir <-"c:/rawdata/project-get-clean-data"  ## working directory you want to set for your machine
  
  #############################################################################
  ##  PART I - DOWNLOAD FILE, UNZIP FILE AND PREPARE INDEX FOR SELECTED COLUMNS
  #############################################################################
  
  # checks if working dir exists, if not creates it
  if (!file.exists(workingDir)){dir.create(workingDir)}
  
  # set working directory
  setwd(workingDir)
  
  if (download){
  
      # sets URL to download file
      fileURL <- "https://d396qusza40orc.cloudfront.net/getdata%2Fprojectfiles%2FUCI%20HAR%20Dataset.zip"
      
      # downloads file, writes into working directory and unzips
      download.file(fileURL,"zipdata.zip")
      unzip("zipdata.zip")

  }
  
  # opens features file
  features <- read.csv("UCI HAR Dataset/features.txt",sep=" ", header = FALSE,stringsAsFactors = FALSE)
  
  # sets name for features data frame columns
  colnames(features) <- c("colIndex","colName")

  # creates an index  vector with position of columns that have "mean" or "STD" 
  #    in their name AND do not have "meanFreq" in their name
  j     <- 1
  index <- c(NULL)

    for (i in 1:nrow(features)){
    
      foundMean     <- regexpr("mean()"     ,features$colName[i])
      foundSTD      <- regexpr("std()"      ,features$colName[i])
      foundmeanFreq <- regexpr("meanFreq()" ,features$colName[i])
      
      if (foundMean > 0){
        locate  <- str_locate(features$colName[i],"mean()")
      } else if (foundSTD > 0) {
            locate  <- str_locate(features$colName[i],"std()")
          }
  
      # create index vector with selected values
      if ((foundMean>0 | foundSTD>0) && (foundmeanFreq<0)) {
        
        # replaces "()" with "" to have clearer names
        features$colName[i] <- as.character(paste0(substr(features$colName[i]
                                             ,1
                                             ,locate[2])
                                      ,substr(features$colName[i]
                                              ,locate[2]+3
                                              ,nchar(as.character(features$colName[i])))))
        # appends value to index
        index[j] <- i
        j <- j+1
      } # if  
      
  } # for  

  #######################################################################################
  ##  PART II - MERGE DATA, PREPARE INTERMEDIATE DATASET WITH LABELS AND SAVE INTO A FILE
  #######################################################################################
  
  # read activity labels file
  activityLabels           <- read.csv("UCI HAR Dataset/activity_labels.txt"    ,sep="",header = FALSE)
  colnames(activityLabels) <- c("actCode","actName")
  
  # read training files
  dataTrainMeasures   <- read.csv("UCI HAR Dataset/train/X_train.txt"      ,sep="",header = FALSE)
  dataTrainSubjects   <- read.csv("UCI HAR Dataset/train/subject_train.txt",sep="",header = FALSE)   
  dataTrainActivities <- read.csv("UCI HAR Dataset/train/y_train.txt",sep="",header = FALSE)   
  
  # read test files
  dataTestMeasures    <- read.csv("UCI HAR Dataset/test/X_test.txt"         ,sep="",header = FALSE)
  dataTestSubjects    <- read.csv("UCI HAR Dataset/test/subject_test.txt"   ,sep="",header = FALSE)   
  dataTestActivities  <- read.csv("UCI HAR Dataset/test/y_test.txt"   ,sep="",header = FALSE)   
  
  # merge train and test data frames to form a complete data frame 
  dataCompleteMeasures   <- rbind(dataTrainMeasures  , dataTestMeasures  )
  dataCompleteSubjects   <- rbind(dataTrainSubjects  , dataTestSubjects  )
  dataCompleteActivities <- rbind(dataTrainActivities, dataTestActivities)

  # append subjects and activity codes to complete data frame  
  dataCompleteMeasures   <- cbind(dataCompleteMeasures, dataCompleteSubjects  )
  dataCompleteMeasures   <- cbind(dataCompleteMeasures, dataCompleteActivities)

  # name columns in complete data frame 
  nameSubject           <- data.frame(colIndex=562,colName="subject")
  nameActivityCode      <- data.frame(colIndex=563,colName="activity_code")
  featuresLabels        <- rbind(features      ,nameSubject)
  featuresLabels        <- rbind(featuresLabels,nameActivityCode)
  
  dataCompleteMeasures  <- setNames(dataCompleteMeasures,featuresLabels$colName)

  # transform resulting data frame in a data table
  dataCompleteMeasuresDT <- data.table(dataCompleteMeasures)
  
  # create new column with activity labels 
  dataCompleteMeasuresDT[,activity_label:={activityLabels$actName[activity_code]}]

  # includes new columns (subject, activity code and activity name) in column index vector
  indexLabels <- c(index,c(562:564))
  
  # extracts selected columns into a new data table and records file 
  dataSelectedMeasuresDT <- dataCompleteMeasuresDT[,indexLabels,with=FALSE]
  write.table(dataSelectedMeasuresDT,"selectedMeasures.txt",sep=",",row.names = FALSE)
  
  ###################################################################################################
  ##  PART III - CREATE FINAL DATASET WITH SUMMARIZED VALUES (MEANS) GROUPED BY SUBJECT AND ACTIVITY,
  ##             LABEL COLUMNS WITH NEW NAMES AND SAVE IT TO A FILE
  ###################################################################################################
  dataSummarizedValuesDT <- dataSelectedMeasuresDT[, j=list(  mean(`tBodyAcc-mean-X`)          ,mean(`tBodyAcc-mean-Y`)           ,mean(`tBodyAcc-mean-Z`)
                                                             ,mean(`tBodyAcc-std-X`)           ,mean(`tBodyAcc-std-Y`)            ,mean(`tBodyAcc-std-Z`)
                                                             ,mean(`tGravityAcc-mean-X`)       ,mean(`tGravityAcc-mean-Y`)        ,mean(`tGravityAcc-mean-Z`)
                                                             ,mean(`tGravityAcc-std-X`)        ,mean(`tGravityAcc-std-Y`)         ,mean(`tGravityAcc-std-Z`)
                                                             ,mean(`tBodyAccJerk-mean-X`)      ,mean(`tBodyAccJerk-mean-Y`)       ,mean(`tBodyAccJerk-mean-Z`)
                                                             ,mean(`tBodyAccJerk-std-X`)       ,mean(`tBodyAccJerk-std-Y`)        ,mean(`tBodyAccJerk-std-Z`)
                                                             ,mean(`tBodyGyro-mean-X`)         ,mean(`tBodyGyro-mean-Y`)          ,mean(`tBodyGyro-mean-Z`)
                                                             ,mean(`tBodyGyro-std-X`)          ,mean(`tBodyGyro-std-Y`)           ,mean(`tBodyGyro-std-Z`)
                                                             ,mean(`tBodyGyroJerk-mean-X`)     ,mean(`tBodyGyroJerk-mean-Y`)      ,mean(`tBodyGyroJerk-mean-Z`)
                                                             ,mean(`tBodyGyroJerk-std-X`)      ,mean(`tBodyGyroJerk-std-Y`)       ,mean(`tBodyGyroJerk-std-Z`)
                                                             ,mean(`tBodyAccMag-mean`)         ,mean(`tBodyAccMag-std`)           ,mean(`tGravityAccMag-mean`)
                                                             ,mean(`tGravityAccMag-std`)       ,mean(`tBodyAccJerkMag-mean`)      ,mean(`tBodyAccJerkMag-std`)
                                                             ,mean(`tBodyGyroMag-mean`)        ,mean(`tBodyGyroMag-std`)          ,mean(`tBodyGyroJerkMag-mean`)
                                                             ,mean(`tBodyGyroJerkMag-std`)     ,mean(`fBodyAcc-mean-X`)           ,mean(`fBodyAcc-mean-Y`)
                                                             ,mean(`fBodyAcc-mean-Z`)          ,mean(`fBodyAcc-std-X`)            ,mean(`fBodyAcc-std-Y`)
                                                             ,mean(`fBodyAcc-std-Z`)           ,mean(`fBodyAccJerk-mean-X`)       ,mean(`fBodyAccJerk-mean-Y`)
                                                             ,mean(`fBodyAccJerk-mean-Z`)      ,mean(`fBodyAccJerk-std-X`)        ,mean(`fBodyAccJerk-std-Y`)
                                                             ,mean(`fBodyAccJerk-std-Z`)       ,mean(`fBodyGyro-mean-X`)          ,mean(`fBodyGyro-mean-Y`)
                                                             ,mean(`fBodyGyro-mean-Z`)         ,mean(`fBodyGyro-std-X`)           ,mean(`fBodyGyro-std-Y`)
                                                             ,mean(`fBodyGyro-std-Z`)          ,mean(`fBodyAccMag-mean`)          ,mean(`fBodyAccMag-std`)
                                                             ,mean(`fBodyBodyAccJerkMag-mean`) ,mean(`fBodyBodyAccJerkMag-std`)   ,mean(`fBodyBodyGyroMag-mean`)    
                                                             ,mean(`fBodyBodyGyroMag-std`)     ,mean(`fBodyBodyGyroJerkMag-mean`) ,mean(`fBodyBodyGyroJerkMag-std`))
                                                        ,by = list(subject,activity_label)] 
  
  
  # prepares names for columns, including "avg-" before measurement columns
  summarizedLabels <- features[index,]
  
  for (i in 1:nrow(summarizedLabels)){
    summarizedLabels[i,2] <- as.character(summarizedLabels[i,2])
    summarizedLabels[i,2] <- paste0("avg-",summarizedLabels[i,2])
  }
  
  # include column names for subject and activity
  nameSubject      <- data.frame(colIndex=562,colName="subject")
  nameActivityCode <- data.frame(colIndex=563,colName="activity")
  
  summarizedLabels <- rbind(nameActivityCode, summarizedLabels)
  summarizedLabels <- rbind(nameSubject     , summarizedLabels)
  
  # converts data table to final data frame and names columns appropriately
  dataSumArrangeValuesDF <- data.frame(dataSummarizedValuesDT)

  # sets name
  dataSumArrangeValuesDF <- setNames(dataSumArrangeValuesDF,summarizedLabels$colName)

  # arranges rows in correct order
  dataSumArrangeValuesDF <- arrange(dataSumArrangeValuesDF,subject,activity)

  # writes file with last dataset (STEP 5)
  write.table(dataSumArrangeValuesDF,"finalDataSet.txt",sep=",",row.names = FALSE)

  
  