README
================
Mu-Tien, Lee
2020/11/18

``` r
#install package used
install.packages(c("ggbiplot","shiny","dmm","tidyverse","caret","readxl","wesanderson",
                   "ggiraphExtra","ggplot2","dplyr","ggpubr","rpart.plot","rpart","remotes",
                   "DT","cluster","factoextra","magrittr","NbClust","plotly","stats",
                   "randomForest", "e1071", "gbm", "CRAN"))

#download ggbiplot
library(remotes)
install_github("vqv/ggbiplot")

#required package
library(gbm)
library(e1071)
library(randomForest)
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
```

``` r
runGitHub( "ST558_Project3", "Mu-Tien",subdir = "/Project3/")
```
