a   <-read.csv('vw_input/AntistateSES_clearVarNames_abbForWill.csv',header=T)
ses <- a[,c('LunaID','VisitID','CommunitySEPz7mean','Zlevel_eduf','Zlevel_occf')]
dmg <-read.table('vw_input/demographic.dat',header=T,sep="\t")
mrg <-merge(dmg,ses,by='LunaID')
write.table(mrg,file="vw_input/SES_Demo.dat",row.names=F,sep="\t", quote=F)

