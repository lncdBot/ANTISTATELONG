library(ggplot2)
library(plyr)

ages<-read.table('VoxelwiseHLM//oldTxt/listage.txt')
names(ages)<-c('subj','scandate','age','donno')
ages<-ages[ages$age>=9&ages$age<=26,]

minAgeLookup <- ddply(ages, .(subj), function(x){min(x$age)} )
names(minAgeLookup)[2] <- 'startage'
ages <- merge(minAgeLookup, ages)
#ages$subj <- as.factor(ages$subj)[order(ages$startage)]
p <- ggplot(ages,aes(x=age,y=as.factor(startage),group=subj)) +
     geom_line() + geom_point(shape=21,color='grey', fill='black') + theme_bw() +
     labs(x='Age (years) at scan', y='')+ #,title='Longitudinal Recordings') + 
     theme(axis.text.y=element_blank(),  panel.grid.minor.y=element_blank(),panel.grid.major.y=element_blank(), axis.ticks.y=element_blank() ) + 
     scale_x_continuous(breaks=seq(5,30,by=5)) +
     theme(panel.border = element_blank(),axis.line = element_line(color="black"))
ggsave(p, file='ageAtScanPerSubj.tiff',dpi=300)
pdf('ageAtScanPerSubj.pdf')
print(p)
dev.off()
