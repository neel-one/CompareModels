
#load directory
#set to whatever file path this is in
setwd(" ")

input_IDT <- read.csv("Datasets\\input_IDTnew.csv",header=TRUE)
input_IDT <- as.data.frame(input_IDT)

#Converts RON/MON in dataset to mol fractions of iso-octane,n-heptane,toluene
#Formula from Yuan et al
ONtoComp <- function(data){
  toluene <- (data$RON - data$MON)/14.2
  isooctane_RON <- (data$RON - 116.2*toluene)/100
  isooctane_MON <- (data$MON - 102*toluene)/100
  isooctane <- (isooctane_RON + isooctane_MON)/2
  nheptane <- 1 - toluene - isooctane
  
  data$isooctane <- isooctane
  data$nheptane <- nheptane
  data$toluene <- toluene
  
  data$RON <- NULL
  data$MON <- NULL
  return(data)
}
#Converts fuel composition to functional groups of CH3, CH2, and BZY
CompToFunc <- function(data){
  ch3 <- 5*data$isooctane + 2*data$nheptane + 1*data$toluene
  ch2 <- 1*data$isooctane + 5*data$nheptane
  bzy <- 1*data$toluene
  total <- ch3 + ch2 + bzy
  data$ch3 <- ch3/total
  data$ch2 <- ch2/total
  data$bzy <- bzy/total
  data$isooctane <- NULL
  data$nheptane <- NULL
  data$toluene <- NULL
  
  return(data)
  
}

input_IDT <- ONtoComp(input_IDT)
write.csv(input_IDT, file="Datasets\\input_IDT_fuelblends.csv")

input_IDT <- CompToFunc(input_IDT)
write.csv(input_IDT, file="Datasets\\input_IDT_funcgroups.csv")
