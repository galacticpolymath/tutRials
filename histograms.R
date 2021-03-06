#Install/load pacman
if(!require(pacman)){install.packages("pacman");require(pacman)}
#Install/load tons of packages
p_load(ggplot2,tidyverse,gganimate,viridis,gifski)

#bring in Galactic Polymath styling
source("https://raw.githubusercontent.com/galacticpolymath/ggGalactic/master/ggGalactic.R")
data(trees)
range(trees$Height)
breaksNlabs <- seq(60,90,5)


h<-ggplot(trees,aes(x=Height))+geom_histogram(breaks=breaksNlabs,col=gpPal2[21],fill=gpPal2[13])+ggGalactic()+labs(x="Tree Height (ft)",y="Count",title="Distribution of Heights for 33 Cherry Trees")+scale_x_continuous(labels=breaksNlabs, breaks = breaksNlabs)
h
ggsave("hist_cherry_trees.png",width=10,height=6)


#Reverse engineer a dotplot from this, cuz geom_dotplot is soooo stupid!
brks<-h[["scales"]][["scales"]][[1]][["breaks"]]
mids<-sapply(1:(length(brks)-1),function(i){median(c(brks[i],brks[i+1]))})

broken<-cut(trees$Height,brks,labels=F)
key<-sort(unique(broken))
names(key)<-paste0("`",mids,"`")
dotX<-sort(recode(as.character(broken),"1"="62.5","2"="67.5","3"="72.5","4"="77.5","5"="82.5","6"="87.5" ))
dotY<-unlist(sapply(table(dotX),function(x) 1:x))
x.orig=sort(trees$Height)
y.orig=unlist(sapply(table(x.orig),function(x) 1:x))

dot<-data.frame(x=c(x.orig,as.numeric(dotX),x.orig),y=c(y.orig,as.numeric(dotY),y.orig),state=c(sapply(1:3,function(x) rep(x,length(x.orig)))))
dot$col=factor(rep(sort(broken),3))
#Unbinned dot plot
binless<-ggplot(dot %>% subset(state==1),aes(x=x,y=y))+geom_point(size=5)+ggGalactic()+labs(x="Tree Height (ft)",y="Count",title="Dot Plot of Tree Heights")+scale_y_continuous(breaks=seq(0,10,2),limits=c(0,10),labels=seq(0,10,2))+scale_x_continuous(labels=breaksNlabs, breaks = breaksNlabs,limits=c(60,90))
binless
ggsave("Dotplot_trees_unbinned.png",width=10,height=6)

#Add bins
#arrows: paste0('\u2190',binlabs,'\u2192')
binlabs<-sapply(1:(length(brks)-1),function(i) {paste0(" >",brks[i]," : ",brks[i+1]," ")})

fills<-viridis::viridis(6)
cols<-c(rep("white",3),rep(1,3))#grey.colors(6,start=0, end=1,rev=T)[c(1,1,1,1,)]


binful<-ggplot(dot %>% subset(state==1),aes(x=x,y=y))+geom_point(size=5,aes(col=col),show.legend=F)+ggGalactic()+labs(x="Tree Height (ft)",y="Count",title="Dot Plot of Tree Heights")+scale_y_continuous(breaks=seq(0,10,2),limits=c(0,10),labels=seq(0,10,2))+scale_colour_manual(values=fills)+scale_x_continuous(labels=breaksNlabs, breaks = breaksNlabs,limits=c(60,90))+geom_vline(xintercept=seq(60,90,5))+geom_label(data=data.frame(mids),aes(x=mids,y=.25),label=binlabs,hjust=0.5,size=6,fill=fills,col=cols)+ ggtitle("Dot Plot with 5 ft. Bins")
binful
ggsave("Dotplot_trees_labeledBins.png",width=11,height=6)



#Binning Dot Plot Animation
binz<-ggplot(dot,aes(x=x,y=y-.5))+geom_point(size=5,aes(col=col),show.legend=F)+ggGalactic()+labs(x="Tree Height (ft)",y="Count",title="Combining Data Points into Bins")+scale_y_continuous(breaks=seq(0,10,2),limits=c(-.25,10),labels=seq(0,10,2))+scale_colour_manual(values=fills)+scale_x_continuous(labels=breaksNlabs, breaks = breaksNlabs,limits=c(60,90))+geom_vline(xintercept=seq(60,90,5))+geom_label(data=data.frame(mids),aes(x=mids,y=-.25),label=binlabs,hjust=0.5,size=6,fill=fills,col=cols) +transition_states(state)
#Not an easy way to specify output dims with anim_save call
options(gganimate.dev_args = list(width = 800, height = 480,units="px"))
animate(binz,duration=7,renderer=gifski_renderer())
anim_save("Dotplot_trees_labeledBins.gif") 


#Get rid of bin marks n labels
preHist<-ggplot(dot %>% subset(state==2),aes(x=x,y=y-.5))+geom_point(size=5)+ggGalactic()+labs(x="Tree Height (ft)",y="Count",title="This is Basically a Histogram")+ylim(-.25,10)+scale_x_continuous(labels=breaksNlabs, breaks = breaksNlabs,limits=c(60,90))
preHist
ggsave("Dotplot_trees_prehistogram.png",width=10,height=6)

#Finally, a histogram
ggplot(dot,aes(x=x,y=y-.5))+geom_histogram(data=trees,aes(x=Height),breaks=breaksNlabs,col=gpPal2[21],fill=gpPal2[13],inherit.aes = F)+ggGalactic()+labs(x="Tree Height (ft)",y="Count",title="Histogram of Tree Heights")+ylim(0,10)+scale_x_continuous(labels=breaksNlabs, breaks = breaksNlabs,limits=c(60,90))
ggsave("Dotplot_trees_histogram.png",width=10,height=6)
