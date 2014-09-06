##### MONTE CARLO PROCEDURE FOR VOICELESS CONSONANTS, ITEM ANALYSIS #####

# load in correct productions and matched errors
voicelessErrsMatched = read.delim("voicelessErrsMatched.txt")
voicelessCor = read.delim("voicelessCor.txt")

# calculate by-item values to seed the list of monte carlo-generated values
subVars = aggregate(VOT~item,data=voicelessErrsMatched,sd)

# seed variance, mean, by-ordering lists
sampleVariance = data.frame(t(subVars$VOT))
sampleVarianceABBA = data.frame(t(subVars$VOT))
sampleVarianceABAB = data.frame(t(subVars$VOT))
sampleMean = data.frame(t(subVars$VOT))
sampleMeanABBA = data.frame(t(subVars$VOT))
sampleMeanABAB = data.frame(t(subVars$VOT))

# seed values for by-position lists for lexicality analyses
subVars = aggregate(VOT~item+elementInOrder+Pair.Status,data=voicelessErrsMatched,sd)
AN = subVars[subVars$elementInOrder=="A" & subVars$Pair.Status == "noMinPair",]
BN = subVars[subVars$elementInOrder=="B" & subVars$Pair.Status == "noMinPair",]
AMP = subVars[subVars$elementInOrder=="A" & subVars$Pair.Status == "minPair",]
BMP = subVars[subVars$elementInOrder=="B" & subVars$Pair.Status == "minPair",]

sampleMeanAN = data.frame(t(AN$VOT))
sampleMeanBN = data.frame(t(BN$VOT))
sampleMeanAMP = data.frame(t(AMP$VOT))
sampleMeanBMP = data.frame(t(BMP$VOT))

# for 1,000 replicates
for (resample in 1:1000){

# seed the list of correct productions sampled
varianceSample = voicelessCor[1,]
# resample the correct productions
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
# exclude dummy first observation
varianceSample = varianceSample[-1,]

# calculate statistics over random sample and add onto stored lists
# by-item variance
sampleVars = aggregate(VOT~item,data=varianceSample,sd)
sampleVariance = rbind(sampleVariance,data.frame(t(sampleVars$VOT)))

# by-item variance across tongue twister ordering conditions
sampleVars = aggregate(VOT~item+Order,data=varianceSample,sd)
sampleVarianceABBA = rbind(sampleVarianceABBA,data.frame(t(sampleVars$VOT[sampleVars$Order=="ABBA"])))
sampleVarianceABAB = rbind(sampleVarianceABAB,data.frame(t(sampleVars$VOT[sampleVars$Order=="ABAB"])))

# by-item means
sampleMeans = aggregate(VOT~item,data=varianceSample,mean)
sampleMean = rbind(sampleMean,data.frame(t(sampleMeans$VOT)))

# by-item means across tongue twister ordering conditions
sampleMeans = aggregate(VOT~item+Order,data=varianceSample,mean)
sampleMeanABBA = rbind(sampleMeanABBA,data.frame(t(sampleMeans$VOT[sampleMeans$Order=="ABBA"])))
sampleMeanABAB = rbind(sampleMeanABAB,data.frame(t(sampleMeans$VOT[sampleMeans$Order=="ABAB"])))

# by-item means across positions in quadruplet
samplePositionMeans = aggregate(VOT~item+elementInOrder+Pair.Status,data=varianceSample,mean)
sampleMeanAN = rbind(sampleMeanAN,data.frame(t(samplePositionMeans$VOT[samplePositionMeans$elementInOrder=="A" & samplePositionMeans$Pair.Status == "noMinPair"])))
sampleMeanBN = rbind(sampleMeanBN,data.frame(t(samplePositionMeans$VOT[samplePositionMeans$elementInOrder=="B" & samplePositionMeans$Pair.Status == "noMinPair"])))
sampleMeanAMP = rbind(sampleMeanAMP,data.frame(t(samplePositionMeans$VOT[samplePositionMeans$elementInOrder=="A" & samplePositionMeans$Pair.Status == "minPair"])))
sampleMeanBMP = rbind(sampleMeanBMP,data.frame(t(samplePositionMeans$VOT[samplePositionMeans$elementInOrder=="B" & samplePositionMeans$Pair.Status == "minPair"])))


}

# add on labels for columns
sampleVars = aggregate(VOT~item,data=varianceSample,sd)
colnames(sampleVariance) = t(sampleVars$item)
colnames(sampleVarianceABBA) = t(sampleVars$item)
colnames(sampleVarianceABAB) = t(sampleVars$item)
colnames(sampleMean) = t(sampleVars$item)
colnames(sampleMeanABBA) = t(sampleVars$item)
colnames(sampleMeanABAB) = t(sampleVars$item)

subVars = aggregate(VOT~item+elementInOrder+Pair.Status,data=voicelessErrsMatched,sd)
AN = subVars[subVars$elementInOrder=="A" & subVars$Pair.Status == "noMinPair",]
BN = subVars[subVars$elementInOrder=="B" & subVars$Pair.Status == "noMinPair",]
AMP = subVars[subVars$elementInOrder=="A" & subVars$Pair.Status == "minPair",]
BMP = subVars[subVars$elementInOrder=="B" & subVars$Pair.Status == "minPair",]

colnames(sampleMeanAN)= t(AN$item)
colnames(sampleMeanBN)= t(BN$item)
colnames(sampleMeanAMP)= t(AMP$item)
colnames(sampleMeanBMP)= t(BMP$item)

# extract dummy first observations
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
write.table(sampleVariance,"sampleVarianceItem-1.txt",quote=F,sep="\t",row.names=F)
write.table(sampleVarianceABBA,"sampleVarianceABBAItem-1.txt",quote=F,sep="\t",row.names=F)
write.table(sampleVarianceABAB,"sampleVarianceABABItem-1.txt",quote=F,sep="\t",row.names=F)
write.table(sampleMean,"sampleMeanItem-1.txt",quote=F,sep="\t",row.names=F)
write.table(sampleMeanABBA,"sampleMeanABBAItem-1.txt",quote=F,sep="\t",row.names=F)
write.table(sampleMeanABAB,"sampleMeanABABItem-1.txt",quote=F,sep="\t",row.names=F)
write.table(sampleMeanAN,"sampleMeanANItem-1.txt",quote=F,sep="\t",row.names=F)
write.table(sampleMeanBN,"sampleMeanBNItem-1.txt",quote=F,sep="\t",row.names=F)
write.table(sampleMeanAMP,"sampleMeanAMPItem-1.txt",quote=F,sep="\t",row.names=F)
write.table(sampleMeanBMP,"sampleMeanBMPItem-1.txt",quote=F,sep="\t",row.names=F)