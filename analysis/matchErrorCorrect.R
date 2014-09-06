##### MATCH ERROR FILES TO CORRECT PRODUCTIONS ######

#load in  results
newdata = read.delim("resultsVOTinfo.txt",as.is=T)
newdata$item = paste(newdata$Pair.Number,newdata$VoicingA,newdata$POA,sep="-")

# extract voiceless productions
voiceless=newdata[newdata$productionVoicing =="voiceless",]

# separate into correct, error trials
voicelessErr = voiceless[voiceless$correct =="error",]
voicelessCor = voiceless[voiceless$correct =="correct",]

# Excluded cases where are there are fewer matched correct responses than errors.
# If cases were included, re-sampling would results in repeated draws of same observation 
keep = voicelessErr[1,]
# for each subject
for (i in unique(voicelessErr$Subject)){
	# in each condition
	for (j in unique(voicelessErr$Order)){
		# for each item (quadruplet)
		for (k in unique(voicelessErr$item)){
			# for each pair
			for (l in unique(voicelessErr$Pair.Status)){
				# for each element in pair
				for (m in unique(voicelessErr$elementInOrder)){
					# if there are observations
					if (length(voicelessErr$VOT[voicelessErr$Subject == i & voicelessErr$Order == j & voicelessErr$item == k & voicelessErr$Pair.Status == l & voicelessErr$elementInOrder == m]) > 0){
						# find correct productions of the error outcome (the opposite element of the tongue twister)
						n = ifelse(m=="A","B","A")

						# if there are at least as many correct as error productions…
						if (length(voicelessCor$VOT[voicelessCor$Subject == i & voicelessCor$Order == j & voicelessCor$item == k & voicelessCor$Pair.Status == l & voicelessCor$elementInOrder == n]) - length(voicelessErr$VOT[voicelessErr$Subject == i & voicelessErr$Order == j & voicelessErr$item == k & voicelessErr$Pair.Status == l & voicelessErr$elementInOrder == m]) >= 0) {
							
							# retain the errors
							keep = rbind(keep,voicelessErr[voicelessErr$Subject == i & voicelessErr$Order == j & voicelessErr$item == k & voicelessErr$Pair.Status == l & voicelessErr$elementInOrder == m,])
						}
					}
				}		
			}
		}
	}
}

# eliminate dummy first observations
voicelessErrsMatched = keep[-1,]

# save results
write.table(voicelessErrsMatched,"voicelessErrsMatched.txt",sep="\t",quote=F,row.names=F)
write.table(voicelessCor,"voicelessCor.txt",sep="\t",quote=F,row.names=F)

# repeat process for voiced productions
# extract voiced outcomes
voiced=newdata[newdata$productionVoicing =="voiced",]

#exclude outlier; this is classified as voiced because the variance of the voiced component is large
voiced = voiced[voiced$VOT < .124,]

# separate out correct, error productions
voicedErr = voiced[voiced$correct =="error",]
voicedCor = voiced[voiced$correct =="correct",]

# Excluded cases where are there are fewer matched correct responses than errors.
keep = voicedErr[1,]
# for each subject
for (i in unique(voicedErr$Subject)){
	# in each condition
	for (j in unique(voicedErr$Order)){
		# for each item (quadruplet)
		for (k in unique(voicedErr$item)){
			# for each pair
			for (l in unique(voicedErr$Pair.Status)){
				# for each element in pair
				for (m in unique(voicedErr$elementInOrder)){
					# if there are observations
					if (length(voicedErr$VOT[voicedErr$Subject == i & voicedErr$Order == j & voicedErr$item == k & voicedErr$Pair.Status == l & voicedErr$elementInOrder == m]) > 0){
						
						# find correct productions of the error outcome (the opposite element of the tongue twister)
						n = ifelse(m=="A","B","A")

						#if there are at least as many correct as error productions…
						if (length(voicedCor$VOT[voicedCor$Subject == i & voicedCor$Order == j & voicedCor$item == k & voicedCor$Pair.Status == l & voicedCor$elementInOrder == n]) - length(voicedErr$VOT[voicedErr$Subject == i & voicedErr$Order == j & voicedErr$item == k & voicedErr$Pair.Status == l & voicedErr$elementInOrder == m]) >= 0) {
							
							# retain the errors
							keep = rbind(keep,voicedErr[voicedErr$Subject == i & voicedErr$Order == j & voicedErr$item == k & voicedErr$Pair.Status == l & voicedErr$elementInOrder == m,])
						}
					}
				}		
			}
		}
	}
}

# exclude dummy first observation
voicedErrsMatched = keep[-1,]

# save results
write.table(voicedErrsMatched,"voicedErrsMatched.txt",sep="\t",quote=F,row.names=F)
write.table(voicedCor,"voicedCor.txt",sep="\t",quote=F,row.names=F)

