#load required packages
library(neuralnet)
library(randomForest)
library(ggplot2)
library(caret)
library(ModelMetrics)
#function makes a few steps easier for scaling input data 
createdataset <- function(inputfile, outputfile="Datasets\\output_IDTnew.csv"){
  input <- read.csv(inputfile, header=TRUE)
  dataset <- as.data.frame(scale(input))
  IDT <- as.numeric(unlist(read.csv(outputfile, header=TRUE, stringsAsFactors=FALSE)))
  dataset$IDT <- IDT
  dataset$X <- NULL
  return(dataset)
}
#Create training and testing set split function
#sizeoftraining set is the percentage used; i.e 70% training 30% test
SplitSets <- function(dataset, sizeoftrainingset){
  set.seed(1234)
  size <- round(.01*sizeoftrainingset*nrow(dataset))
  split <- sample(nrow(dataset), size=size, replace=FALSE, prob=NULL)
  return(split)
}
#train random forest function
rf <-function(trainingdata, filename= "rds\\rf_YouForgotToSpecify.rds", save=FALSE){
  #k-fold crossvalidation, k=10
  cv <- trainControl(method="cv", number=10, savePredictions=TRUE)
  start.time <- Sys.time()
  set.seed(3000)
  rf <- train(IDT ~ ., data=trainingdata, trControl=cv, method="rf",importance=TRUE)
  if(save)
    saveRDS(rf, file=filename)
  end.time <- Sys.time()
  print(end.time-start.time)
  
  return(rf)  
}
#train neural network function
nnet <- function(trainingdata, hidden=c(2), filename= "rds\\nnet_YouForgotToSpecify.rds", save=FALSE, threshold=1, stepmax=1e+9){
  n <- names(trainingdata)
  formula <- as.formula(paste("IDT ~", paste(n[!n %in% "IDT"], collapse = " + ")))
  set.seed(3000)
  start.time<- Sys.time()
  #*IDT ~ . may not work for nnet for some reason
  nnet <- neuralnet(formula, data=trainingdata, hidden=hidden, linear.output=TRUE, threshold=threshold, stepmax=stepmax, lifesign='minimal')
  if(save)
    saveRDS(nnet, filename)
  end.time <- Sys.time()
  print(end.time-start.time)
  
  return(nnet)
}
#makes it easier to plot, only 2 compared groups for now
plot <- function(pred1, pred2, testset1, testset2, file="YouForgotToSpecify.png", title = "Random Forest"){
  df1 <- data.frame(x=log(pred1), y=log(testset1$IDT), type=as.factor("FB"))
  df2 <- data.frame(x=log(pred2), y=log(testset2$IDT), type=as.factor("FG"))
  df <- do.call(rbind, list(df1,df2))
  plot <- ggplot(df, aes(x = x, y = y)) +
    geom_point(alpha = 0.3, color="red", size=.8) + 
    scale_x_continuous(breaks = seq(-3,4,1), lim=c(-3, 4)) +
    scale_y_continuous(lim=c(-3,4)) +
    geom_segment(aes(x=-3,y=-3,xend=3,yend=3), linetype='dashed')+
    geom_smooth(method="loess", se=FALSE, size=0.5, color="blue") +
    #facet_wrap(~type, ncol=3) + #ncol changed from 3-2
    theme(panel.background = element_rect(fill = 'white', colour = 'black'),panel.grid.major = element_line(size = 0.5, linetype = 'solid',
                                                                                                            colour = "white"), 
          text=element_text(size=20), panel.grid.minor = element_line(size = 0.25, linetype = 'solid',
                                                                      colour = "white"))+
    facet_wrap(~type, ncol=2) +
   # annotate("text", x = -1, y = 3, label = c("R^2==.919","R^2==.9","R^2==.996",'R^2==.996'), parse=TRUE, size=7)+
  #  annotate("text", x = -1, y = 2, label = c("RMSE==.25","RMSE==.15","RMSE==.12",'RMSE==.11'), parse=TRUE, size=7)+
    labs(x='log(Predicted IDT)', y='log(Observed IDT)')+
    ggtitle((title))+theme(plot.title = element_text(hjust = 0.5))+
    
    ggsave(file=file, width=8, height=5)
  plot
  
  return(plot)
}
error <- function(calculated, actual){
  calculated <- as.matrix(calculated)
  actual <- as.matrix(actual)
  num <- norm(calculated - actual)
  den <- norm(actual)
  return(abs(num/den))
}
#reload directory if necessary
#Set the directory to whereever it is saved
setwd(" ")

#fb = fuel blends, fg = functional groups
dataset_fb <- createdataset("Datasets\\input_IDT_fuelblends.csv")
dataset_fg <- createdataset("Datasets\\input_IDT_funcgroups.csv")

set70 <- SplitSets(dataset=dataset_fb, 70)
training_fb <- dataset_fb[set70,]
test_fb <- dataset_fb[-set70,]

set70 <- SplitSets(dataset=dataset_fg, 70)
training_fg <- dataset_fg[set70,]
test_fg <- dataset_fg[-set70,]

#if you want to change the number of trees, you have to edit it within the function/add a parameter to it
rf_fb <- rf(training_fb, "rds\\rf_fb.rds", TRUE)
rf_fg <- rf(training_fg, "rds\\rf_fg.rds", TRUE)
#you can play around with the hidden neurons, error threshold, stepmax, etc.
nnet_fb <- nnet(training_fb, hidden=c(100), "rds\\nnet_fb50.rds",TRUE)
nnet_fg <- nnet(training_fg, hidden=c(100), "rds\\nnet_fg50.rds",TRUE)

rf.pred.fb <- predict(rf_fb, test_fb[,1:5])
rf.pred.fg <- predict(rf_fg, test_fg[,1:5])
nnet.pred.fb <- compute(nnet_fb, test_fb[,1:5])$net.result
nnet.pred.fg <- compute(nnet_fg, test_fg[,1:5])$net.result

plotrf <- plot(rf.pred.fb, rf.pred.fg, test_fb, test_fg, file="RF_fbvsfg.png",title = "Random Forest")
plotnnet <- plot(nnet.pred.fb, nnet.pred.fg, test_fb, test_fg, file="NN_fbvsfg_100nodes.png", title="Neural Network")
