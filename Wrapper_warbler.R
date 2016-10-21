#This code is associated with Zipkin et al. 2014 Ecology and Evolution
#The code loads and formats warbler count data and then fits a structured
#Dail-Madsen model using the associated JAGS code "warbler.R".
#The code produces a summary of the parameter estimates for the model and model diagnostics
#(e.g., traceplots and R-hat statisic)

#This code runs with R version 3.2.2

#The warbler model is a 2-stage, 2 sex model
#Data are summarized from capture-recapure data at Hubard Brook from 1998-2010 by Scott sillett

#Load the library rjags
library(rjags)

#Data - desired format: (site, year, stage)
#Read in data files for male and female birds
males<- read.table("males.csv", header=TRUE,sep=",",na.strings=TRUE)
females<- read.table("females.csv", header=TRUE,sep=",",na.strings=TRUE)

nSites=length(unique(males$Elevation))
nYears=length(unique(males$Year))  #length(unique(females$Year))

#Define the sex/stage groups as follows:
## 1=m,yearling; 2=f,yearling; 3=m,adult; 4=f,adult
## 5=m,unknown, 6=f,unknown
nStages=6 
nReps=1

## Create an observation matrix y
y <- array(NA, dim=c(nSites,nYears,nStages), 
           dimnames=list(sort(unique(males$Elevation)),
                         sort(unique(males$Year)),c("MY","FY", "MA","FA", "MU","FU")) )       

Sites=c("high", "low",  "mid") 

#Fill in the data matrix y with male data
for (i in 1:nSites) {
a=males[which(males$Elevation==Sites[i]),]
b=pmatch(a$Year,dimnames(y)[[2]])
y[i,b,1]=a$Yearling
y[i,b,3]=a$Older
y[i,b,5]=a$UNK
}

#Fill in the data matrix y with female data
for (i in 1:nSites) {
  a=females[which(females$Elevation==Sites[i]),]
  b=pmatch(a$Year,dimnames(y)[[2]])
  y[i,b,2]=a$Yearling
  y[i,b,4]=a$Older
  y[i,b,6]=a$UNK
}


#Set the intital values to run the JAGS model
lamNew=rep(NA,4); omegaNew=rep(NA,4); gammaNew=rep(NA,2); QNew=rep(NA,2); CNew=rep(NA,2) 
lamNew[1] <- 3 * 10          # Initial population density
lamNew[2] <- 3 * 10  
lamNew[3] <- 3 * 10          
lamNew[4] <- 3 * 10  
omegaNew[1] <- 0.90          # Survival rate 
omegaNew[2] <- 0.90     
omegaNew[3] <- 0.90           
omegaNew[4] <- 0.90         
gammaNew[1] <- 3 * 10        # Recruitment rate 
gammaNew[2] <- 3 * 10


QNew[1] <- 0.95              # Detection probability
QNew[2] <- 0.95

CNew[1] <- 0.95
CNew[2] <- 0.95

Knew <- 50

#NNew and GNew are empty arrays
#Fix SNew to some value greater than zero
NNew <- array(NA, dim=c(nSites,nYears,4), 
              dimnames=list(sort(unique(males$Elevation)),
                            sort(unique(males$Year)),c("MY","FY", "MA","FA")) ) 

# S = Survivors; G=NewRecruits


GNew <- array(NA, dim=c(nSites,nYears-1,4), 
              dimnames=list(sort(unique(males$Elevation)),
                            1986:2009,c("MY","FY", "MA","FA")) )   
SNew <- array(2, dim=c(nSites,nYears-1,4), 
              dimnames=list(sort(unique(males$Elevation)),
                            1986:2009,c("MY","FY", "MA","FA")) ) 

ymax<- y[,,1:4]


#Add a big number to ymax for each stage to fill in the NNew matrix
NNew[1,11:25,] <- ymax[1,11:25,] +20
NNew[2,11:25,] <- ymax[2,11:25,] +20
NNew[3,1:25,] <- ymax[3,1:25,] +20


#Very important!!
#Make sure SNew+GNew=NNew or jags will not run!
GNew = NNew[,1:24,]-SNew
GNew[1:2,11,] = 20
SNew[1:2,1:11,] = NA

# Bundle data
Dat <- list(nSites=nSites, nYears=nYears, y=y) #nStages=nStages

# Set intial values
InitStage <- function() list(gamma=gammaNew, C=CNew, K=Knew,
                             omega=omegaNew, G=GNew, Q=QNew, S=SNew) 

# Parameters to be monitored
ParsStage <- c("lambda", "gamma", "omega", "Q", "C", "K",
               "Nall", "Ntt", "deviance") 
load.module("dic")

# Sequential - start the adaptive phase of the model 
StageBurnin1 <- jags.model(paste("warbler.r",sep=""), 
                           Dat, InitStage, n.chains=3, n.adapt=20000)


#Keep Niter/Nthin samples after the initial burn in of 20000 (above)
Niter=20000
Nthin=10
StageSample1 <- coda.samples(StageBurnin1, ParsStage, n.iter=Niter, thin=Nthin)

#Print out a summary of the parameter estimates
summary(StageSample1)

#Examine model fit
#Look at the trace plots
plot(StageSample1)

##Calculate the Rhat statistic
library(coda)
gelman.diag(StageSample1)

g <- matrix(NA, nrow=nvar(StageSample1), ncol=2)
for (v in 1:nvar(StageSample1)) {
  g[v,] <- gelman.diag(StageSample1[,v])$psrf
}

##Calculate the DIC of the model
chains=as.matrix(StageSample1)
dev=chains[,"deviance"]
######DIC
dic=mean(dev)+0.5*var(dev)


