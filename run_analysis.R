setwd(UCI HAR Dataset)

#Read in all the data
  features <- read.table("features.txt",header=TRUE)
  colnames(features) <- c('ind','features')
  activities <- read.table('activity_labels.txt')
  test.subject <- read.table('test/subject_test.txt')
  test.x <- read.table('test/X_test.txt')
  test.y <- read.table('test/y_test.txt')
  train.subject <- read.table('train/subject_train.txt')
  train.x <- read.table('train/X_train.txt')
  train.y <- read.table('train/y_train.txt')

#Change the colnames to numbers
  colnames(test.x) <- 1:561
  colnames(train.x) <- 1:561

#Then stack test.x and train.x
  test.x <- stack(test.x)
  train.x <- stack(train.x)

#Change x to data table
  test.x <- data.table(test.x)
  train.x <- data.table(train.x)
  features <- data.table(features)


#Change feature names to readable
  V2 <- gsub('\\(\\)','',features$features)
  V2 <- gsub('(^|\\()t','TimeOf',V2)
  V2 <- gsub('angle','angle.between.',V2)
  V2 <- gsub('\\(','',V2)
  V2 <- gsub('\\)','',V2)
  V2 <- gsub(',','.and.',V2)
  V2 <- gsub('^f','FourierTransformed',V2)
  features$features <- V2

#Merge x with features
  setkey(test.x,ind)
  setkey(train.x,ind)
  setkey(features,ind)
  test.x <- merge(test.x,features)
  train.x <- merge(train.x,features)

#Merge y with activities
  test.y <- data.table(test.y)
  train.y <- data.table(train.y)
  activities <- data.table(activities)
  test.y <- merge(test.y,activities,by='V1')
  train.y <- merge(train.y,activities,by='V1')

#Move the test data into test.table, and train to train.table
  test.table <- data.table(subjects=test.subject$V1,values=test.x$values,
  features=test.x$features,activities=test.y$V2)
  train.table <- data.table(subjects=train.subject$V1,values=train.x$values,
  features=train.x$features,activities=train.y$V2)

#Add a group column (test/train) to each table
  test.table[,group:='test'];train.table[,group:='train']

#Then merge test and train tables altogether
  data <- rbind(test.table, train.table)

#Remove test and train tables
  rm(test.table,train.table)

#Extract mean and standard deviation
  mean.std.data <- data[grep('(mean|std)',data$features)]

#Create a second tidy dataset
  tidy.data <- mean.std.data[,mean(values),by=list(features,activities,subjects)]
  setnames(tidy.data,'V1','mean')

#Write tidt dataset
  write.csv(tidy.data, 'tidyData.txt', row.names=F)
