#!/usr/bin/env bash
# 3dMEMA creates temp files
# cannot have overlapping
tempdir=$(mktemp -d QuadASerrorCorr-tmp) 
cd $tempdir
3dMEMA \
  -prefix /Volumes/Governator/ANTISTATELONG/AgeGrpAnalyses/3dMEMA/Quad_ASerrorCorr_Rnd \
  -jobs 4 \
  -covariates /Volumes/Governator/ANTISTATELONG/AgeGrpAnalyses/3dMEMA/covariateAge_Quad_ASerrorCorr.1D \
  -covariates_name 'age age**2' \
  -missing_data 0 \
  -n_nonzero 124 \
  -mask /Volumes/Governator/ANTISTATELONG/Reliability/mask+tlrc \
  -set everyone \
                  10309051205121315 /Volumes/Governator/ANTISTATELONG/10309/051205121315/analysis/glm_hrf_Stats_REML+tlrc[6] /Volumes/Governator/ANTISTATELONG/10309/051205121315/analysis/glm_hrf_Stats_REML+tlrc[7] \
                  10187051215162541 /Volumes/Governator/ANTISTATELONG/10187/051215162541/analysis/glm_hrf_Stats_REML+tlrc[6] /Volumes/Governator/ANTISTATELONG/10187/051215162541/analysis/glm_hrf_Stats_REML+tlrc[7] \
                  10204060105155654 /Volumes/Governator/ANTISTATELONG/10204/060105155654/analysis/glm_hrf_Stats_REML+tlrc[6] /Volumes/Governator/ANTISTATELONG/10204/060105155654/analysis/glm_hrf_Stats_REML+tlrc[7] \
                  10199060113155611 /Volumes/Governator/ANTISTATELONG/10199/060113155611/analysis/glm_hrf_Stats_REML+tlrc[6] /Volumes/Governator/ANTISTATELONG/10199/060113155611/analysis/glm_hrf_Stats_REML+tlrc[7] \
                  10196060114162842 /Volumes/Governator/ANTISTATELONG/10196/060114162842/analysis/glm_hrf_Stats_REML+tlrc[6] /Volumes/Governator/ANTISTATELONG/10196/060114162842/analysis/glm_hrf_Stats_REML+tlrc[7] \
                  10202060123155345 /Volumes/Governator/ANTISTATELONG/10202/060123155345/analysis/glm_hrf_Stats_REML+tlrc[6] /Volumes/Governator/ANTISTATELONG/10202/060123155345/analysis/glm_hrf_Stats_REML+tlrc[7] \
                  10200060202162452 /Volumes/Governator/ANTISTATELONG/10200/060202162452/analysis/glm_hrf_Stats_REML+tlrc[6] /Volumes/Governator/ANTISTATELONG/10200/060202162452/analysis/glm_hrf_Stats_REML+tlrc[7] \
                  10194060204095141 /Volumes/Governator/ANTISTATELONG/10194/060204095141/analysis/glm_hrf_Stats_REML+tlrc[6] /Volumes/Governator/ANTISTATELONG/10194/060204095141/analysis/glm_hrf_Stats_REML+tlrc[7] \
                  10198060206155700 /Volumes/Governator/ANTISTATELONG/10198/060206155700/analysis/glm_hrf_Stats_REML+tlrc[6] /Volumes/Governator/ANTISTATELONG/10198/060206155700/analysis/glm_hrf_Stats_REML+tlrc[7] \
                  10134060209134325 /Volumes/Governator/ANTISTATELONG/10134/060209134325/analysis/glm_hrf_Stats_REML+tlrc[6] /Volumes/Governator/ANTISTATELONG/10134/060209134325/analysis/glm_hrf_Stats_REML+tlrc[7] \
                  10215060218111508 /Volumes/Governator/ANTISTATELONG/10215/060218111508/analysis/glm_hrf_Stats_REML+tlrc[6] /Volumes/Governator/ANTISTATELONG/10215/060218111508/analysis/glm_hrf_Stats_REML+tlrc[7] \
                  10217060227161522 /Volumes/Governator/ANTISTATELONG/10217/060227161522/analysis/glm_hrf_Stats_REML+tlrc[6] /Volumes/Governator/ANTISTATELONG/10217/060227161522/analysis/glm_hrf_Stats_REML+tlrc[7] \
                  10222060311142900 /Volumes/Governator/ANTISTATELONG/10222/060311142900/analysis/glm_hrf_Stats_REML+tlrc[6] /Volumes/Governator/ANTISTATELONG/10222/060311142900/analysis/glm_hrf_Stats_REML+tlrc[7] \
                  10150060323162830 /Volumes/Governator/ANTISTATELONG/10150/060323162830/analysis/glm_hrf_Stats_REML+tlrc[6] /Volumes/Governator/ANTISTATELONG/10150/060323162830/analysis/glm_hrf_Stats_REML+tlrc[7] \
                  10235060325143915 /Volumes/Governator/ANTISTATELONG/10235/060325143915/analysis/glm_hrf_Stats_REML+tlrc[6] /Volumes/Governator/ANTISTATELONG/10235/060325143915/analysis/glm_hrf_Stats_REML+tlrc[7] \
                  10278060330161349 /Volumes/Governator/ANTISTATELONG/10278/060330161349/analysis/glm_hrf_Stats_REML+tlrc[6] /Volumes/Governator/ANTISTATELONG/10278/060330161349/analysis/glm_hrf_Stats_REML+tlrc[7] \
                  10269060401113408 /Volumes/Governator/ANTISTATELONG/10269/060401113408/analysis/glm_hrf_Stats_REML+tlrc[6] /Volumes/Governator/ANTISTATELONG/10269/060401113408/analysis/glm_hrf_Stats_REML+tlrc[7] \
                  10177060408131155 /Volumes/Governator/ANTISTATELONG/10177/060408131155/analysis/glm_hrf_Stats_REML+tlrc[6] /Volumes/Governator/ANTISTATELONG/10177/060408131155/analysis/glm_hrf_Stats_REML+tlrc[7] \
                  10256060408142558 /Volumes/Governator/ANTISTATELONG/10256/060408142558/analysis/glm_hrf_Stats_REML+tlrc[6] /Volumes/Governator/ANTISTATELONG/10256/060408142558/analysis/glm_hrf_Stats_REML+tlrc[7] \
                  10279060410160830 /Volumes/Governator/ANTISTATELONG/10279/060410160830/analysis/glm_hrf_Stats_REML+tlrc[6] /Volumes/Governator/ANTISTATELONG/10279/060410160830/analysis/glm_hrf_Stats_REML+tlrc[7] \
                  10261060417162906 /Volumes/Governator/ANTISTATELONG/10261/060417162906/analysis/glm_hrf_Stats_REML+tlrc[6] /Volumes/Governator/ANTISTATELONG/10261/060417162906/analysis/glm_hrf_Stats_REML+tlrc[7] \
                  10148060424162317 /Volumes/Governator/ANTISTATELONG/10148/060424162317/analysis/glm_hrf_Stats_REML+tlrc[6] /Volumes/Governator/ANTISTATELONG/10148/060424162317/analysis/glm_hrf_Stats_REML+tlrc[7] \
                  10273060427161210 /Volumes/Governator/ANTISTATELONG/10273/060427161210/analysis/glm_hrf_Stats_REML+tlrc[6] /Volumes/Governator/ANTISTATELONG/10273/060427161210/analysis/glm_hrf_Stats_REML+tlrc[7] \
                  10297060506101902 /Volumes/Governator/ANTISTATELONG/10297/060506101902/analysis/glm_hrf_Stats_REML+tlrc[6] /Volumes/Governator/ANTISTATELONG/10297/060506101902/analysis/glm_hrf_Stats_REML+tlrc[7] \
                  10281060513154259 /Volumes/Governator/ANTISTATELONG/10281/060513154259/analysis/glm_hrf_Stats_REML+tlrc[6] /Volumes/Governator/ANTISTATELONG/10281/060513154259/analysis/glm_hrf_Stats_REML+tlrc[7] \
                  10306060525161836 /Volumes/Governator/ANTISTATELONG/10306/060525161836/analysis/glm_hrf_Stats_REML+tlrc[6] /Volumes/Governator/ANTISTATELONG/10306/060525161836/analysis/glm_hrf_Stats_REML+tlrc[7] \
                  10311060601160452 /Volumes/Governator/ANTISTATELONG/10311/060601160452/analysis/glm_hrf_Stats_REML+tlrc[6] /Volumes/Governator/ANTISTATELONG/10311/060601160452/analysis/glm_hrf_Stats_REML+tlrc[7] \
                  10170060603094618 /Volumes/Governator/ANTISTATELONG/10170/060603094618/analysis/glm_hrf_Stats_REML+tlrc[6] /Volumes/Governator/ANTISTATELONG/10170/060603094618/analysis/glm_hrf_Stats_REML+tlrc[7] \
                  10211060605164937 /Volumes/Governator/ANTISTATELONG/10211/060605164937/analysis/glm_hrf_Stats_REML+tlrc[6] /Volumes/Governator/ANTISTATELONG/10211/060605164937/analysis/glm_hrf_Stats_REML+tlrc[7] \
                  10305060608161920 /Volumes/Governator/ANTISTATELONG/10305/060608161920/analysis/glm_hrf_Stats_REML+tlrc[6] /Volumes/Governator/ANTISTATELONG/10305/060608161920/analysis/glm_hrf_Stats_REML+tlrc[7] \
                  10323060713162654 /Volumes/Governator/ANTISTATELONG/10323/060713162654/analysis/glm_hrf_Stats_REML+tlrc[6] /Volumes/Governator/ANTISTATELONG/10323/060713162654/analysis/glm_hrf_Stats_REML+tlrc[7] \
                  10136060715095530 /Volumes/Governator/ANTISTATELONG/10136/060715095530/analysis/glm_hrf_Stats_REML+tlrc[6] /Volumes/Governator/ANTISTATELONG/10136/060715095530/analysis/glm_hrf_Stats_REML+tlrc[7] \
                  10331060727155753 /Volumes/Governator/ANTISTATELONG/10331/060727155753/analysis/glm_hrf_Stats_REML+tlrc[6] /Volumes/Governator/ANTISTATELONG/10331/060727155753/analysis/glm_hrf_Stats_REML+tlrc[7] \
                  10330060729155605 /Volumes/Governator/ANTISTATELONG/10330/060729155605/analysis/glm_hrf_Stats_REML+tlrc[6] /Volumes/Governator/ANTISTATELONG/10330/060729155605/analysis/glm_hrf_Stats_REML+tlrc[7] \
                  10124060803163400 /Volumes/Governator/ANTISTATELONG/10124/060803163400/analysis/glm_hrf_Stats_REML+tlrc[6] /Volumes/Governator/ANTISTATELONG/10124/060803163400/analysis/glm_hrf_Stats_REML+tlrc[7] \
                  10342060810162342 /Volumes/Governator/ANTISTATELONG/10342/060810162342/analysis/glm_hrf_Stats_REML+tlrc[6] /Volumes/Governator/ANTISTATELONG/10342/060810162342/analysis/glm_hrf_Stats_REML+tlrc[7] \
                  10329060821164831 /Volumes/Governator/ANTISTATELONG/10329/060821164831/analysis/glm_hrf_Stats_REML+tlrc[6] /Volumes/Governator/ANTISTATELONG/10329/060821164831/analysis/glm_hrf_Stats_REML+tlrc[7] \
                  10336060824162803 /Volumes/Governator/ANTISTATELONG/10336/060824162803/analysis/glm_hrf_Stats_REML+tlrc[6] /Volumes/Governator/ANTISTATELONG/10336/060824162803/analysis/glm_hrf_Stats_REML+tlrc[7] \
                  10345060914160717 /Volumes/Governator/ANTISTATELONG/10345/060914160717/analysis/glm_hrf_Stats_REML+tlrc[6] /Volumes/Governator/ANTISTATELONG/10345/060914160717/analysis/glm_hrf_Stats_REML+tlrc[7] \
                  10339060921161720 /Volumes/Governator/ANTISTATELONG/10339/060921161720/analysis/glm_hrf_Stats_REML+tlrc[6] /Volumes/Governator/ANTISTATELONG/10339/060921161720/analysis/glm_hrf_Stats_REML+tlrc[7] \
                  10195061030164251 /Volumes/Governator/ANTISTATELONG/10195/061030164251/analysis/glm_hrf_Stats_REML+tlrc[6] /Volumes/Governator/ANTISTATELONG/10195/061030164251/analysis/glm_hrf_Stats_REML+tlrc[7] \
                  10370061104095818 /Volumes/Governator/ANTISTATELONG/10370/061104095818/analysis/glm_hrf_Stats_REML+tlrc[6] /Volumes/Governator/ANTISTATELONG/10370/061104095818/analysis/glm_hrf_Stats_REML+tlrc[7] \
                  10176061106165928 /Volumes/Governator/ANTISTATELONG/10176/061106165928/analysis/glm_hrf_Stats_REML+tlrc[6] /Volumes/Governator/ANTISTATELONG/10176/061106165928/analysis/glm_hrf_Stats_REML+tlrc[7] \
                  10360061111142529 /Volumes/Governator/ANTISTATELONG/10360/061111142529/analysis/glm_hrf_Stats_REML+tlrc[6] /Volumes/Governator/ANTISTATELONG/10360/061111142529/analysis/glm_hrf_Stats_REML+tlrc[7] \
                  10361061111160713 /Volumes/Governator/ANTISTATELONG/10361/061111160713/analysis/glm_hrf_Stats_REML+tlrc[6] /Volumes/Governator/ANTISTATELONG/10361/061111160713/analysis/glm_hrf_Stats_REML+tlrc[7] \
                  10206070106133323 /Volumes/Governator/ANTISTATELONG/10206/070106133323/analysis/glm_hrf_Stats_REML+tlrc[6] /Volumes/Governator/ANTISTATELONG/10206/070106133323/analysis/glm_hrf_Stats_REML+tlrc[7] \
                  10180070113162039 /Volumes/Governator/ANTISTATELONG/10180/070113162039/analysis/glm_hrf_Stats_REML+tlrc[6] /Volumes/Governator/ANTISTATELONG/10180/070113162039/analysis/glm_hrf_Stats_REML+tlrc[7] \
                  10216070331101022 /Volumes/Governator/ANTISTATELONG/10216/070331101022/analysis/glm_hrf_Stats_REML+tlrc[6] /Volumes/Governator/ANTISTATELONG/10216/070331101022/analysis/glm_hrf_Stats_REML+tlrc[7] \
                  10185070426162723 /Volumes/Governator/ANTISTATELONG/10185/070426162723/analysis/glm_hrf_Stats_REML+tlrc[6] /Volumes/Governator/ANTISTATELONG/10185/070426162723/analysis/glm_hrf_Stats_REML+tlrc[7] \
                  10183070526133033 /Volumes/Governator/ANTISTATELONG/10183/070526133033/analysis/glm_hrf_Stats_REML+tlrc[6] /Volumes/Governator/ANTISTATELONG/10183/070526133033/analysis/glm_hrf_Stats_REML+tlrc[7] \
                  10230070627165959 /Volumes/Governator/ANTISTATELONG/10230/070627165959/analysis/glm_hrf_Stats_REML+tlrc[6] /Volumes/Governator/ANTISTATELONG/10230/070627165959/analysis/glm_hrf_Stats_REML+tlrc[7] \
                  10260070707094153 /Volumes/Governator/ANTISTATELONG/10260/070707094153/analysis/glm_hrf_Stats_REML+tlrc[6] /Volumes/Governator/ANTISTATELONG/10260/070707094153/analysis/glm_hrf_Stats_REML+tlrc[7] \
                  10156070707110749 /Volumes/Governator/ANTISTATELONG/10156/070707110749/analysis/glm_hrf_Stats_REML+tlrc[6] /Volumes/Governator/ANTISTATELONG/10156/070707110749/analysis/glm_hrf_Stats_REML+tlrc[7] \
                  10128070808162602 /Volumes/Governator/ANTISTATELONG/10128/070808162602/analysis/glm_hrf_Stats_REML+tlrc[6] /Volumes/Governator/ANTISTATELONG/10128/070808162602/analysis/glm_hrf_Stats_REML+tlrc[7] \
                  10263070924093111 /Volumes/Governator/ANTISTATELONG/10263/070924093111/analysis/glm_hrf_Stats_REML+tlrc[6] /Volumes/Governator/ANTISTATELONG/10263/070924093111/analysis/glm_hrf_Stats_REML+tlrc[7] \
                  10125070928185843 /Volumes/Governator/ANTISTATELONG/10125/070928185843/analysis/glm_hrf_Stats_REML+tlrc[6] /Volumes/Governator/ANTISTATELONG/10125/070928185843/analysis/glm_hrf_Stats_REML+tlrc[7] \
                  10188071017164109 /Volumes/Governator/ANTISTATELONG/10188/071017164109/analysis/glm_hrf_Stats_REML+tlrc[6] /Volumes/Governator/ANTISTATELONG/10188/071017164109/analysis/glm_hrf_Stats_REML+tlrc[7] \
                  10485071106142917 /Volumes/Governator/ANTISTATELONG/10485/071106142917/analysis/glm_hrf_Stats_REML+tlrc[6] /Volumes/Governator/ANTISTATELONG/10485/071106142917/analysis/glm_hrf_Stats_REML+tlrc[7] \
                  10385071114164529 /Volumes/Governator/ANTISTATELONG/10385/071114164529/analysis/glm_hrf_Stats_REML+tlrc[6] /Volumes/Governator/ANTISTATELONG/10385/071114164529/analysis/glm_hrf_Stats_REML+tlrc[7] \
                  10186071130171215 /Volumes/Governator/ANTISTATELONG/10186/071130171215/analysis/glm_hrf_Stats_REML+tlrc[6] /Volumes/Governator/ANTISTATELONG/10186/071130171215/analysis/glm_hrf_Stats_REML+tlrc[7] \
                  10175071203174809 /Volumes/Governator/ANTISTATELONG/10175/071203174809/analysis/glm_hrf_Stats_REML+tlrc[6] /Volumes/Governator/ANTISTATELONG/10175/071203174809/analysis/glm_hrf_Stats_REML+tlrc[7] \
                  10133071204164954 /Volumes/Governator/ANTISTATELONG/10133/071204164954/analysis/glm_hrf_Stats_REML+tlrc[6] /Volumes/Governator/ANTISTATELONG/10133/071204164954/analysis/glm_hrf_Stats_REML+tlrc[7] \
                  10451071218163034 /Volumes/Governator/ANTISTATELONG/10451/071218163034/analysis/glm_hrf_Stats_REML+tlrc[6] /Volumes/Governator/ANTISTATELONG/10451/071218163034/analysis/glm_hrf_Stats_REML+tlrc[7] \
                  10181080102135908 /Volumes/Governator/ANTISTATELONG/10181/080102135908/analysis/glm_hrf_Stats_REML+tlrc[6] /Volumes/Governator/ANTISTATELONG/10181/080102135908/analysis/glm_hrf_Stats_REML+tlrc[7] \
                  10132080104102455 /Volumes/Governator/ANTISTATELONG/10132/080104102455/analysis/glm_hrf_Stats_REML+tlrc[6] /Volumes/Governator/ANTISTATELONG/10132/080104102455/analysis/glm_hrf_Stats_REML+tlrc[7] \
                  10500080115174945 /Volumes/Governator/ANTISTATELONG/10500/080115174945/analysis/glm_hrf_Stats_REML+tlrc[6] /Volumes/Governator/ANTISTATELONG/10500/080115174945/analysis/glm_hrf_Stats_REML+tlrc[7] \
                  10192080119104956 /Volumes/Governator/ANTISTATELONG/10192/080119104956/analysis/glm_hrf_Stats_REML+tlrc[6] /Volumes/Governator/ANTISTATELONG/10192/080119104956/analysis/glm_hrf_Stats_REML+tlrc[7] \
                  10486080129184609 /Volumes/Governator/ANTISTATELONG/10486/080129184609/analysis/glm_hrf_Stats_REML+tlrc[6] /Volumes/Governator/ANTISTATELONG/10486/080129184609/analysis/glm_hrf_Stats_REML+tlrc[7] \
                  10529080219140951 /Volumes/Governator/ANTISTATELONG/10529/080219140951/analysis/glm_hrf_Stats_REML+tlrc[6] /Volumes/Governator/ANTISTATELONG/10529/080219140951/analysis/glm_hrf_Stats_REML+tlrc[7] \
                  10160080328093055 /Volumes/Governator/ANTISTATELONG/10160/080328093055/analysis/glm_hrf_Stats_REML+tlrc[6] /Volumes/Governator/ANTISTATELONG/10160/080328093055/analysis/glm_hrf_Stats_REML+tlrc[7] \
                  10542080331154925 /Volumes/Governator/ANTISTATELONG/10542/080331154925/analysis/glm_hrf_Stats_REML+tlrc[6] /Volumes/Governator/ANTISTATELONG/10542/080331154925/analysis/glm_hrf_Stats_REML+tlrc[7] \
                  10408080522155832 /Volumes/Governator/ANTISTATELONG/10408/080522155832/analysis/glm_hrf_Stats_REML+tlrc[6] /Volumes/Governator/ANTISTATELONG/10408/080522155832/analysis/glm_hrf_Stats_REML+tlrc[7] \
                  10223080619123313 /Volumes/Governator/ANTISTATELONG/10223/080619123313/analysis/glm_hrf_Stats_REML+tlrc[6] /Volumes/Governator/ANTISTATELONG/10223/080619123313/analysis/glm_hrf_Stats_REML+tlrc[7] \
                  10152080806151206 /Volumes/Governator/ANTISTATELONG/10152/080806151206/analysis/glm_hrf_Stats_REML+tlrc[6] /Volumes/Governator/ANTISTATELONG/10152/080806151206/analysis/glm_hrf_Stats_REML+tlrc[7] \
                  10174080828160901 /Volumes/Governator/ANTISTATELONG/10174/080828160901/analysis/glm_hrf_Stats_REML+tlrc[6] /Volumes/Governator/ANTISTATELONG/10174/080828160901/analysis/glm_hrf_Stats_REML+tlrc[7] \
                  10335081013170955 /Volumes/Governator/ANTISTATELONG/10335/081013170955/analysis/glm_hrf_Stats_REML+tlrc[6] /Volumes/Governator/ANTISTATELONG/10335/081013170955/analysis/glm_hrf_Stats_REML+tlrc[7] \
                  10472081117161855 /Volumes/Governator/ANTISTATELONG/10472/081117161855/analysis/glm_hrf_Stats_REML+tlrc[6] /Volumes/Governator/ANTISTATELONG/10472/081117161855/analysis/glm_hrf_Stats_REML+tlrc[7] \
                  10368081120161731 /Volumes/Governator/ANTISTATELONG/10368/081120161731/analysis/glm_hrf_Stats_REML+tlrc[6] /Volumes/Governator/ANTISTATELONG/10368/081120161731/analysis/glm_hrf_Stats_REML+tlrc[7] \
                  10343081202160138 /Volumes/Governator/ANTISTATELONG/10343/081202160138/analysis/glm_hrf_Stats_REML+tlrc[6] /Volumes/Governator/ANTISTATELONG/10343/081202160138/analysis/glm_hrf_Stats_REML+tlrc[7] \
                  10220081203162435 /Volumes/Governator/ANTISTATELONG/10220/081203162435/analysis/glm_hrf_Stats_REML+tlrc[6] /Volumes/Governator/ANTISTATELONG/10220/081203162435/analysis/glm_hrf_Stats_REML+tlrc[7] \
                  10344081204162652 /Volumes/Governator/ANTISTATELONG/10344/081204162652/analysis/glm_hrf_Stats_REML+tlrc[6] /Volumes/Governator/ANTISTATELONG/10344/081204162652/analysis/glm_hrf_Stats_REML+tlrc[7] \
                  10201081213085343 /Volumes/Governator/ANTISTATELONG/10201/081213085343/analysis/glm_hrf_Stats_REML+tlrc[6] /Volumes/Governator/ANTISTATELONG/10201/081213085343/analysis/glm_hrf_Stats_REML+tlrc[7] \
                  10162081215154852 /Volumes/Governator/ANTISTATELONG/10162/081215154852/analysis/glm_hrf_Stats_REML+tlrc[6] /Volumes/Governator/ANTISTATELONG/10162/081215154852/analysis/glm_hrf_Stats_REML+tlrc[7] \
                  10173090121161304 /Volumes/Governator/ANTISTATELONG/10173/090121161304/analysis/glm_hrf_Stats_REML+tlrc[6] /Volumes/Governator/ANTISTATELONG/10173/090121161304/analysis/glm_hrf_Stats_REML+tlrc[7] \
                  10483090202162031 /Volumes/Governator/ANTISTATELONG/10483/090202162031/analysis/glm_hrf_Stats_REML+tlrc[6] /Volumes/Governator/ANTISTATELONG/10483/090202162031/analysis/glm_hrf_Stats_REML+tlrc[7] \
                  10248090318160554 /Volumes/Governator/ANTISTATELONG/10248/090318160554/analysis/glm_hrf_Stats_REML+tlrc[6] /Volumes/Governator/ANTISTATELONG/10248/090318160554/analysis/glm_hrf_Stats_REML+tlrc[7] \
                  10358090328104011 /Volumes/Governator/ANTISTATELONG/10358/090328104011/analysis/glm_hrf_Stats_REML+tlrc[6] /Volumes/Governator/ANTISTATELONG/10358/090328104011/analysis/glm_hrf_Stats_REML+tlrc[7] \
                  10193090411105408 /Volumes/Governator/ANTISTATELONG/10193/090411105408/analysis/glm_hrf_Stats_REML+tlrc[6] /Volumes/Governator/ANTISTATELONG/10193/090411105408/analysis/glm_hrf_Stats_REML+tlrc[7] \
                  10167090512163950 /Volumes/Governator/ANTISTATELONG/10167/090512163950/analysis/glm_hrf_Stats_REML+tlrc[6] /Volumes/Governator/ANTISTATELONG/10167/090512163950/analysis/glm_hrf_Stats_REML+tlrc[7] \
                  10316090514143105 /Volumes/Governator/ANTISTATELONG/10316/090514143105/analysis/glm_hrf_Stats_REML+tlrc[6] /Volumes/Governator/ANTISTATELONG/10316/090514143105/analysis/glm_hrf_Stats_REML+tlrc[7] \
                  10315090604143532 /Volumes/Governator/ANTISTATELONG/10315/090604143532/analysis/glm_hrf_Stats_REML+tlrc[6] /Volumes/Governator/ANTISTATELONG/10315/090604143532/analysis/glm_hrf_Stats_REML+tlrc[7] \
                  10169090613104355 /Volumes/Governator/ANTISTATELONG/10169/090613104355/analysis/glm_hrf_Stats_REML+tlrc[6] /Volumes/Governator/ANTISTATELONG/10169/090613104355/analysis/glm_hrf_Stats_REML+tlrc[7] \
                  10300090617130615 /Volumes/Governator/ANTISTATELONG/10300/090617130615/analysis/glm_hrf_Stats_REML+tlrc[6] /Volumes/Governator/ANTISTATELONG/10300/090617130615/analysis/glm_hrf_Stats_REML+tlrc[7] \
                  10288090715125121 /Volumes/Governator/ANTISTATELONG/10288/090715125121/analysis/glm_hrf_Stats_REML+tlrc[6] /Volumes/Governator/ANTISTATELONG/10288/090715125121/analysis/glm_hrf_Stats_REML+tlrc[7] \
                  10153090728161522 /Volumes/Governator/ANTISTATELONG/10153/090728161522/analysis/glm_hrf_Stats_REML+tlrc[6] /Volumes/Governator/ANTISTATELONG/10153/090728161522/analysis/glm_hrf_Stats_REML+tlrc[7] \
                  10161090820142507 /Volumes/Governator/ANTISTATELONG/10161/090820142507/analysis/glm_hrf_Stats_REML+tlrc[6] /Volumes/Governator/ANTISTATELONG/10161/090820142507/analysis/glm_hrf_Stats_REML+tlrc[7] \
                  10129090825164254 /Volumes/Governator/ANTISTATELONG/10129/090825164254/analysis/glm_hrf_Stats_REML+tlrc[6] /Volumes/Governator/ANTISTATELONG/10129/090825164254/analysis/glm_hrf_Stats_REML+tlrc[7] \
                  10163091010091003 /Volumes/Governator/ANTISTATELONG/10163/091010091003/analysis/glm_hrf_Stats_REML+tlrc[6] /Volumes/Governator/ANTISTATELONG/10163/091010091003/analysis/glm_hrf_Stats_REML+tlrc[7] \
                  10365091027163830 /Volumes/Governator/ANTISTATELONG/10365/091027163830/analysis/glm_hrf_Stats_REML+tlrc[6] /Volumes/Governator/ANTISTATELONG/10365/091027163830/analysis/glm_hrf_Stats_REML+tlrc[7] \
                  10489100107120845 /Volumes/Governator/ANTISTATELONG/10489/100107120845/analysis/glm_hrf_Stats_REML+tlrc[6] /Volumes/Governator/ANTISTATELONG/10489/100107120845/analysis/glm_hrf_Stats_REML+tlrc[7] \
                  10221100123085705 /Volumes/Governator/ANTISTATELONG/10221/100123085705/analysis/glm_hrf_Stats_REML+tlrc[6] /Volumes/Governator/ANTISTATELONG/10221/100123085705/analysis/glm_hrf_Stats_REML+tlrc[7] \
                  10138100213112008 /Volumes/Governator/ANTISTATELONG/10138/100213112008/analysis/glm_hrf_Stats_REML+tlrc[6] /Volumes/Governator/ANTISTATELONG/10138/100213112008/analysis/glm_hrf_Stats_REML+tlrc[7] \
                  10409100420164252 /Volumes/Governator/ANTISTATELONG/10409/100420164252/analysis/glm_hrf_Stats_REML+tlrc[6] /Volumes/Governator/ANTISTATELONG/10409/100420164252/analysis/glm_hrf_Stats_REML+tlrc[7] \
                  10807100503163517 /Volumes/Governator/ANTISTATELONG/10807/100503163517/analysis/glm_hrf_Stats_REML+tlrc[6] /Volumes/Governator/ANTISTATELONG/10807/100503163517/analysis/glm_hrf_Stats_REML+tlrc[7] \
                  10226100505160750 /Volumes/Governator/ANTISTATELONG/10226/100505160750/analysis/glm_hrf_Stats_REML+tlrc[6] /Volumes/Governator/ANTISTATELONG/10226/100505160750/analysis/glm_hrf_Stats_REML+tlrc[7] \
                  10717100508094543 /Volumes/Governator/ANTISTATELONG/10717/100508094543/analysis/glm_hrf_Stats_REML+tlrc[6] /Volumes/Governator/ANTISTATELONG/10717/100508094543/analysis/glm_hrf_Stats_REML+tlrc[7] \
                  10686100519155724 /Volumes/Governator/ANTISTATELONG/10686/100519155724/analysis/glm_hrf_Stats_REML+tlrc[6] /Volumes/Governator/ANTISTATELONG/10686/100519155724/analysis/glm_hrf_Stats_REML+tlrc[7] \
                  10699100522091923 /Volumes/Governator/ANTISTATELONG/10699/100522091923/analysis/glm_hrf_Stats_REML+tlrc[6] /Volumes/Governator/ANTISTATELONG/10699/100522091923/analysis/glm_hrf_Stats_REML+tlrc[7] \
                  10333100602155417 /Volumes/Governator/ANTISTATELONG/10333/100602155417/analysis/glm_hrf_Stats_REML+tlrc[6] /Volumes/Governator/ANTISTATELONG/10333/100602155417/analysis/glm_hrf_Stats_REML+tlrc[7] \
                  10825100609160740 /Volumes/Governator/ANTISTATELONG/10825/100609160740/analysis/glm_hrf_Stats_REML+tlrc[6] /Volumes/Governator/ANTISTATELONG/10825/100609160740/analysis/glm_hrf_Stats_REML+tlrc[7] \
                  10527100626104222 /Volumes/Governator/ANTISTATELONG/10527/100626104222/analysis/glm_hrf_Stats_REML+tlrc[6] /Volumes/Governator/ANTISTATELONG/10527/100626104222/analysis/glm_hrf_Stats_REML+tlrc[7] \
                  10480101023122142 /Volumes/Governator/ANTISTATELONG/10480/101023122142/analysis/glm_hrf_Stats_REML+tlrc[6] /Volumes/Governator/ANTISTATELONG/10480/101023122142/analysis/glm_hrf_Stats_REML+tlrc[7] \
                  10479101120120436 /Volumes/Governator/ANTISTATELONG/10479/101120120436/analysis/glm_hrf_Stats_REML+tlrc[6] /Volumes/Governator/ANTISTATELONG/10479/101120120436/analysis/glm_hrf_Stats_REML+tlrc[7] \
                  10184101120153518 /Volumes/Governator/ANTISTATELONG/10184/101120153518/analysis/glm_hrf_Stats_REML+tlrc[6] /Volumes/Governator/ANTISTATELONG/10184/101120153518/analysis/glm_hrf_Stats_REML+tlrc[7] \
                  10869101208165124 /Volumes/Governator/ANTISTATELONG/10869/101208165124/analysis/glm_hrf_Stats_REML+tlrc[6] /Volumes/Governator/ANTISTATELONG/10869/101208165124/analysis/glm_hrf_Stats_REML+tlrc[7] \
                  10470101218141509 /Volumes/Governator/ANTISTATELONG/10470/101218141509/analysis/glm_hrf_Stats_REML+tlrc[6] /Volumes/Governator/ANTISTATELONG/10470/101218141509/analysis/glm_hrf_Stats_REML+tlrc[7] \
                  10253110209170916 /Volumes/Governator/ANTISTATELONG/10253/110209170916/analysis/glm_hrf_Stats_REML+tlrc[6] /Volumes/Governator/ANTISTATELONG/10253/110209170916/analysis/glm_hrf_Stats_REML+tlrc[7] \
                  10878110226122311 /Volumes/Governator/ANTISTATELONG/10878/110226122311/analysis/glm_hrf_Stats_REML+tlrc[6] /Volumes/Governator/ANTISTATELONG/10878/110226122311/analysis/glm_hrf_Stats_REML+tlrc[7] \
                  10252110412160841 /Volumes/Governator/ANTISTATELONG/10252/110412160841/analysis/glm_hrf_Stats_REML+tlrc[6] /Volumes/Governator/ANTISTATELONG/10252/110412160841/analysis/glm_hrf_Stats_REML+tlrc[7] \
                  10820110601171939 /Volumes/Governator/ANTISTATELONG/10820/110601171939/analysis/glm_hrf_Stats_REML+tlrc[6] /Volumes/Governator/ANTISTATELONG/10820/110601171939/analysis/glm_hrf_Stats_REML+tlrc[7] \
                  10816111109163617 /Volumes/Governator/ANTISTATELONG/10816/111109163617/analysis/glm_hrf_Stats_REML+tlrc[6] /Volumes/Governator/ANTISTATELONG/10816/111109163617/analysis/glm_hrf_Stats_REML+tlrc[7] \
                  10241111220144044 /Volumes/Governator/ANTISTATELONG/10241/111220144044/analysis/glm_hrf_Stats_REML+tlrc[6] /Volumes/Governator/ANTISTATELONG/10241/111220144044/analysis/glm_hrf_Stats_REML+tlrc[7] \
                  10477081118152142 /Volumes/Governator/ANTISTATELONG/10477/081118152142/analysis/glm_hrf_Stats_REML+tlrc[6] /Volumes/Governator/ANTISTATELONG/10477/081118152142/analysis/glm_hrf_Stats_REML+tlrc[7] \
                  10280070623150331 /Volumes/Governator/ANTISTATELONG/10280/070623150331/analysis/glm_hrf_Stats_REML+tlrc[6] /Volumes/Governator/ANTISTATELONG/10280/070623150331/analysis/glm_hrf_Stats_REML+tlrc[7] \
                  10492071126090657 /Volumes/Governator/ANTISTATELONG/10492/071126090657/analysis/glm_hrf_Stats_REML+tlrc[6] /Volumes/Governator/ANTISTATELONG/10492/071126090657/analysis/glm_hrf_Stats_REML+tlrc[7] \  2>&1 |
tee /Volumes/Governator/ANTISTATELONG/AgeGrpAnalyses/3dMEMA/out_Quad_ASerrorCorr.log
rm $tempdir
