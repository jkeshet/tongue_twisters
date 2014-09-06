##### EXTRACT DATA FROM LOG FILES #####
# get list of log files
logs = list.files(pattern="log$")

# load in twister data
twisterData = read.delim("lookup_numbered.csv",sep=",",as.is=T)
syllables = twisterData[,c("TrialLabel","Syl1","Syl2","Syl3","Syl4")]

# create first line
Subject = 1
VOT = .001
VOTConfidence = .001
Sequence = 0

resultsVOT = cbind(Subject,twisterData[1,c("TrialLabel", "VoicingA", "VoicingB", "Pair.Status", "Pair.Number", "Order", "Ordering", "POA", "Script1","Script2")], VOT, VOTConfidence,Sequence)

badAlign = 0
badVOT = 0
missVOT = 0
for (i in 1:length(logs)){
	# extract subject ID
	subjectID = paste("'",substr(logs[i],20,22),"'",sep="")
	# note have to specify columns else it reads in incorrectly. In this case, max # of VOTs is 14 so max number of columns is 2*14 + 3 (+1 to handle line end character? it fails if # is 31)
	vots = read.csv(logs[i],header=F,col.names=1:32)
	# process each file
	for (j in 1:length(vots[,1])){
		# if  alignment_confidence > 11.0 or alignment_confidence < 5.0 or| mse_score > 0.00535 then this line is badly aligned.
		# alignment confidence : column 2; mse score : column 3
		if (vots[j,2] < 11.0 & vots[j,2] > 5.0 & vots[j,3] < 0.00535  ){
			sequenceID = substr(vots[j,1],5,14)
			#calc max position; smaller of 27 (=2*12 VOTs - 1 + 3 for first 3 columns) vs. length excluding missing values
			maxVOTs = sum(!is.na(vots[j,]))
			if (maxVOTs > 27)
				maxVOTs <- 27
				missVOT = missVOT+12-((maxVOTs-3)/2)
			for (k in seq(4,maxVOTs,by=2)){
				#kth value = VOT confidence; k+1 = VOT
				currentVOT = vots[j,k+1]
				currentVOTscore = vots[j,k]
				#exclude if VOT < .005 or VOT score is negative
				if (currentVOT > .005 & currentVOTscore > 0){
					currentLine = cbind(subjectID,twisterData[twisterData$TrialLabel==sequenceID,c("TrialLabel", "VoicingA", "VoicingB", "Pair.Status", "Pair.Number", "Order", "Ordering", "POA", "Script1","Script2")],currentVOT,currentVOTscore,(k-2)/2)
					names(currentLine) = names(resultsVOT)
					resultsVOT = rbind(resultsVOT,currentLine)
				} else {  # otherwise put in dummy values
					currentLine = cbind(subjectID,twisterData[twisterData$TrialLabel==sequenceID,c("TrialLabel", "VoicingA", "VoicingB", "Pair.Status", "Pair.Number", "Order", "Ordering", "POA", "Script1","Script2")],-999,-999,(k-2)/2)
					names(currentLine) = names(resultsVOT)
					resultsVOT = rbind(resultsVOT,currentLine)
					badVOT = badVOT + 1
				}
				
			}
		}
		else {
					badAlign = badAlign + 1
		}
	}
}

resultsVOT = resultsVOT[-1,]

write.table(resultsVOT,"resultsVOT.txt",quote=F,sep="\t",row.names=F)