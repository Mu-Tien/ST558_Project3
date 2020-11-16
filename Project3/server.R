#required package
library(ggbiplot)
library(shiny)
library(dmm)
library(knitr)
library(rmarkdown)
library(MuMIn)
library(tidyverse)
library(caret)
library(corrplot)
library(readxl)
library(caret)
library(ggiraphExtra)
library(knitr)
library(ggplot2)
library(dplyr)
library(ggpubr)
library(rpart.plot)
library(rpart)
library(DT)
library(cluster)
library(factoextra)
library(magrittr)
library(NbClust)
library(plotly)
# Define server logic required to draw a histogram
shinyServer(function(input, output, session){

#read in data
data <- read.csv("diabetes_data.csv")
for( j in 1:nrow(data)){    
  ifelse (data[j,17] == "Positive", data[j,17] <- 1,data[j,17] <- 0)
  
  for (i in 3:16){
    if (data[j,i] == "Yes") data[j,i] <- 1
    else if (data[j,i] == "No") data[j,i] <- 0
  }
}
mydata<-data
for (i in 3:16){
  mydata[,i] <- as.numeric(mydata[,i])%>% as.factor()
  data[,i] <- as.numeric(data[,i])
}
data <- as_tibble(data)
mydata$class <- as.factor(mydata$class)
mydata <- as_tibble(mydata)

#histogram of data
   output$histogram <- renderPlotly({
     ggplot(data=mydata, aes(x=Age))+geom_histogram(aes(fill=class))+labs(title = "Histogram for age seperate by test result")+facet_grid(.~Gender)+scale_fill_discrete(name="Test result", labels=c("Negative", "Positive"))
   })

# scatter plot of data
   output$scatter <- renderPlotly({
     t <- paste0("Scatter plots for ", input$plotvar1, " and ", input$plotvar2)
     ggplot(data=mydata)+geom_jitter(aes_string(x=input$plotvar1, y=input$plotvar2, color="class"))+facet_grid(.~Gender)+labs(title = t)+scale_fill_discrete(name="Test result", labels=c("Negative", "Positive"))
     
   })
   
# summary table of data
   output$sumtable <- DT::renderDataTable({
     data <- data %>% select(class,Gender, everything())
     data$class <- as.numeric(data$class)
     if (input$groups=="Gender")
     sumdata <- data %>% group_by(Gender)
     else if(input$groups=="Test result")
       sumdata <- data %>% group_by(class)
     else if (input$groups=="Test result and Gender")
       sumdata <- data %>% group_by(class,Gender)
     
     sumdata <-sumdata %>% summarise_all(list(mean))
     sumdata[,3:17]<- round(sumdata[,3:17],2)
     datatable(sumdata)
   })
   
# convert gender into numeric
     for (i in 1:nrow(data)){
       ifelse(data[i,2]=="Male",data[i,2] <- "1", data[i,2]<-"0" )
     }
     data$Gender <- as.numeric(data$Gender)
     
#PCA plots
   output$PCA <- renderPlotly({
     PCs <- prcomp(data[,1:16], center=TRUE, scale=TRUE)
     ggbiplot(PCs, group=data$class)
   })

# Optimal number of cluster
   output$recomCluster <- renderPlotly({
     fviz_nbclust(data[,1:16], kmeans, method ="silhouette")
   })
   
#clustering using kmean
   output$kmean <- renderPlotly({
     km.res <- kmeans(data[,1:16],input$numclust)
     fviz_cluster(km.res, data = data[,1:16],
                  ellipse.type = "convex",
                  palette = "jco")
   })

#Clustering using hierarchical clustering
   output$Hierclust <- renderPlotly({
     HierClust <- hclust(dist(data[,1:16]), method = "ward.D2")
     fviz_dend(HierClust, k = input$clusteringNum, # Cut in four groups
               cex = 0.5, # label size
               palette = "jco",
               show_labels = FALSE, # color labels by groups
               rect = TRUE # Add rectangle around groups
     )
   })
   
   #separating training and testing dataset
   train <- sample(1:nrow(mydata), size = nrow(mydata)*0.8)
   test <- dplyr::setdiff(1:nrow(mydata), train)
   diabetesdataTrain <- mydata[train, ]
   diabetesdataTest <- mydata[test, ]

#modeling1-logistic regression
   reg_model <- eventReactive(input$start_reg,{
      trctrl_reg <- trainControl(method = input$reg_trainmethod, 
                                 number = input$reg_num_folders)
      reg_fit <- train(class~., data = diabetesdataTrain, method = "glm",
                       family="binomial",
                       trControl=trctrl_reg,
                       preProcess = c("center", "scale"))
      output <- reg_fit$results
   })
   
   output$regTrain <- renderPrint({
      list <- reg_model()
      list$output
   })
   
#modeling2-tree based(rf, bagged, boosting)
   
#modeling3-KNN
   
})
