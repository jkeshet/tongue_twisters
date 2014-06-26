
from textgrid import *




print f
        tg = textgrid.TextGrid()
        tg.read(f)
        tg.type = tgType(tg) # label for which tiers this tg has
        ct = CombinedIntervalTier()
        ct.fName = f
        
        wavName = soundTgDict[bn(f)]
        # check that both original and 16kHz wav files exist
        assert os.path.isfile(pj(wavDirOrig,wavName)), "wav file %s not in %s" % (wavName,wavDirOrig)
        assert os.path.isfile(pj(wavDir16kHz,wavName)), "wav file %s not in %s" % (wavName,wavDir16kHz)
        
        ct.soundF = wavName
        tn = tg.tierNames(case="lower")

        votInd = tn.index('vot')
        # VOT -> vot
        tg[votInd]._IntervalTier__name = tg[votInd]._IntervalTier__name.lower()
        ct.append(tg[votInd])

        labInd = tn.index('label') if tg.type==1 else tn.index('text')
        # rename 'text', or 'Label', etc. -> 'label'
        tg[labInd]._IntervalTier__name = 'label'
        ct.append(tg[labInd],addingLabelTier=True)
