###### ANALYSIS OF ACCURACY ACROSS POSITIONS ######

# load in results
newdata = read.delim("resultsVOTinfo.txt",as.is=T)

# place of articulation effects, correct productions
aggregate(VOT~POA+productionVoicing, data=newdata[newdata$correct=="correct",],mean)

# calc mean proportion correct for each participant in each condition
library(plyr)
# code correct/error numerically
newdata$accuracyCode = ifelse(newdata$correct=="correct",1,0)
# get error rate within each condition for each subject
error.Condition = ddply(newdata,.(Subject,Order,Pair.Status,elementInOrder),summarize,PropCorrect = mean(accuracyCode))
# get mean error rate across participants
means.error.Condition = ddply(error.Condition,.(Order,Pair.Status,elementInOrder),summarize,PropCorrectMean = mean(PropCorrect))

# bootstrap estimates of 95% CI for proportion correct (across participants) in each condition
library(boot)
#bootstrap function; calculate mean within conditions
boot.mean.fnc <- function (data,indices){
	# select data at each index
	d <- data[indices,]
	# calculate by participant means
	mean.calc <- ddply(d,.(Order,Pair.Status,elementInOrder),summarize,PropCorrectMean = mean(PropCorrect))
	return(mean.calc$PropCorrectMean)
}

boot.results <- boot(data = error.Condition,statistic=boot.mean.fnc,R=1000) # 1000 bootstrap replicates

# add in upper and lower bounds on 95% confidence interval
means.error.Condition$upperCI = -999
means.error.Condition$lowerCI = -999
for (i in 1:length(means.error.Condition$Order)){
	means.error.Condition$upperCI[i] = boot.ci(boot.results,type="perc",index=i)$perc[,5] # get upper 95%ile
	means.error.Condition$lowerCI[i] = boot.ci(boot.results,type="perc",index=i)$perc[,4] # get lower 95%ile
}

# print out results
means.error.Condition