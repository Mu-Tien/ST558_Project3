#required package
library(ggbiplot)
library(shiny)
library(dmm)
library(tidyverse)
library(caret)
library(readxl)
library(ggiraphExtra)
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
library(wesanderson)
library(stats)

# Define server logic required to draw a histogram
shinyServer(function(input, output, session){

#read in data
getwd()
data <- read.csv("diabetes_data.csv")

#transfer data type
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
#store data better
data <- as_tibble(data)
mydata$class <- as.factor(mydata$class)
mydata <- as_tibble(mydata)

# output math type equation
output$math <- renderUI({
   withMathJax(helpText('The summary number can represent the propotion in each group:  $$P[symptom=1]=x$$'))
})

#histogram of data
   output$histogram <- renderPlotly({
     ggplot(data=mydata, aes(x=Age))+geom_histogram(aes(fill=class))+
         labs(title = "Histogram for age seperate by test result")+
         facet_grid(.~Gender)+scale_fill_discrete(name="Test result", labels=c("Negative", "Positive"))+
         scale_fill_manual(values=wes_palette(n=2, name="Royal1"),labels=c("No", "Yes"))
   })

# bar plot of data
   output$barplot <- renderPlotly({
     t <- paste0("Bar plots for ", input$plotvar)
     ggplot(data=mydata)+geom_bar(aes_string(x=input$plotvar, fill="class"), position = "dodge")+
     facet_grid(.~Gender)+labs(title = t)+
     scale_fill_discrete(name="Test result", labels=c("Negative", "Positive"))+
     scale_fill_manual(values=wes_palette(n=2, name="Royal1"),labels=c("No", "Yes"))
   })
   
# summary table of data
   output$sumtable <- DT::renderDataTable({
      columns = names(data)
      columns = c("class", "Gender", "Age",input$summaryvar)
      newdata <- data[,columns,drop=FALSE]
      newdata <- newdata %>% select(class,Gender, everything())%>% rename(Reault=class)
      newdata$Reault <- as.numeric(newdata$Reault)
     if (input$groups=="Gender")
     sumdata <- newdata %>% group_by(Gender)
     else if(input$groups=="Test result")
       sumdata <- newdata %>% group_by(Reault)
     else if (input$groups=="Test result and Gender")
       sumdata <- newdata %>% group_by(Reault,Gender)
     
     sumdata <-sumdata %>% summarise_all(list(mean))
     sumdata<- round(sumdata,2)
     datatable(sumdata)
   })
   
# convert gender into numeric
     for (i in 1:nrow(data)){
       ifelse(data[i,2]=="Male",data[i,2] <- "1", data[i,2]<-"0" )
     }
     data$Gender <- as.numeric(data$Gender)
     
     
#PCA plots
   output$PCA <- renderPlotly({
      columns = names(data)
      columns = input$PCAVar
      newdata <- data[,columns,drop=FALSE]
      PCs <- prcomp(newdata, center=TRUE, scale=TRUE)
      ggbiplot(PCs, group=data$class)
      
   })

# Optimal number of cluster
   output$recomCluster <- renderPlotly({
     fviz_nbclust(data[,1:16], kmeans, method ="silhouette")
   })
   
#clustering using kmean
   output$kmean <- renderPlotly({
      columns = names(data)
      columns = input$kmeanVar
      newdata <- data[,columns,drop=FALSE]
     km.res <- kmeans(newdata,input$numclust)
     fviz_cluster(km.res, data = newdata,
                  ellipse.type = "convex",
                  palette = "jco")
   })

#Clustering using hierarchical clustering
   clust <- eventReactive(input$cluststart,
   {  
      columns = names(data)
      columns = input$HierVar
      newdata <- data[,columns,drop=FALSE]
      HierClust <- hclust(dist(newdata), method = "ward.D2")
      resultPlot <- fviz_dend(HierClust, k = input$clusteringNum, # Cut in k groups
                              cex = 0.5, # label size
                              palette = "jco",
                              show_labels = FALSE, # color labels by groups
                              rect = TRUE) # Add rectangle around groups
     }
   )
   
   output$Hierclust <- renderPlotly({
      clust()
   })
   
#separating training and testing data set
   train <- sample(1:nrow(mydata), size = nrow(mydata)*0.8)
   test <- dplyr::setdiff(1:nrow(mydata), train)
   diabetesdataTrain <- mydata[train, ]
   diabetesdataTest <- mydata[test, ]

#modeling1-logistic regression
   ## setting training control
   reg_control <- reactive({
      if (input$reg_trainmethod=="repeatedcv")
         trctrl_reg <- trainControl(method = input$reg_trainmethod, 
                                    number = input$reg_num_folders,
                                    repeats = input$reg_num_times)
      else
         trctrl_reg <- trainControl(method = input$reg_trainmethod, 
                                    number = input$reg_num_folders)
   })
   
   ##training model
   reg_model<- eventReactive(input$start_reg,{
      regmodel <- train(class~., data = diabetesdataTrain, method = "glm",
                       family="binomial",
                       trControl=reg_control(),
                       preProcess = c("center", "scale"))
                             })
   ## output result
   output$regTrain <- renderTable({
         regmodel <-reg_model()
         regmodel$results
                })
   
   ## testing model
   reg_test <-  eventReactive(input$start_test_reg,
                {reg_pred <- predict(reg_model(), newdata = diabetesdataTest[,1:16])
                 result <- postResample(reg_pred, diabetesdataTest$class)
                })
   
   ## showing testing result
   output$regTest <- renderText({
      result <- reg_test()
      paste0("When testing in test data set the Accuracy is ", round(result[1],2), " and Kappa is ", round(result[2],2))

   })
   
   ##read in predict data
   reg_predictdata <- reactive({
      data<-data.frame(Age=input$reg_age,Gender=input$reg_Gender,Polyuria=input$reg_Polyuria,Polydipsia=input$reg_Polydipsia,
                              sudden.weight.loss=input$reg_WL,weakness=input$reg_weakness,Polyphagia=input$reg_Polyphagia,Genital.thrush=input$reg_GT,
                              visual.blurring=input$reg_VB,Itching=input$reg_itch,Irritability=input$reg_irri,delayed.healing=input$reg_DH,
                              partial.paresis=input$reg_PP,muscle.stiffness=input$reg_MS,Alopecia=input$reg_Alopecia,Obesity=input$reg_Obesity)
   })
   
   ## output predict 
   ## print out prediction
   reg_pred <- eventReactive(input$regpred,{      
      model<-reg_model()
      data <-reg_predictdata()
      reg_pred <- predict(model,data)
      })
   
   ## output the result 
   output$reg_pred <- renderText({
      res <- ifelse(reg_pred()==0, "Negative", "Positive")
      paste0("Your prediction is ", res)
      })
   
#modeling2-tree based(rf, bagged, boosting)
   ##setting train control
   tree_control <- reactive({
      if (input$treemethod=="repeatedcv")
         trctrl_tree <- trainControl(method = input$treemethod, 
                                    number = input$tree_num_folders,
                                    repeats = input$tree_num_times)
      else
         trctrl_tree <- trainControl(method = input$treemethod, 
                                    number = input$tree_num_folders)
   })
   
   ## UI update for number of tree
   observe({updateSliderInput(session, "uppertree", min = input$lowertree+3, max=input$lowertree+15)})
   
   ## tuning parameter control
   param_control <- reactive({
      parameter <- expand.grid(n.trees=seq(input$lowertree,input$uppertree,1),
                           interaction.depth=5:10,
                           shrinkage=0.1, n.minobsinnode=10)
   })
   
   ## training tree model
   tree_model<- eventReactive(input$start_tree,{
      if (input$treetype=="rf")
         tree_fit <- train(class~., data = diabetesdataTrain, method = "rf",
                       trControl=tree_control(),
                       tuneLength =10,
                       preProcess = c("center", "scale"))
      
      else if (input$treetype=="treebag")
         tree_fit <- train(class~., data = diabetesdataTrain, method = "treebag",
                           trControl=tree_control(),
                           preProcess = c("center", "scale"))
      else
         tree_fit <- train(class~., data = diabetesdataTrain, method = "gbm",
                           trControl=tree_control(),
                           tuneGrid=param_control(),
                           preProcess = c("center", "scale"))
   })
   
   ## show the training plot
   output$treeTrainPlot <- renderPlot({
                   if (input$treetype=="treebag")
                   {}
                   else
                   plot(tree_model())
                })
   
   ## show the training result
   output$treeTrain <- renderTable({
      if (input$treetype=="treebag")
         tree_model()$results
      else
         tree_model()$bestTune
   })
   
   
   ## testing the model
   tree_pred <- eventReactive(input$start_test_tree,
                { tree_pred <- predict(tree_model(), newdata = diabetesdataTest[,1:16])
                  result <- postResample(tree_pred, diabetesdataTest$class)
                })
   ## output testing result
   output$treeTest <- renderText({
      result <- tree_pred()
      paste0("When testing in test data set the Accuracy is ", round(result[1],2), " and Kappa is ", round(result[2],2))
      })
   
   ## read in predict data
   treepredictdata <- reactive({
      data<-data.frame(Age=input$tree_age,Gender=input$tree_Gender,Polyuria=input$tree_Polyuria,Polydipsia=input$tree_Polydipsia,
                       sudden.weight.loss=input$tree_WL,weakness=input$tree_weakness,Polyphagia=input$tree_Polyphagia,Genital.thrush=input$tree_GT,
                       visual.blurring=input$tree_VB,Itching=input$tree_itch,Irritability=input$tree_irri,delayed.healing=input$tree_DH,
                       partial.paresis=input$tree_PP,muscle.stiffness=input$tree_MS,Alopecia=input$tree_Alopecia,Obesity=input$tree_Obesity)
      
   })

   ## print out prediction
   res_tree <- eventReactive(input$treepred,
                {  model <- tree_model()
                   data <- treepredictdata()
                   tree_pred <- predict(model, data)
                   res <- ifelse(tree_pred==0, "Negative", "Positive")
                })
   output$tree_pred <- renderText({
      paste0("Your prediction is ", res_tree())
      })

#data saving page   
   downloaddata<- data
   # Table of selected dataset
   costumerData <- eventReactive(input$filter,{
      columns = names(data)
      columns = input$column
      downloaddata <- data[,columns,drop=FALSE]
   })
   output$dataforuser <- renderTable({
      if(input$filterdata)costumerData()
      else downloaddata
   })
   # Downloadable csv of selected dataset 
   output$downloadData <- downloadHandler(
      filename = function(){
         if(input$filterdata)paste("SubsetDiabetesData", ".csv", sep = "")
         else paste("diabetesData", ".csv", sep = "")},
      content = function(file){
         if(input$filterdata) write.csv(costumerData(), file)
         else write.csv(downloaddata, file)}
      
   )
})
