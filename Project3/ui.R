# project 3 ui page

library(shiny)

# Define UI for application that draws a histogram
shinyUI(fluidPage(
#information page  
  tabsetPanel(
    tabPanel("Information",
             verticalLayout(
               h1("Using 13 symptoms to predict whether you have diabetes"),
               h4("The main idea of this project is to use 13 symptoms, 
                  Gender, Age,and the test result to build a model for diabetes."),
                  "The idea is to let everyone have a basic idea whether they have diabetes. Some people are
               not willing to go to the hospital for just a small symptoms. Therefore, this project can let them do the self-examination at home",
               h4("This report will contain 5 different parts:"),
               h4("1. The introduction"),
               h4("2. Data summary"),
               "In the data summary, I split the summary into two parts. First, you can choose any symptom that you are
               interesting in and see the propotion of its realetionship with diabetes.",
               uiOutput("math"),
               "In the second part, I will show you some plots that related to the data, again, 
               you can choose a symptom that you are interested in to find out the 
               relation between diabetes.",
               h4("3. Using unsupervised learning analysis the data"),
               "During the unsupervised learning page, you can use three different methods (PCA, k mean clustering and Hierachical clustering)
               to find out how great we can divided our dataset into groups.",
               h4("4. Using supervised learning modeling the data and let you try some prediction"),
               "For the supervised learning, you can choose your own model and training methods to training the model,
               Also, I will show you the acuuracy of the model you trained and let you do the prediction with it",
               "If you are only interested about the result, I recommend you to choose_, and do the prediction after training the model,
               because this model has the highest accuracy at all time",
               h4("5. Data saving"),
               "In the data saving page, I'll let you subset the dataset I used in this project and stored it",
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
                   checkboxGroupInput("summaryvar",label = "variables that you want to check",
                                      choices = names(data)[3:16],
                                      inline = TRUE),
                   DT::dataTableOutput("sumtable")
                 )),
             
             #vertical element 2- plots
             h3("Plot of data"),
             sidebarLayout(
               sidebarPanel(
                 h4("Select a symptom to see its relation with diabetes"),
                 selectInput("plotvar",label="Variables for the bar plot",
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
                 plotlyOutput("barplot"),
                 plotlyOutput("histogram")
               ))
             ) #end of vertical Layout
),# End of summary tab
    
#unsupervised learning page
    tabPanel("Unsupervised Learning",
             h1("Unsupervised learning"),
             
             #tab inside this page
             navlistPanel(
               
               #1st tab PCA
               tabPanel("PCA",
               verticalLayout(
                 h2("Principle Component Analysis"),
                 checkboxGroupInput("PCAVar",label = "Variables use in PCA",
                                    choices = names(data)[1:16],
                                    inline = TRUE),
                 h4("Here I show you two Most explained PCA element"),
                 plotlyOutput("PCA"))
               ), 
               #End of PCA
               
               #2nd tab clustering using k mean
               tabPanel("Clustering-K Mean",
               verticalLayout(
                 h2("Clustering using k mean method"),
                   #kmean
                   verticalLayout(
                     h3(em("Below plot shows you the optimal cluster")),
                     plotlyOutput("recomCluster"),
                     br(),
                     h3(em("Slelect the number of cluster and variables you want to use in the model")),
                     numericInput("numclust",label = "Number of cluster use in k mean",
                              value=2, min=2, max=5),
                     checkboxGroupInput("kmeanVar",label = "Variables use in k mean  (choose at least 3 variables)",
                                        choices = names(data)[1:16],
                                        inline = TRUE),
                     br(),
                     br(),
                     plotlyOutput("kmean"))
                 ),# End of vertical Layout
               ),#End of kmean
               
               #3rd tab cluster using hier
               
             tabPanel("Clustering-Hier",
                      #Hier
                      verticalLayout(
                        h2("Clustering using Hierarchical method"),
                        h3(em("Slelect the number of cluster and variables you want to use in the modle")),
                        numericInput("clusteringNum",label = "Number of cluster use in Hierarchical Clustering",
                                     value=2, min=2, max=5),
                        checkboxGroupInput("HierVar",label = "Variables use in Hierarchical",
                                           choices = names(data)[1:16],
                                           inline = TRUE),
                        actionButton("cluststart", "Start training"),
                        br(),
                        br(),
                        plotlyOutput("Hierclust")
                      )
                      ),#End of Hier
             
             widths = c(2,10)) #End of tabs in this page
             ),
    # End of unsupervised learning

#modeling page
    tabPanel("Modeling and Prediction",
             h1("Training supervised learning and do the prediction"),
             h4("There are two kind of model provided. You may choose it from the left hand side.
                In each model you can set up the training method and the parameter if needed."),
             h4("1. Please train your model fisrt."),
             h4("2. Please click on the code(start to test) to test your model."),
             h4("3. Finally, feel free to do the prediction."),
             br(),
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
                              actionButton("start_reg",label="Start training"),
                              actionButton("start_test_reg",label="Start testing")
                              ),
                            mainPanel(
                              h3(em("The accuracy of this model")),
                              tableOutput("regTrain"),
                              br(),
                              h3(em("The accuracy of this model on the testing dataset")),
                              textOutput("regTest")
                              
                              )
                          ),# end of training sidebar layout
                          
                          #predicting
                          sidebarLayout(
                            sidebarPanel(
                              h2("Predicting using Logistic regression"),
                              br(),
                              em("Some definition:"),
                              h5("Polyuria: body urinates more than usual "),
                              h5("Polydipsia: excessive thirst"),
                              h5("Polyphagia: extreme hunger"),
                              h5("Alopecia: hair  fall out in small patches"),
                              ),
                            mainPanel(
                              verticalLayout(
                              h2("Input all your symptom to do the prediction"),
                              fluidRow(column(3,radioButtons("reg_Gender","Gender",c("Male"="Male", "Female"="Female"))),
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
                              ),
                              actionButton("regpred","Start predicting"),
                              br(),
                              tableOutput("reg_preddata"),
                              h1(em(textOutput("reg_pred")))
                              )
                            )
                            )# end of predicting sidebar layout
             )# end of vertical Layout
               ),#End of Regression model tab
             
             #Tree based model
             tabPanel("Tree base model",
                      verticalLayout(
                        
                        #training
                        sidebarLayout(
                          sidebarPanel(
                            h2("Training tree model"),
                            #selection of tree type
                            radioButtons("treetype",
                                         label = "Select a tree you want ot use in the model",
                                         choices = c("Bagged tree"="treebag",
                                                     "Random forest"="rf",
                                                     "Boosted tree"="gbm")),
                            conditionalPanel(condition="input.treetype=='gbm'",
                                             sliderInput("lowertree",label="At least how many trees training in your model",
                                                         min=5, max=25, value=10)),
                            conditionalPanel(condition="input.treetype=='gbm'",
                                             sliderInput("uppertree",label="At most how many trees training in your model",
                                                         min=10, max=40, value=20)),
                            #selection of tree training methods
                            radioButtons("treemethod",
                                         label = "Select a method to do a training control",
                                         choices = c("Bootstrapt"="boot",
                                                     "Cross validation"="cv",
                                                     "Repeated cross validation"="repeatedcv",
                                                     "Leave one out cross validation"="LOOCV")),
                            sliderInput("tree_num_folders", 
                                        label="Select number of folders using in training method",
                                        min=1, max=10, value=3),
                            conditionalPanel(condition="input.treemethod=='repeatedcv'",
                                             sliderInput("tree_num_times",label="How many times to repeat cross validation",
                                                         min=1, max=10, value=3)),
                            actionButton("start_tree",label="Start training"),
                            actionButton("start_test_tree",label="Start testing")
                            
                          ),
                          mainPanel(
                            h3(em("The accuracy of this model")),
                            plotOutput("treeTrainPlot"),
                            h3(em("The best tuning parameters of this model is")),
                            tableOutput("treeTrain"),
                            br(),
                            h3(em("The accuracy of this model on the testing dataset")),
                            textOutput("treeTest")
                            
                          )
                        ),# end of training sidebar layout
                        
                        #predicting
                        sidebarLayout(
                          sidebarPanel(
                            h2("Predicting using Tree based model"),
                            br(),
                            em("Some definition:"),
                            h5("Polyuria: body urinates more than usual "),
                            h5("Polydipsia: excessive thirst"),
                            h5("Polyphagia: extreme hunger"),
                            h5("Alopecia: hair  fall out in small patches"),
                          ),
                          mainPanel(
                            verticalLayout(
                              h2("Input all your symptom to do the prediction"),
                              fluidRow(column(3,radioButtons("tree_Gender","Gender",c("Male"="Male", "Female"="Female"))),
                                       column(3,numericInput("tree_age", "Your age",30, min=10, max=100)),
                                       column(3,radioButtons("tree_Polyuria","Polyuria",c("Yes"=1, "No"=0))),
                                       column(3,radioButtons("tree_Polydipsia","Polydipsia ",c("Yes"=1, "No"=0)))
                              ),
                              fluidRow(
                                column(3,radioButtons("tree_WL","Sudden weight loss",c("Yes"=1, "No"=0))),
                                column(3,radioButtons("tree_weakness","Weakness",c("Yes"=1, "No"=0))),
                                column(3,radioButtons("tree_Polyphagia","Polyphagia",c("Yes"=1, "No"=0))),
                                column(3,radioButtons("tree_GT","Genital thrush",c("Yes"=1, "No"=0)))
                              ),
                              fluidRow(
                                column(3,radioButtons("tree_VB","Visual blurring",c("Yes"=1, "No"=0))),
                                column(3,radioButtons("tree_itch","Itching",c("Yes"=1, "No"=0))),
                                column(3,radioButtons("tree_irri","Irritability",c("Yes"=1, "No"=0))),
                                column(3,radioButtons("tree_DH","Delayed healing",c("Yes"=1, "No"=0)))
                              ),
                              fluidRow(
                                column(3,radioButtons("tree_PP","Partial paresis",c("Yes"=1, "No"=0))),
                                column(3,radioButtons("tree_MS","Muscle stiffness",c("Yes"=1, "No"=0))),
                                column(3,radioButtons("tree_Alopecia","Alopecia",c("Yes"=1, "No"=0))),
                                column(3,radioButtons("tree_Obesity","Obesity",c("Yes"=1, "No"=0)))
                              ),
                              actionButton("treepred","Start predicting"),
                              br(),
                              tableOutput("tree_preddata"),
                              h1(em(textOutput("tree_pred")))
                            )
                          )
                        )# end of predicting sidebar layout
                      )# end of vertical Layout
             ),#End of tree base model tab

             widths = c(2,10))# end of tabs in this tab
    ),
    #end of modeling page

#data saving page
    tabPanel("Data saving",
             h1("Welocme to download the data I used if you want"),
             
             sidebarLayout(
               sidebarPanel(
                 h4("Check the box if you want to subset the dataset"),
                 checkboxInput("filterdata", label="Do you want to subset this dataset ?"),
                 conditionalPanel(condition ="input.filterdata==1", 
                                  checkboxGroupInput("column", label = "Choose the variables you want",
                                                     names(data))),
                 conditionalPanel(condition ="input.filterdata==1", 
                                  actionButton("filter", "show my subset")),
                 downloadButton("downloadData", "Download")
               ),
               
               # Main panel for displaying outputs ----
               mainPanel(
                 tableOutput("dataforuser")
               ))
    
  )
))
)