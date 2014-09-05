##### print info
getinfo <- function(ses,dmg,mrg){
   ## Luna IDS
   uniqSES<-unique(ses$LunaID)
   uniqD  <-unique(dmg$LunaID)
   cat( 'SES  : ',nrow(ses),' rows with ', length(uniqSES)           ,' unique lunas\n' )
   cat( 'demo : ',nrow(dmg),' rows with ', length(uniqD)             ,' unique lunas\n' )
   cat( 'merge: ',nrow(mrg),' rows with ', length(unique(mrg$LunaID)),' unique lunas\n' )
   cat('\n')

   cat('in SES not in D: ')
   cat(setdiff(uniqSES,uniqD))
   cat('\n')

   cat('in D not in SES: ')
   cat(setdiff(uniqD,uniqSES))
   cat('\n\n')

   ## Missing values
   cat('\nmissing values in ses\n')
   print(t(sapply(c('CommunitySEPz7mean','Zlevel_eduf','Zlevel_occf'),function(x){ length(which(is.na(ses[,x])))})))
   cat('\n')

   cat('\nmissing values in merged\n')
   print(t(sapply(c('CommunitySEPz7mean','Zlevel_eduf','Zlevel_occf'),function(x){ i<-which(is.na(mrg[,x])); data.frame(totalmiss=length(i),people=length(unique(mrg$LunaID[i])))})))
   cat('\n')

   cat('\n\nMissing Lunas:\n\n')
   print(
     sapply(c('CommunitySEPz7mean','Zlevel_eduf','Zlevel_occf'),function(x){ sort(unique(ses$LunaID[which(is.na(mrg[,x]))]))})
   )
}




###############
a   <-read.csv('vw_input/AntistateSES_clearVarNames_abbForWill.csv',header=T)
ses <- a[,c('LunaID','VisitID','CommunitySEPz7mean','Zlevel_eduf','Zlevel_occf')]
dmg <-read.table('vw_input/Data302_9to26_20120504_copy.dat',header=T,sep="\t")
mrg <-merge(dmg,ses,by='LunaID')

# tests
m <- merge(dmg,a,by='LunaID')

if(length(which(m$SexID.x!=m$SexID.y))>0){
 error('demo and ses merge failed: sex is reported differently')
}

i<-which(m$VisitID.x == m$VisitID.y)
if(max(abs(m$Age.y[i]-m$Age.x[i]),na.rm=T)>.1){
 error('demo and ses merge failed: large age differences')
}


todrop <- unique(unlist( lapply(c('CommunitySEPz7mean','Zlevel_eduf','Zlevel_occf'),function(x){ which(is.na(mrg[,x])) }) ) )
mrg <- mrg[-todrop,]
write.table(mrg,file="vw_input/SES_Demo.dat",row.names=F,sep="\t", quote=F)

getinfo(ses,dmg,mrg)


