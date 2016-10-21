#Examine some results of the model and make some figures

#Pull out the parameter estimates
chains=as.matrix(StageSample1)

l1=chains[,"lambda[1]"]
l2=chains[,"lambda[2]"]
l3=chains[,"lambda[3]"]

g1=chains[,"gamma[1]"]
g2=chains[,"gamma[2]"]

o1=chains[,"omega[1]"]
o2=chains[,"omega[2]"]
o3=chains[,"omega[3]"]
o4=chains[,"omega[4]"]

p1=chains[,"Q[1]"]
p2=chains[,"Q[2]"]

c1=chains[,"C[1]"]
c2=chains[,"C[2]"]

K=chains[,"K"]


#Create a matrix with the posterior distribution of survival estimates
#for male/female yearlings/adults
sur =  matrix(NA, ncol=4, nrow=length(o1))
sur[,1]=o1
sur[,2]=o2
sur[,3]=o3
sur[,4]=o4
colnames(sur)=c("Male yearlings","Female yearlings",
                "Male adults","Female adults")


###Plot the survivoral parameters
par(mfrow=c(1,1), mar=c(5,5,2,1))
boxplot(sur, ylim=c(0,0.85), ylab="Survival probability", cex.lab=1.4,
        show.names=TRUE, cex.axis=1.2)

###Plots for the detection models - detection and classification probabilities
pp =  matrix(NA, ncol=2, nrow=length(p1))
pp[,1]=p1
pp[,2]=p2
colnames(pp)=c("Males","Females")

cc =  matrix(NA, ncol=2, nrow=length(c1))
cc[,1]=c1
cc[,2]=c2
colnames(cc)=c("Males","Females")

par(mfrow=c(1,2), mar=c(5,2.5,2,1))
boxplot(pp, xlab="Detection probability", cex.lab=1.3, 
        show.names=TRUE, ylim=c(0.5,1))

boxplot(cc, xlab="Classification probability", cex.lab=1.3,
        show.names=TRUE, ylim=c(0.85,1))


################################################################################
#Create a plot showing the parameter values - Figure 3 from the paper

#Load the necessary libraries
library(ggplot2)
library(denstrip)
library(lattice)
library(reshape)

#Create a new matrix including all desired parameters to plot
params =  matrix(NA, ncol=8, nrow=length(o1))
params[,1]=o1
params[,2]=o2
params[,3]=o3
params[,4]=o4
params[,5]=p1
params[,6]=p2
params[,7]=c1
params[,8]=c2
colnames(params)=c("Male yearling survival","Female yearling survival",
                "Male adult survival","Female adult suvival",
                "Male detection","Female detection",
                "Male classification","Female classification")

preds <- as.data.frame(params)

#Sort effects by median size
idx<-8:1

#Apply and sort labels
labs = colnames(params)[idx]

mp=melt(preds[,idx])

#Create the plot
x11()
rpp = bwplot(variable~value,data=mp,xlab=list(label="Parameter probability values",cex=1.3), xlim=c(-0.05,1.1),
             ,panel = function(x, y) { 
               #grid.segments(1,0,0,0)
               xlist <- split(x, factor(y))
               for (i in seq(along=xlist))
                 panel.denstrip(x=xlist[[i]], at=i)
             },par.settings = list(axis.line = list(col=NA)),
             scales=list(col=1,cex=1,x=list(col=1),
                         y=list(draw=T,labels=labs)))
print(rpp)

#Add lines and text
trellis.focus("panel", 1, 1)
panel.lines(c(-0.05,1.05),c(0.4,0.4), col="black")
panel.lines(c(-0.05,1.05),c(8.6,8.6), col="black")

panel.lines(c(median(o1),median(o1)), c(7.8,8.2), lwd=7,col="black")
panel.text("(0.04 , 0.35)", y=7.6, x=median(o1), cex=0.8, col="gray35")

panel.lines(c(median(o2),median(o2)), c(6.8,7.2), lwd=7,col="black")
panel.text("(0.04 , 0.49)", y=6.6, x=median(o2), cex=0.8, col="gray35")

panel.lines(c(median(o3),median(o3)), c(5.8,6.2), lwd=7,col="black")
panel.text("(0.01 , 0.41)", y=5.6, x=median(o3), cex=0.8, col="gray35")

panel.lines(c(median(o4),median(o4)), c(4.8,5.2), lwd=7,col="black")
panel.text("(0.06 , 0.49)", y=4.6, x=median(o4), cex=0.8, col="gray35")

panel.lines(c(0.50,0.50), c(7.8,8.2), col="grey", lwd=6)
panel.lines(c(0.42,0.42), c(6.8,7.2), col="grey", lwd=6)
panel.lines(c(0.51,0.51), c(5.8,6.2), col="grey", lwd=6)
panel.lines(c(0.46,0.46), c(4.8,5.2), col="grey", lwd=6)

panel.text("(0.83 , 0.96)", y=3.7, x=median(p1), cex=0.8, col="gray45")
panel.text("(0.68 , 0.83)", y=2.7, x=median(p2), cex=0.8, col="gray45")

panel.text("(0.98 , 1.00)", y=1.7, x=median(c1), cex=0.8, col="gray45")
panel.text("(0.90 , 0.94)", y=0.7, x=median(c2), cex=0.8, col="gray45")

trellis.unfocus()




