# data analysis template
# we define knitr chunks here which  can be picked up by Rnw or Rmd files for document generation

# knitr uses Rmd fil location as working directory
# if we run script from Rstudio we need to put the right working dir
# setwd("~/r-studio/dataMineR/1-data-understanding")

library(knitr)

## @knitr setup

# all inline!

## @knitr read_data
i=1

# data location full path to filename from working directory(=project dir)
# This works by default from the relative path
path2file <- "../data/data-simple-example.tab"

# read dataframe from tab delimets file
data <- read.delim(path2file,sep = "\t",strip.white = TRUE)

# determine number of rows and colums in dataframe
rows <- nrow(data)
colums <- ncol(data)

# case_id = registrnr
original_case_id = 'caseID'
#data$caseID <- data$caseID

# check if case_id is unique
if( ! (length(unique(data$caseID)) == length(data$caseID)) ){
        cat('Warning : Case_id appears not unique ! ')}

# exclude original case_id and variables with lot of missing
#exclude_var_names <- c('caseID','registrnr','X2011tmoktstornaant','X2010stornoaantal')
exclude_var_names <- c('p_y','p_real','y')
data <- data[,!names(data) %in% exclude_var_names]

## @knitr var_types
# names in header
var_names <- names(data)

# sometimes variabels are in the dataset as codes, they appear numeric but code for a category

##treat_as_categorical <- c("catHHINKOMEN","catHHSOCIALE","catHHOPLEIDI","catHHLEVENSF","catHHGEOTYPE","catHHTYPEWO",
##"catHHEIGENDO","catHHWOZWAA", "catBELEGGERS","catLENERS",   "catSPAARDERS","catSWITCHGEVO"      
##,"catMERKENTROU")
treat_as_categorical <- NULL

# transform numeric into factors
data[treat_as_categorical] <- lapply(data[treat_as_categorical], as.factor)

num_var_names <- names(data[sapply(data, is.numeric)])
num_vars <- length(num_var_names)
cat_var_names <- names(data[sapply(data, is.factor)])
cat_vars <- length(cat_var_names)

## @knitr num-overview-md
library(pander)

# summarize numeric variables
td <- data[,sapply(data, is.numeric)]
td.min <- sapply(td,min,na.rm = TRUE)
td.mean <- sapply(td,mean,na.rm = TRUE)
td.median <- sapply(td,median,na.rm = TRUE)
td.max <- sapply(td,max,na.rm = TRUE)
td.n <- as.numeric(apply(td, 2, function(x) length(which(!is.na(x)))))
td.na <- as.numeric(apply(td, 2, function(x) length(which(is.na(x)))))
td.q <- apply(td,2,quantile,na.rm = TRUE)

tddf <- data.frame(cbind(td.n,td.na,td.min,td.mean,td.median,td.max))
names(tddf) <- c('n obs','n missing','min','mean','median','max')

#print(xtable(tddf),type='html')
panderOptions('table.split.table', Inf)
pander(tddf)
panderOptions('table.split.table', 80)

## run numeric template for each numeric variable seperately

## @knitr run-numeric-md
out = NULL
for (i in c(1:num_vars)) {
  out = c(out, knit_child('da-numeric.Rmd'))
}

## @knitr cat-overview
c_data <- data[sapply(data, is.factor)]
# check number of levels per factor
c_levels <-  sapply(c_data,nlevels)
max_levels <- 25
# trick if only one colum left we need to make sure still a dataframe to keep the names attached
c_data.limited_levels <- c_data[,c_levels <= max_levels, drop=FALSE ]
c_data.not_reported <- c_data[,c_levels > max_levels]

# keep only those with limited number of factors for reporting
c_var_names <- names(c_data.limited_levels)
if (ncol(c_data.not_reported) == 0){
  c_var_names.not_reported <- c('no variabes to report')
} else {
  c_var_names.not_reported <- names(c_data.not_reported)
}
num_c_vars_lim <- length(c_var_names)

## @knitr cat-levels-md
library(xtable)
library(pander)

# report missing values
c_num_missing <- colSums(is.na(c_data))
t <- data.frame(c_levels,c_num_missing)
# sort ascending 
#t_sorted <- t[with(t, order(nct)), ]
xt <- xtable(t)
digits(xt) <- c(0,0,0)

names(xt) <- c('levels','missings')
pander(xt)

## @knitr run-categoric-md
out = NULL
for (i in c(1:num_c_vars_lim)) {
  out = c(out, knit_child('da-categorical.Rmd'))
}

## @knitr save-data
datasetName = "../data/data-analysis.tab"
write.table(data,file = datasetName, sep = "\t", row.names=FALSE, quote = FALSE)

