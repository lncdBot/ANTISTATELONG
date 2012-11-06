# source me and I'll create:
# img_R20121018/
#   supfig3-Left_PPC.png      supfig3-Right_putamen.png  supfig5-Left_dlPFC.png
#   supfig3-Left_putamen.png  supfig3-SEF.png            supfig5-Left_vlPFC.png
#   supfig5-Right_dlPFC.png

library(ggplot2)
library(reshape2)

#AgeC <-c(-7.726,-6.726,-5.726,-4.726,-3.726,-2.726,-1.726,-0.726,0.274,1.274,2.274,3.274,4.274,5.274,6.274,7.274,8.274 );
# invAgeC  <- c(0.051,0.040,0.031,0.024,0.017,0.012,0.007,0.003,-0.001,-0.004,-0.007,-0.010,-0.012,-0.014,-0.016,-0.018,-0.020)
Age      <- 9:26
AgeC     <- Age - 16.726
invAgeC  <- 1/Age - 1/16.726

# figure 3.
files<- c( 'csv/ageC_SEF.csv', 'csv/ageC_PPC_L.csv', 'csv/ageC_putamen_L.csv', 'csv/ageC_putamen_R.csv')
# figure 1.
files <- c(files, 'csv_parallel/ASpErr_invageC.csv')
# figure 5. and 1.
files <- c(files,paste('csv_parallel',c('dlPFC_L_invageC.csv' ,  'dlPFC_R_invageC.csv',  '20121018_vlPFC_L_invageC.csv', '20121018_Vlatcorr_invageC.csv'),sep='/'))

allmodels<-data.frame()

for (i in 1:length(files)){

 # strip junk, get what the title should be
 if(length(grep('Vlatcorr',files[i]))>0){
   figname='supfig1'
   xvals=invAgeC
   xvalsmean=invAgeC
   yvals=Age
   ylim=c(300,700)
   ylab='Latency (ms)'
   t='AS Correct Lateancy'
   meanx='FVINVAGE'
   idvx='ECINVAGE'
 }
 else if(length(grep('ASpErr',files[i]))>0){
   figname='supfig1'
   xvals=invAgeC[c(8,9)]
   xvalsmean=invAgeC
   yvals=Age[c(8,9)]
   ylim=c(0,1)
   ylab='Error Ratio'
   t<-'AS Error Ratio'
   meanx='FVINVAGE'
   idvx='ECINVAGE'
 }
 else if (length(grep('csv/',files[i]))>0) {
   figname='supfig3'
   xvals=AgeC
   xvalsmean=AgeC
   yvals=Age
   ylim=c(-.05,.15)
   ylab='% Signal Change'
   t<-sub('.*ageC_(.*).csv',"\\1", files[i], perl=T)
   t<-sub('(.*)_L','Left \\1',t); t<-sub('(.*)_R','Right \\1',t)
   meanx='FVAGEC'
   idvx='ECAGEC'
 }
 else if(length(grep('csv_parallel/',files[i])>0)) {
   figname='supfig5'
   xvals=invAgeC[c(8,9)]
   xvalsmean=invAgeC
   yvals=Age[c(8,9)]
   ylim=c(-.05,.15)
   ylab='% Signal Change'
   t<-sub('.*/(.*)_invageC.csv',"\\1", files[i], perl=T)
   t<-sub('(.*)_L','Left \\1',t); t<-sub('(.*)_R','Right \\1',t); t<-sub('20121018_','',t)
   meanx='FVINVAGE'
   idvx='ECINVAGE'
 }
 else {
   print(c('?',files[i]))
   next
 }

 print(paste(i,files[i],t,figname,meanx,idvx))
 # read in the csv
 d<-read.table(files[i],sep=',',header=T)
 # always use uppercase
 names(d)<-toupper(names(d))
 # make naming consistant
 names(d) <- gsub("SEXMREF","SEXNUM",names(d))

 # use sex55 if it exists
 if(length(grep('SEX55$',names(d)))>0)   d$SEXNUM<-d$SEX55+.5

 ##
 # make a dataframe with points for each age with  sex (color) and id (group) values
 ##
 # get the mean
 m<-data.frame(y=d[1,'FVINTRCP'] + xvalsmean*d[1,meanx], Age=Age, sex=3,id='mean')
 # get individuals
 s<-do.call("rbind",lapply(1:nrow(d),function(i){data.frame(y=d[i,'ECINTRCP'] + xvals*d[i,idvx], Age=yvals, sex=d[i,'SEXNUM'],id=d[i,1])}))
 # cobmine the two
 tograph<-rbind(s,m)
 tograph$figure<-figname
 tograph$graph<-t

 # make sex a factor (attach mean to sex for displaying) and give names
 tograph$sex<-as.factor(tograph$sex)
 levels(tograph$sex)<-c('female','male','mean')

 allmodels<-rbind(allmodels,tograph)
 # setup plot
 g <- ggplot(data=tograph,aes(x=Age,y=y,color=sex,size=sex))

 png(paste('img_R20121018/',figname,'-',gsub(' ','_',t),'.png',sep=''))
 print(
   g + geom_line(aes(group=id)) + scale_color_manual(values=c('red','blue','black')) + scale_size_manual(values=(c(.5,.5,2)))+
     ggtitle(t) + theme(text=element_text(size=24))+ scale_y_continuous(ylab, limits=ylim) +
     theme(legend.position="none")  #remove this to get the legend back
 )
 dev.off()
}

for (subfig in paste('supfig',c(3,5),sep='')) {
  tog<-subset(allmodels,figure==subfig)
  g <- ggplot(data=tog,aes(x=Age,y=y,color=sex,size=sex))
  imgfilename <-paste('img_R20121018/',subfig,'.png',sep='')
  print(c(subfig, imgfilename))
  png(imgfilename)
  print(
    g + geom_line(aes(group=id)) + scale_color_manual(values=c('red','blue','black')) + scale_size_manual(values=(c(.5,.5,2)))+
      theme(text=element_text(size=24))+ scale_y_continuous('% Signal Change',limits=c(-.05,.15)) + facet_wrap(~graph,ncol=2)
      # + theme(legend.position="none")  #remove this to get the legend back
  )
  dev.off()
}

########################### parallels



# for (i in 1:length(files)){
#  print(paste(i,files[i],t))
# # strip junk, get what the title should be
#
#  # read in the csv
#  d<-read.table(files[i],sep=',',header=T)
#  # always use uppercase
#  names(d)<-toupper(names(d))
#  # make naming consistant
#  names(d) <- gsub("SEXMREF","SEXNUM",names(d))
# 
#  ##
#  # make a dataframe with points for each age with  sex (color) and id (group) values
#  ##
#  # get the mean, make a full line
#  m<-data.frame(y=d[1,'FVINTRCP'] + invAgeC*d[1,'FVINVAGE'],
#           Age=Age, sex=3,id='mean')
# 
#  # get individuals, only make a partial line
#  #agepartial=c(-.3,.3)
# 
#  # the x in y=a*x+b is x=1/age - 1/mu = agepartial = 1/{16,17} -1/16.72
#  # so age should be 16,17
#  s<-do.call("rbind",lapply(1:nrow(d),function(i){data.frame(
#           y=d[i,'ECINTRCP'] + invAgeC[c(8,9)]*d[i,'ECINVAGE'],
#           Age=Age[c(8,9)],                 sex=d[i,'SEXNUM'],id=d[i,1])}))
#  # cobmine the two
#  tograph <-rbind(s,m)
#  # make sex a factor (attach mean to sex for displaying) and give names
#  tograph$sex<-as.factor(tograph$sex)
#  levels(tograph$sex)<-c('female','male','mean')
# 
#  # setup plot
#  g <- ggplot(data=tograph,aes(x=Age,y=y,color=sex,size=sex))
# 
# 
#  png(paste('img_R20121018/supfig5-',sub(' ','_',t),'.png',sep=''))
#  print(g + geom_line(aes(group=id)) + scale_color_manual(values=c('red','blue','black')) + scale_size_manual(values=(c(.5,.5,2)))+
#      ggtitle(t) + theme(text=element_text(size=24))+ scale_y_continuous('% Signal Change', limits=c(-.05,.15)) +
#      theme(legend.position="none")  #remove this to get the legend back
#   )
#  dev.off()
# 
# }
