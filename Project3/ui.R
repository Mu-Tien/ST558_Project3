# project 3 ui page

library(shiny)

# Define UI for application that draws a histogram
shinyUI(fluidPage(
#information page  
  tabsetPanel(
    tabPanel("Information",
             verticalLayout(
               h1("Using 13 symptoms to predict wheather you have diabetes"),
               h4("The main idea of this project is to use 13 symptoms, 
                  Gender, Age,and the test result to build a model for diabetes. 
                  This report will contain 5 different parts:"),
               h5("1. The introduction"),
               h5("2. Data summary"),
               h5("3. Usgin unsupervised learning analysis the data"),
               h5("4. Using supervised learning modeling the data and let you try some prediction"),
               h5("5. Data saving"),
               br(),
               h4("The data was download from", a(herf="from UCI Machine learning repository","https://archive.ics.uci.edu/ml/datasets/Early+stage+diabetes+risk+prediction+dataset."))
             )),
#Data summarize page
    tabPanel("Data exploration",
             verticalLayout(
             #title
               h1("Data exploration- summary table and plots"),
               
             #vertical element 1 - tables
               h3("Summary data"),
               sidebarLayout(
                 sidebarPanel(
                   radioButtons("groups",label="Choose variables you would like to group with",
                                      choices = list("Gender", "Test result", "Test result and Gender"))
                 ),
                 mainPanel(
                   DT::dataTableOutput("sumtable")
                 )),
             
             #vertical element 2- plots
             h3("Plot of data"),
             sidebarLayout(
               sidebarPanel(
                 h4("Select 2 symptom to see their relation with diabetes"),
                 selectInput("plotvar1",label="First Variables for the scatter plot",
                             choices = list("Polyuria",
                                            "Polydipsia",
                                            "sudden weight loss"="sudden.weight.loss",
                                            "weakness",
                                            "Polyphagia",
                                            "Genital thrush"="Genital.thrush",
                                            "visual blurring"="visual.blurring",
                                            "Itching",
                                            "Irritability",
                                            "delayed healing"="delayed.healing",
                                            "partial paresis"="partial.paresis",
                                            "muscle stiffness"="muscle.stiffness",
                                            "Alopecia",
                                            "Obesity")),
                 selectInput("plotvar2",label="Second Variables for the scatter plot",
                             choices = list("Polyuria",
                                            "Polydipsia",
                                            "sudden weight loss"="sudden.weight.loss",
                                            "weakness",
                                            "Polyphagia",
                                            "Genital thrush"="Genital.thrush",
                                            "visual blurring"="visual.blurring",
                                            "Itching",
                                            "Irritability",
                                            "delayed healing"="delayed.healing",
                                            "partial paresis"="partial.paresis",
                                            "muscle stiffness"="muscle.stiffness",
                                            "Alopecia",
                                            "Obesity"))
               ),
               mainPanel(
                 plotlyOutput("scatter"),
                 plotlyOutput("histogram")
               ))
             ) #end of vertical Layout
),# End of summary tab
    
#unsupervised learning page
    tabPanel("Unsupervised Learning",
             h1("Unsupervised learning"),
             
             #tab inside this page
             navlistPanel(
               
               #PCA
               tabPanel("PCA",
               verticalLayout(
                 h2("Principle Component Analysis"),
                 plotlyOutput("PCA"))
               ), 
               #End of PCA
               
               #clustering
               tabPanel("Clustering",
               verticalLayout(
                 h2("Clustering"),
                 
                 #split two different method (kmean and hier)
                 splitLayout(
                   #kmean
                   verticalLayout(
                     h3(em("k means Clustering")),
                     plotlyOutput("recomCluster"),
                     numericInput("numclust",label = "Number of cluster use in k mean",
                              value=2, min=2, max=5),
                     plotlyOutput("kmean")),
                   #End of kmean
                   
                   #Hier
                   verticalLayout(
                     h3(em("Hierarchical Clustering")),
                     numericInput("clusteringNum",label = "Number of cluster use in Hierarchical Clustering",
                                  value=2, min=2, max=5),
                     plotlyOutput("Hierclust")
                   )
                   #End of Hier
                   )
               )# End of vertical Layout
             ),
             #End of clustering
             
             widths = c(2,10)) #End of tabs in this page
             ),
    # End of unsupervised learning

#modeling page
    tabPanel("Modeling and Prediction",
             h1("Training supervised learning and do the prediction"),
             #tab inside this page
             navlistPanel(
               #Regression model
               tabPanel("Regression model",
                        verticalLayout(
                          
                          #training
                          sidebarLayout(
                            sidebarPanel(
                              h2("Training Logistic regression"),
                              radioButtons("reg_trainmethod",
                                           label = "Select a method to do a training control",
                                           choices = c("Bootstrapt"="boot",
                                                       "Cross validation"="cv",
                                                       "Repeated cross validation"="repeatedcv",
                                                       "Leave one out cross validation"="LOOCV")),
                              sliderInput("reg_num_folders", 
                                          label="Select number of folders using in training method",
                                          min=1, max=10, value=3),
                              conditionalPanel(condition="input.reg_trainmethod=='repeatedcv'",
                                               sliderInput("reg_num_times",label="How many times to repeat cross validation",
                                                           min=1, max=10, value=3)),
                              actionButton("start_reg",label="Start training")
                              ),
                            mainPanel(
                              textOutput("regTrain")
                              )
                          ),# end of training sidebar layout
                          
                          #predicting
                          sidebarLayout(
                            sidebarPanel(
                              h2("Predicting using Logistic regression")
                              ),
                            mainPanel(
                              verticalLayout(
                                h2("Input all your symptom to do the prediction"),
                              fluidRow(column(3,radioButtons("reg_Gender","Gender",c("Male", "Female"))),
                                       column(3,numericInput("reg_age", "Your age",30, min=10, max=100)),
                                       column(3,radioButtons("reg_Polyuria","Polyuria",c("Yes"=1, "No"=0))),
                                       column(3,radioButtons("reg_Polydipsia","Polydipsia ",c("Yes"=1, "No"=0)))
                                       ),
                              fluidRow(
                                       column(3,radioButtons("reg_WL","Sudden weight loss",c("Yes"=1, "No"=0))),
                                       column(3,radioButtons("reg_weakness","Weakness",c("Yes"=1, "No"=0))),
                                       column(3,radioButtons("reg_Polyphagia","Polyphagia",c("Yes"=1, "No"=0))),
                                       column(3,radioButtons("reg_GT","Genital thrush",c("Yes"=1, "No"=0)))
                              ),
                              fluidRow(
                                       column(3,radioButtons("reg_VB","Visual blurring",c("Yes"=1, "No"=0))),
                                       column(3,radioButtons("reg_itch","Itching",c("Yes"=1, "No"=0))),
                                       column(3,radioButtons("reg_irri","Irritability",c("Yes"=1, "No"=0))),
                                       column(3,radioButtons("reg_DH","Delayed healing",c("Yes"=1, "No"=0)))
                              ),
                              fluidRow(
                                       column(3,radioButtons("reg_PP","Partial paresis",c("Yes"=1, "No"=0))),
                                       column(3,radioButtons("reg_MS","Muscle stiffness",c("Yes"=1, "No"=0))),
                                       column(3,radioButtons("reg_Alopecia","Alopecia",c("Yes"=1, "No"=0))),
                                       column(3,radioButtons("reg_Obesity","Obesity",c("Yes"=1, "No"=0)))
                              )
                              )
                            )
                            )# end of predicting sidebar layout
             )# end of vertical Layout
               ),#End of Regression model tab
             widths = c(2,10))# end of tabs in this tab
    ),
    #end of modeling page

#data saving page
    tabPanel("Data saving",
             "")
    
  )
))
