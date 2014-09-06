##### MONTE CARLO PROCEDURE FOR VOICELESS CONSONANTS, BY-PARTICIPANT ANALYSIS #####

# load in correct productions and matched errors
voicelessErrsMatched = read.delim("voicelessErrsMatched.txt")
voicelessCor = read.delim("voicelessCor.txt")

# calculate by-participant values to seed the list of monte carlo-generated values
subVars = aggregate(VOT~Subject,data=voicelessErrsMatched,sd)

# seed variance, mean, by-ordering lists
sampleVariance = data.frame(t(subVars$VOT))
sampleVarianceABBA = data.frame(t(subVars$VOT))
sampleVarianceABAB = data.frame(t(subVars$VOT))
sampleMean = data.frame(t(subVars$VOT))
sampleMeanABBA = data.frame(t(subVars$VOT))
sampleMeanABAB = data.frame(t(subVars$VOT))
sampleMeanAN = data.frame(t(subVars$VOT))
sampleMeanBN = data.frame(t(subVars$VOT))
sampleMeanAMP = data.frame(t(subVars$VOT))
sampleMeanBMP = data.frame(t(subVars$VOT))

# for 1,000 replicates
for (resample in 1:1000){

# seed data frame storing re-sampled correct productions
varianceSample = voicelessCor[1,]
# resample 
# for each subject
for (i in unique(voicelessErrsMatched$Subject)){
	# in each condition
	for (j in unique(voicelessErrsMatched$Order)){
		# for each item (quadruplet)
		for (k in unique(voicelessErrsMatched$item)){
			# for each pair
			for (l in unique(voicelessErrsMatched$Pair.Status)){
				# for each element in pair
				for (m in unique(voicelessErrsMatched$elementInOrder)){
					# if there are observations in the set of errors…
					nErrs = length(voicelessErrsMatched$VOT[voicelessErrsMatched$Subject == i & voicelessErrsMatched$Order == j & voicelessErrsMatched$item == k & voicelessErrsMatched$Pair.Status == l & voicelessErrsMatched$elementInOrder == m]) 
					if (nErrs > 0){
						# find corresponding correct productions (other member of the pair)						
						n = ifelse(m=="A","B","A")
						relCors = voicelessCor[voicelessCor$Subject == i & voicelessCor$Order == j & voicelessCor$item == k & voicelessCor$Pair.Status == l & voicelessCor$elementInOrder == n,]
						# generate a random sample of indices from this list
						sampleIndices = sample(1:length(relCors$VOT),nErrs)
						# add random sample onto list of correct productions sample
						varianceSample = rbind(varianceSample,relCors[sampleIndices,])						
					}
				}
			}		
		}
	}
}
# excluded dummy first observation
varianceSample = varianceSample[-1,]


# calculate statistics over random sample and add onto stored lists
# by-subject variance
sampleVars = aggregate(VOT~Subject,data=varianceSample,sd)
sampleVariance = rbind(sampleVariance,data.frame(t(sampleVars$VOT)))

# by-subject variance across tongue twister ordering conditions
sampleVars = aggregate(VOT~Subject+Order,data=varianceSample,sd)
sampleVarianceABBA = rbind(sampleVarianceABBA,data.frame(t(sampleVars$VOT[sampleVars$Order=="ABBA"])))
sampleVarianceABAB = rbind(sampleVarianceABAB,data.frame(t(sampleVars$VOT[sampleVars$Order=="ABAB"])))

# by-subject means
sampleMeans = aggregate(VOT~Subject,data=varianceSample,mean)
sampleMean = rbind(sampleMean,data.frame(t(sampleMeans$VOT)))

# by-subject means across tongue twister ordering conditions
sampleMeans = aggregate(VOT~Subject+Order,data=varianceSample,mean)
sampleMeanABBA = rbind(sampleMeanABBA,data.frame(t(sampleMeans$VOT[sampleMeans$Order=="ABBA"])))
sampleMeanABAB = rbind(sampleMeanABAB,data.frame(t(sampleMeans$VOT[sampleMeans$Order=="ABAB"])))

# by-subject means across positions in quadruplet
samplePositionMeans = aggregate(VOT~Subject+elementInOrder+Pair.Status,data=varianceSample,mean)
sampleMeanAN = rbind(sampleMeanAN,data.frame(t(samplePositionMeans$VOT[samplePositionMeans$elementInOrder=="A" & samplePositionMeans$Pair.Status == "noMinPair"])))
sampleMeanBN = rbind(sampleMeanBN,data.frame(t(samplePositionMeans$VOT[samplePositionMeans$elementInOrder=="B" & samplePositionMeans$Pair.Status == "noMinPair"])))
sampleMeanAMP = rbind(sampleMeanAMP,data.frame(t(samplePositionMeans$VOT[samplePositionMeans$elementInOrder=="A" & samplePositionMeans$Pair.Status == "minPair"])))
sampleMeanBMP = rbind(sampleMeanBMP,data.frame(t(samplePositionMeans$VOT[samplePositionMeans$elementInOrder=="B" & samplePositionMeans$Pair.Status == "minPair"])))


}
# add on labels for columns
sampleVars = aggregate(VOT~Subject,data=varianceSample,sd)
colnames(sampleVariance) = t(sampleVars$Subject)
colnames(sampleVarianceABBA) = t(sampleVars$Subject)
colnames(sampleVarianceABBA) = t(sampleVars$Subject)
colnames(sampleMean) = t(sampleVars$Subject)
colnames(sampleMeanABBA) = t(sampleVars$Subject)
colnames(sampleMeanABAB) = t(sampleVars$Subject)
colnames(sampleMeanAN)= t(sampleVars$Subject)
colnames(sampleMeanBN)= t(sampleVars$Subject)
colnames(sampleMeanAMP)= t(sampleVars$Subject)
colnames(sampleMeanBMP)= t(sampleVars$Subject)

# exclude dummy first observations
sampleVariance = sampleVariance[-1,]
sampleVarianceABBA = sampleVarianceABBA[-1,]
sampleVarianceABAB = sampleVarianceABAB[-1,]
sampleMean = sampleMean[-1,]
sampleMeanABBA = sampleMeanABBA[-1,]
sampleMeanABAB = sampleMeanABAB[-1,]
sampleMeanAN = sampleMeanAN[-1,]
sampleMeanBN = sampleMeanBN[-1,]
sampleMeanAMP = sampleMeanAMP[-1,]
sampleMeanBMP = sampleMeanBMP[-1,]

# write out results
write.table(sampleVariance,"sampleVariance.txt",quote=F,sep="\t",row.names=F)
write.table(sampleVarianceABBA,"sampleVarianceABBA.txt",quote=F,sep="\t",row.names=F)
write.table(sampleVarianceABAB,"sampleVarianceABAB.txt",quote=F,sep="\t",row.names=F)
write.table(sampleMean,"sampleMean.txt",quote=F,sep="\t",row.names=F)
write.table(sampleMeanABBA,"sampleMeanABBA.txt",quote=F,sep="\t",row.names=F)
write.table(sampleMeanABAB,"sampleMeanABAB.txt",quote=F,sep="\t",row.names=F)
write.table(sampleMeanAN,"sampleMeanAN.txt",quote=F,sep="\t",row.names=F)
write.table(sampleMeanBN,"sampleMeanBN.txt",quote=F,sep="\t",row.names=F)
write.table(sampleMeanAMP,"sampleMeanAMP.txt",quote=F,sep="\t",row.names=F)
write.table(sampleMeanBMP,"sampleMeanBMP.txt",quote=F,sep="\t",row.names=F)
