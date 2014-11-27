##### SELECT SUBSET OF ITEMS FOR VARIANCE POWER ANALYSIS #####

nSamplesEach = 15

# load in correct productions and matched errors
voicedErrsMatched = read.delim("voicedErrsMatched.txt")
voicedCor = read.delim("voicedCor.txt")
voicelessErrsMatched = read.delim("voicelessErrsMatched.txt")
voicelessCor = read.delim("voicelessCor.txt")

# select ABAB items
# only use 1st block, and only draw from 1st quarter of trials
voicedErrsMatchedABAB = voicedErrsMatched[voicedErrsMatched$List == 1 & voicedErrsMatched$trialNumber <= 28,]
voicedCorABAB = voicedCor[voicedCor$List == 1 & voicedCor$trialNumber <= 28,]

# track how many errors are excluded, and what is the minimum number of errors per participant
excludeCount = data.frame(c(rep("ABAB",nSamplesEach),rep("ABBA", nSamplesEach)),rep(0, nSamplesEach*2),rep(0, nSamplesEach*2),rep(0,nSamplesEach*2),rep(0,nSamplesEach*2))
colnames(excludeCount) = c("Order","N.Excluded","N.Errs","PropExclude","Min.Errs.Sub")

# get list of possible participants
subs <- unique(voicedErrsMatchedABAB$Subject)
# generate nSamples from each order
for(z in 1:nSamplesEach){
	selectSubs <- sample(subs,8) # select 8 participants
	Err <- voicedErrsMatchedABAB[is.element(voicedErrsMatchedABAB$Subject,selectSubs),] # select relevant errors
	Cor <- voicedCorABAB[is.element(voicedCorABAB$Subject,selectSubs),] # select relevant correct productions
	count <- nrow(Err) # total number of errors available
	# Excluded cases where are there are fewer matched correct responses than errors.
	# If cases were included, re-sampling would results in repeated draws of same observation 
	keep = Err[1,]
	# for each subject
	for (i in unique(Err$Subject)){
		# in each condition
		for (j in unique(Err$Order)){
			# for each item (quadruplet)
			for (k in unique(Err$item)){
				# for each pair
				for (l in unique(Err$Pair.Status)){
					# for each element in pair
					for (m in unique(Err$elementInOrder)){
						# if there are observations
						if (length(Err$VOT[Err$Subject == i & Err$Order == j & Err$item == k & Err$Pair.Status == l & Err$elementInOrder == m]) > 0){
							# find correct productions of the error outcome (the opposite element of the tongue twister)
							n = ifelse(m=="A","B","A")

							# if there are at least as many correct as error productions…
							if (length(Cor$VOT[Cor$Subject == i & Cor$Order == j & Cor$item == k & Cor$Pair.Status == l & Cor$elementInOrder == n]) - length(Err$VOT[Err$Subject == i & Err$Order == j & Err$item == k & Err$Pair.Status == l & Err$elementInOrder == m]) >= 0) {
							
								# retain the errors
								keep = rbind(keep,Err[Err$Subject == i & Err$Order == j & Err$item == k & Err$Pair.Status == l & Err$elementInOrder == m,])
							}
						}
					}		
				}
			}
		}
	}

	# eliminate dummy first observations
	ErrsMatched = keep[-1,]

	# count number excluded, minimum number per participant
	excludeCount$N.Excluded[z]=count-nrow(ErrsMatched)
	excludeCount$N.Errs[z]=count
	excludeCount$PropExclude[z] = (count-nrow(ErrsMatched))/count
	excludeCount$Min.Errs.Sub[z] = min(table(ErrsMatched$Subject)[selectSubs])

	write.table(ErrsMatched,paste("voicedErrsMatchedABAB-",z,".txt",sep=""),sep="\t",quote=F,row.names=F)
	write.table(Cor,paste("voicedCorABAB-",z,".txt",sep=""),sep="\t",quote=F,row.names=F)
}

# select ABBA items
# only use 1st block, and only draw from 1st quarter of trials
voicedErrsMatchedABBA = voicedErrsMatched[voicedErrsMatched$List == 2 & voicedErrsMatched$trialNumber <= 28,]
voicedCorABBA = voicedCor[voicedCor$List == 2 & voicedCor$trialNumber <= 28,]

subs <- unique(voicedErrsMatchedABBA$Subject)
# generate nSamples random subsets
for(z in 1: nSamplesEach){
	selectSubs <- sample(subs,8) # select 8 participants
	Cor <- 	voicedCorABBA[is.element(voicedCorABBA$Subject,selectSubs),] # select relevant correct productions
	Err <- voicedErrsMatchedABBA[is.element(voicedErrsMatchedABBA$Subject,selectSubs),] # select relevant errors
	count <- nrow(Err) # total error count
	# Excluded cases where are there are fewer matched correct responses than errors.
	# If cases were included, re-sampling would results in repeated draws of same observation 
	keep = Err[1,]
	# for each subject
	for (i in unique(Err$Subject)){
		# in each condition
		for (j in unique(Err$Order)){
			# for each item (quadruplet)
			for (k in unique(Err$item)){
				# for each pair
				for (l in unique(Err$Pair.Status)){
					# for each element in pair
					for (m in unique(Err$elementInOrder)){
						# if there are observations
						if (length(Err$VOT[Err$Subject == i & Err$Order == j & Err$item == k & Err$Pair.Status == l & Err$elementInOrder == m]) > 0){
							# find correct productions of the error outcome (the opposite element of the tongue twister)
							n = ifelse(m=="A","B","A")

							# if there are at least as many correct as error productions…
							if (length(Cor$VOT[Cor$Subject == i & Cor$Order == j & Cor$item == k & Cor$Pair.Status == l & Cor$elementInOrder == n]) - length(Err$VOT[Err$Subject == i & Err$Order == j & Err$item == k & Err$Pair.Status == l & Err$elementInOrder == m]) >= 0) {
							
								# retain the errors
								keep = rbind(keep,Err[Err$Subject == i & Err$Order == j & Err$item == k & Err$Pair.Status == l & Err$elementInOrder == m,])
							}
						}
					}		
				}
			}
		}
	}

	# eliminate dummy first observations
	ErrsMatched = keep[-1,]

	# count number excluded, minimum number per participant
	excludeCount$N.Excluded[z+ nSamplesEach]=count-nrow(ErrsMatched)
	excludeCount$N.Errs[z+ nSamplesEach]=count
	excludeCount$PropExclude[z+ nSamplesEach] = (count-nrow(ErrsMatched))/count
	excludeCount$Min.Errs.Sub[z+ nSamplesEach] = min(table(ErrsMatched$Subject)[selectSubs])
	write.table(ErrsMatched,paste("voicedErrsMatchedABBA-",z,".txt",sep=""),sep="\t",quote=F,row.names=F)
	write.table(Cor,paste("voicedCorABBA-",z,".txt",sep=""),sep="\t",quote=F,row.names=F)
}

write.table(excludeCount,"excludeCount-V.txt",quote=F,sep="\t",row.names=F)

# select ABAB items
# only use 1st block, and only draw from 1st quarter of trials
voicelessErrsMatchedABAB = voicelessErrsMatched[voicelessErrsMatched$List == 1 & voicelessErrsMatched$trialNumber <= 28,]
voicelessCorABAB = voicelessCor[voicelessCor$List == 1 & voicelessCor$trialNumber <= 28,]


excludeCount = data.frame(c(rep("ABAB",nSamplesEach),rep("ABBA", nSamplesEach)),rep(0, nSamplesEach*2),rep(0, nSamplesEach*2),rep(0,nSamplesEach*2),rep(0,nSamplesEach*2))
colnames(excludeCount) = c("Order","N.Excluded","N.Errs","PropExclude","Min.Errs.Sub")

subs <- unique(voicelessErrsMatchedABAB$Subject)
# generate nSamples from each order
for(z in 1:nSamplesEach){
	selectSubs <- sample(subs,8) # select 8 participants
	Err <- voicelessErrsMatchedABAB[is.element(voicelessErrsMatchedABAB$Subject,selectSubs),] # select relevant errors
	Cor <- voicelessCorABAB[is.element(voicelessCorABAB$Subject,selectSubs),] # select relevant correct productions
	count <- nrow(Err) # total errors
	# Excluded cases where are there are fewer matched correct responses than errors.
	# If cases were included, re-sampling would results in repeated draws of same observation 
	keep = Err[1,]
	# for each subject
	for (i in unique(Err$Subject)){
		# in each condition
		for (j in unique(Err$Order)){
			# for each item (quadruplet)
			for (k in unique(Err$item)){
				# for each pair
				for (l in unique(Err$Pair.Status)){
					# for each element in pair
					for (m in unique(Err$elementInOrder)){
						# if there are observations
						if (length(Err$VOT[Err$Subject == i & Err$Order == j & Err$item == k & Err$Pair.Status == l & Err$elementInOrder == m]) > 0){
							# find correct productions of the error outcome (the opposite element of the tongue twister)
							n = ifelse(m=="A","B","A")

							# if there are at least as many correct as error productions…
							if (length(Cor$VOT[Cor$Subject == i & Cor$Order == j & Cor$item == k & Cor$Pair.Status == l & Cor$elementInOrder == n]) - length(Err$VOT[Err$Subject == i & Err$Order == j & Err$item == k & Err$Pair.Status == l & Err$elementInOrder == m]) >= 0) {
							
								# retain the errors
								keep = rbind(keep,Err[Err$Subject == i & Err$Order == j & Err$item == k & Err$Pair.Status == l & Err$elementInOrder == m,])
							}
						}
					}		
				}
			}
		}
	}

	# eliminate dummy first observations
	ErrsMatched = keep[-1,]

	# count number excluded, minimum number per participant
	excludeCount$N.Excluded[z]=count-nrow(ErrsMatched)
	excludeCount$N.Errs[z]=count
		excludeCount$PropExclude[z] = (count-nrow(ErrsMatched))/count
	excludeCount$Min.Errs.Sub[z] = min(table(ErrsMatched$Subject)[selectSubs])

	write.table(ErrsMatched,paste("voicelessErrsMatchedABAB-",z,".txt",sep=""),sep="\t",quote=F,row.names=F)
	write.table(Cor,paste("voicelessCorABAB-",z,".txt",sep=""),sep="\t",quote=F,row.names=F)
}

# select ABBA items
# only use 1st block, and only draw from 1st quarter of trials
voicelessErrsMatchedABBA = voicelessErrsMatched[voicelessErrsMatched$List == 2 & voicelessErrsMatched$trialNumber <= 28,]
voicelessCorABBA = voicelessCor[voicelessCor$List == 2 & voicelessCor$trialNumber <= 28,]

subs <- unique(voicelessErrsMatchedABBA$Subject)
# generate nSamples random subsets
for(z in 1: nSamplesEach){
	selectSubs <- sample(subs,8) # select 8 participants
	Cor <- 	voicelessCorABBA[is.element(voicelessCorABBA$Subject,selectSubs),] # select relevant correct productions
	Err <- voicelessErrsMatchedABBA[is.element(voicelessErrsMatchedABBA$Subject,selectSubs),] # select relevant errors
	count <- nrow(Err) # total error count
	# Excluded cases where are there are fewer matched correct responses than errors.
	# If cases were included, re-sampling would results in repeated draws of same observation 
	keep = Err[1,]
	# for each subject
	for (i in unique(Err$Subject)){
		# in each condition
		for (j in unique(Err$Order)){
			# for each item (quadruplet)
			for (k in unique(Err$item)){
				# for each pair
				for (l in unique(Err$Pair.Status)){
					# for each element in pair
					for (m in unique(Err$elementInOrder)){
						# if there are observations
						if (length(Err$VOT[Err$Subject == i & Err$Order == j & Err$item == k & Err$Pair.Status == l & Err$elementInOrder == m]) > 0){
							# find correct productions of the error outcome (the opposite element of the tongue twister)
							n = ifelse(m=="A","B","A")

							# if there are at least as many correct as error productions…
							if (length(Cor$VOT[Cor$Subject == i & Cor$Order == j & Cor$item == k & Cor$Pair.Status == l & Cor$elementInOrder == n]) - length(Err$VOT[Err$Subject == i & Err$Order == j & Err$item == k & Err$Pair.Status == l & Err$elementInOrder == m]) >= 0) {
							
								# retain the errors
								keep = rbind(keep,Err[Err$Subject == i & Err$Order == j & Err$item == k & Err$Pair.Status == l & Err$elementInOrder == m,])
							}
						}
					}		
				}
			}
		}
	}

	# eliminate dummy first observations
	ErrsMatched = keep[-1,]

	# count number excluded, minimum number per participant
	excludeCount$N.Excluded[z+ nSamplesEach]=count-nrow(ErrsMatched)
	excludeCount$N.Errs[z+ nSamplesEach]=count
		excludeCount$PropExclude[z+ nSamplesEach] = (count-nrow(ErrsMatched))/count
	excludeCount$Min.Errs.Sub[z+ nSamplesEach] = min(table(ErrsMatched$Subject)[selectSubs])

	write.table(ErrsMatched,paste("voicelessErrsMatchedABBA-",z,".txt",sep=""),sep="\t",quote=F,row.names=F)
	write.table(Cor,paste("voicelessCorABBA-",z,".txt",sep=""),sep="\t",quote=F,row.names=F)
}

write.table(excludeCount,"excludeCount.txt",quote=F,sep="\t",row.names=F)