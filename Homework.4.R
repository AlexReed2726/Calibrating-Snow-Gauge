#############################################################################
## Math 289C                                                               ##
## Case Study 4                                                            ##                                                
## Group: Siyue Wu, Alexander Reed, Yichao Yang, Zach Caamano-Withall,     ##
##        Bibi Jiang, Wanting Chen                                         ##
## Date: Feb 29, 2016                                                      ##
#############################################################################
##
rm(list=ls())     # clear all data
graphics.off()    # close all figures 
cat("\014")       # clear the console
##
#############################################################################

data = read.table(file="http://www.stat.berkeley.edu/users/statlabs/data/gauge.data", header=T)
attach(data)

# install.packages("e1071")
library(e1071)

newgain=tapply(data[,2],rep(1:9,each=10),FUN=mean)
newdensity=unique(density)
newdata=cbind(newdensity,newgain)
#############################################################################
# Problem 1 [Fitting]
#############################################################################
##
## try to find the correlation between density and gain
## the graph told us they have coreelation, since it is ellips not circle
require(ellipse)
plotcorr(cor(data))
##
# try to plot the data and fit with linear model first
par(mfrow=c(1,1))
fit1=lm(density~gain)
plot(gain,density)
abline(fit1, col="red")
summary(fit1)
#boxplot for residuals
boxplot(residuals(fit1), main="boxplot for residual")
# standardized residuals vs. fitted values 
plot(fit1, which=3)
##
##
# try to plot the data and transfer gain to log(gain), then fit it
par(mfrow=c(1,1))
fit2=lm(density~I(log(gain)))
plot(log(gain),density,main="regression for log(gain) VS density")
abline(fit2, col="red")
summary(fit2)
#boxplot for residuals
boxplot(residuals(fit2), main="boxplot for residual")
# standardized residuals vs. fitted values 
plot(fit2, which=3)
##
##
# try to plot the data and transfer gain to log(gain), then fit it
par(mfrow=c(1,1))
fit3=lm(density~poly(gain,2,raw=T))
plot(gain,density,main="regression for polynomial regression degree 2")
pts=seq(min(gain),max(gain),len=100)
val=predict(fit3,data.frame(gain=pts))
lines(pts,val,col="red",lwd=3)
#boxplot for residuals
boxplot(residuals(fit3), main="boxplot for residual")
# standardized residuals vs. fitted values 
plot(fit3, which=3)


## Support Vector Machine

fit.SVM.radial <- svm(newdensity ~ newgain, data=newdata, type="eps", kernel="radial")
Xval <- seq(min(newgain), max(newgain), length = 500)
predictedY.radial <- predict(fit.SVM.radial, data.frame(newgain = Xval))
plot(newdensity~newgain)
lines(Xval, predictedY.radial, col="red")
tuneParam <- tune(svm, newdensity ~ newgain, data=data.frame(newdata), ranges = list(epsilon = seq(0.05,0.15,0.01),
                                                       cost = 1:6),tunecontrol=tune.control(sampling = "cross",cross=5))
print(tuneParam)
tunedSVM <- tuneParam$best.model
tunePredictedY <- predict(tunedSVM, data.frame(newgain=Xval))
lines(Xval, tunePredictedY, col="blue")

## do the regression for the new average data
par(mfrow=c(1,1))
attach(data.frame(newdata))
fit4=lm(newdensity~I(log(newgain)))
plot(log(newgain),newdensity,main="regression for log(gain) VS density")
abline(fit4, col="red")
summary(fit4)
#boxplot for residuals
boxplot(residuals(fit4), main="boxplot for residual")
# standardized residuals vs. fitted values 
plot(fit4, which=3)

#############################################################################
# Problem 2 [predicting]
#############################################################################
# using fit3 above to predict
val1=predict(fit4,data.frame(newgain=38.6))
val2=predict(fit4,data.frame(newgain=426.7))
print(paste("the density for gain=38.6 is:",val1))
print(paste("the density for gain=426.7 is:",val2,
            "since the density cannot be negative, so the density is 0"))
# plot the 95% bands
plot(newdensity ~ log(newgain), type = 'n')
pts=seq(2.5, 6.5, len = 100)
val=predict(fit4, data.frame(newgain=exp(pts)),interval = 'prediction')
lines(pts, val[ ,3], lty = 'dashed', col = 'red')
lines(pts, val[ ,2], lty = 'dashed', col = 'red')
polygon(c(rev(pts), pts), c(rev(val[ ,3]), val[ ,2]), col = 'grey80', border = NA)
abline(fit4)
points(log(newgain), newdensity, col="blue")

#############################################################################
# Problem 3 [cross validation]
#############################################################################
  validation=newdata[which(newdata[,1]==0.508),]
  train=newdata[which(newdata[,1]!=0.508),]
  attach(data.frame(train))
  fit=lm(newdensity~I(log(newgain)),data=data.frame(train))
  value=predict(fit,data.frame(newgain=validation[2]))
  error=sum((validation[1]-value)^2)/length(validation)
  value=predict(fit, data.frame(newgain=38.6),interval = 'prediction')
  print(paste("The fit is ",value[1]," The lower bound is ", value[2]," The upper bound is ",value[3]))
  
  
  
  validation=newdata[which(newdata[,1]==0.001),]
  train=newdata[which(newdata[,1]!=0.001),]
  attach(data.frame(train))
  fit=lm(newdensity~I(log(newgain)),data=data.frame(train))
  value=predict(fit,data.frame(newgain=validation[2]))
  error=sum((validation[1]-value)^2)/length(validation)
  value=predict(fit, data.frame(newgain=426.7),interval = 'prediction')
  print(paste("The fit is ",value[1]," The lower bound is ", value[2]," The upper bound is ",value[3]))
  



