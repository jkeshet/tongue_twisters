##### MONTE CARLO PROCEDURE FOR VOICELESS CONSONANTS, BY-PARTICIPANT ANALYSIS #####

# load in correct productions and matched errors
voicedErrsMatched = read.delim("voicedErrsMatched.txt")
voicedCor = read.delim("voicedCor.txt")

# calculate by-participant values to seed the list of monte carlo-generated values
subVars = aggregate(VOT~Subject,data=voicedErrsMatched,sd)

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
varianceSample = voicedCor[1,]
# resample 
# for each subject
for (i in unique(voicedErrsMatched$Subject)){
	# in each condition
	for (j in unique(voicedErrsMatched$Order)){
		# for each item (quadruplet)
		for (k in unique(voicedErrsMatched$item)){
			# for each pair
			for (l in unique(voicedErrsMatched$Pair.Status)){
				# for each element in pair
				for (m in unique(voicedErrsMatched$elementInOrder)){
					# if there are observations in the set of errors…
					nErrs = length(voicedErrsMatched$VOT[voicedErrsMatched$Subject == i & voicedErrsMatched$Order == j & voicedErrsMatched$item == k & voicedErrsMatched$Pair.Status == l & voicedErrsMatched$elementInOrder == m]) 
					if (nErrs > 0){
						# find corresponding correct productions (other member of the pair)						
						n = ifelse(m=="A","B","A")
						relCors = voicedCor[voicedCor$Subject == i & voicedCor$Order == j & voicedCor$item == k & voicedCor$Pair.Status == l & voicedCor$elementInOrder == n,]
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
write.table(sampleVariance,"sampleVariance-V.txt",quote=F,sep="\t",row.names=F)
write.table(sampleVarianceABBA,"sampleVarianceABBA-V.txt",quote=F,sep="\t",row.names=F)
write.table(sampleVarianceABAB,"sampleVarianceABAB-V.txt",quote=F,sep="\t",row.names=F)
write.table(sampleMean,"sampleMean-V.txt",quote=F,sep="\t",row.names=F)
write.table(sampleMeanABBA,"sampleMeanABBA-V.txt",quote=F,sep="\t",row.names=F)
write.table(sampleMeanABAB,"sampleMeanABAB-V.txt",quote=F,sep="\t",row.names=F)
write.table(sampleMeanAN,"sampleMeanAN-V.txt",quote=F,sep="\t",row.names=F)
write.table(sampleMeanBN,"sampleMeanBN-V.txt",quote=F,sep="\t",row.names=F)
write.table(sampleMeanAMP,"sampleMeanAMP-V.txt",quote=F,sep="\t",row.names=F)
write.table(sampleMeanBMP,"sampleMeanBMP-V.txt",quote=F,sep="\t",row.names=F)
