#function to add transparency to colors
alpha.col<-function(color,alpha)
	{
		#check to see if alpha already set
		
		tmp <- col2rgb(color)/255 
		rgb(tmp[1,],tmp[2,],tmp[3,],alpha=alpha)
	}

#plot cluster representation of point group via connected edges to a group center
edge.group<-function(obj,color,lwd=1,lty=1)
	{
		#split objs and inputs for each group based on color (color, lwd, lty  are all mapped together)
		tmp.obj<-as.data.frame(obj)
		tmp.char<-as.data.frame(cbind(color,lwd,lty))
		fct<-as.factor(color)
		.obj<-split(tmp.obj,fct)
		.char<-split(tmp.char,fct)
		
		i<-1
		for(i in 1:nlevels(fct))
		{	
			#group center
			pts<-.obj[[i]]
			m<-colMeans(pts)
			
			#plotting
			segments(m[1],m[2],pts[,1],pts[,2],col=as.character(.char[[i]][,1]),
				lwd=as.numeric(as.character(.char[[i]][,2])),lty=as.numeric(as.character(.char[[i]][,3])))
		}
	}

#plot ellipse representation of point group 	
ellipse.group<-function(obj,color,lwd=1,lty=1,border="#00000050",ellipse.level=.95,show.polygon=TRUE, alpha=.5)
	{
		check.get.packages(c("ellipse","splancs"))
		
		#check color and add extra transparency
		color<-alpha.col(color,alpha)	
		#split objs and inputs for each group based on color (color, lwd, lty  are all mapped together)
		tmp.obj<-as.data.frame(obj)
		tmp.char<-as.data.frame(cbind(color,lwd,lty,border))
		fct<-as.factor(color)
		.obj<-split(tmp.obj,fct)
		.char<-split(tmp.char,fct)

		#calculate points for ellipse
		ellipse.var<-lapply(1:nlevels(fct),function(i)
			{
				tmp<-list()
				pts<-.obj[[i]]
				if(nrow(pts)<=2){pts<-matrix(c(NA,NA))}# avoid polygon error for 1D object
				m<-colMeans(pts)
				tmp$points<-tryCatch(ellipse(as.matrix(cov(pts)),centre=c(m[1],m[2]),level=ellipse.level),
					error=function(e){NA})
				tmp$color<-unique(as.character(.char[[i]][,1]))[1] # choose single value
				tmp$lwd<-unique(as.numeric(as.character(.char[[i]][,2])))[1]
				tmp$lty<-unique(as.numeric(as.character(.char[[i]][,3])))[1]
				tmp$border<-unique(as.character(.char[[i]][,4]))[1]
				tmp
			})
			
		# get size to plot smallest last
		ellipse.size<-sapply(1:length(ellipse.var),function(i)
			{
				tryCatch(areapl(ellipse.var[[i]]$points),error=function(e){NA})
			})
		
		plot.order<-order(ellipse.size,decreasing=TRUE)
		
		#plot
		for(i in 1:length(ellipse.var))
			{
				if(!is.na(ellipse.var[[plot.order[i]]]$points))
					{
						if(show.polygon==TRUE)
						{
							polygon(unlist(ellipse.var[[plot.order[i]]]$points[,1]),unlist(ellipse.var[[plot.order[i]]]$points[,2]),
								col=as.character(ellipse.var[[plot.order[i]]]$color),border = ellipse.var[[plot.order[i]]]$border,
								lwd=ellipse.var[[plot.order[i]]]$lwd,lty=ellipse.var[[plot.order[i]]]$lty)		
						}else{
							lines(unlist(ellipse.var[[plot.order[i]]]$points[,1]),unlist(ellipse.var[[plot.order[i]]]$points[,2]),
								col=as.character(ellipse.var[[plot.order[i]]]$color),border = ellipse.var[[plot.order[i]]],
								lwd=ellipse.var[[plot.order[i]]]$lwd,lty=ellipse.var[[plot.order[i]]]$lty)	
						}				
					}
			}
	}		
	
#plot polygon representation of point group
polygon.group<-function(obj,color,lwd=1,lty=1,border="#00000050",.level=.95,show.polygon=TRUE, alpha=.5)
	{
		check.get.packages("grDevices")#convex hull

		#check color and add extra transparency
		color<-alpha.col(color,alpha)	
		#split objs and inputs for each group based on color (color, lwd, lty  are all mapped together)
		tmp.obj<-as.data.frame(obj)
		tmp.char<-as.data.frame(cbind(color,lwd,lty,border))
		fct<-as.factor(color)
		.obj<-split(tmp.obj,fct)
		.char<-split(tmp.char,fct)

		#calculate points for 
		.var<-lapply(1:nlevels(fct),function(i)
			{
				tmp<-list()
				pts<-.obj[[i]]
				if(nrow(pts)<=2){pts<-NA} # avoid polygon error for 1D object
				tmp$points<-tryCatch(as.matrix(pts)[chull(as.matrix(pts)),],
					error=function(e){NA})
				tmp$color<-unique(as.character(.char[[i]][,1]))[1] # choose single value
				tmp$lwd<-unique(as.numeric(as.character(.char[[i]][,2])))[1]
				tmp$lty<-unique(as.numeric(as.character(.char[[i]][,3])))[1]
				tmp$border<-unique(as.character(.char[[i]][,4]))[1]
				tmp
			})
			
		# get size to plot smallest last
		.size<-sapply(1:length(.var),function(i)
			{
				tryCatch(areapl(.var[[i]]$points),error=function(e){NA})
			})
		
		plot.order<-order(.size,decreasing=TRUE)
		
		#plot
		for(i in 1:length(.var))
			{
				if(!is.na(.var[[plot.order[i]]]$points))
					{
						if(show.polygon==TRUE)
						{
							polygon(unlist(.var[[plot.order[i]]]$points[,1]),unlist(.var[[plot.order[i]]]$points[,2]),
								col=as.character(.var[[plot.order[i]]]$color),border = .var[[plot.order[i]]]$border,
								lwd=.var[[plot.order[i]]]$lwd,lty=.var[[plot.order[i]]]$lty)		
						}else{
							lines(unlist(.var[[plot.order[i]]]$points[,1]),unlist(.var[[plot.order[i]]]$points[,2]),
								col=as.character(.var[[plot.order[i]]]$color),border = .var[[plot.order[i]]],
								lwd=.var[[plot.order[i]]]$lwd,lty=.var[[plot.order[i]]]$lty)	
						}	
					}		
			}
	}		

#interactively choose colors	
getcolors <- function(n){
	# from http://menugget.blogspot.com/2013/01/choosing-colors-visually-with-getcolors.html#more
	 N <- 6
	 
	 X <- seq(N^2)-0.5
	 Y <- seq(N)-0.5
	 Z <- matrix(0, nrow=length(X), ncol=length(Y))
	 
	 LEV <- seq(0,1,,N) 
	 R <- rep(LEV, each=N^2)
	 G <- rep(rep(LEV, each=N), N)
	 B <- rep(LEV, N^2)
	 
	 x11(width=6, height=6)
	 layout(matrix(1:2, nrow=2, ncol=1), widths=c(6), heights=c(1.5,4.5))
	 op <- par(mar=c(1,3,2,1))
	 
	 image(X,Y,Z, col=NA, xlab="", ylab="", xaxt="n", yaxt="n")
	 for(i in seq(Z)){
	  xs <- c(((i-1) %% N^2), ((i-1) %% N^2), ((i-1) %% N^2) + 1, ((i-1) %% N^2) + 1)
	  ys <- c(((i-1) %/% N^2), ((i-1) %/% N^2)+1, ((i-1) %/% N^2) + 1, ((i-1) %/% N^2))
	  polygon(xs, ys, col=rgb(R[i], G[i], B[i]), border=NA)
	 }
	 mtext(paste("Click on", n, "colors [please]"), side=3, line=0.5)
	 box()
	 
	 COLS <- NA*seq(n)
	 for(i in seq(n)){
	  coord <- locator(1)
	  red <- coord$y / N
	  green <- coord$x / N^2
	  blue <- (coord$x %% N) / N
	  #pos <- (round(coord$y-1) * N^2) + round(coord$x)
	  COLS[i] <- rgb(red, green, blue)
	 }
	 
	 par(mar=c(1,3,0,1))
	 pal <- colorRampPalette(c("black", "white"))
	 image(x=1:100, y=seq(n), z=matrix(rep(1:100,n), nrow=100, ncol=n), col=pal(100), xlab="", ylab="", xaxt="n", yaxt="n")
	 box()
	 for(i in seq(n)){
	  lines(x=c(1,100), y=c(i,i), col=COLS[i], lwd=4)
	 }
	 axis(2, at=seq(n))
	 
	 par(op)
	 
	 COLS
}

#add scale to plot
image.scale <- function(z, zlim, col = heat.colors(12),breaks, horiz=TRUE, ylim=NULL, xlim=NULL, ...){
 if(!missing(breaks)){
  if(length(breaks) != (length(col)+1)){stop("must have one more break than colour")}
 }
 if(missing(breaks) & !missing(zlim)){
  breaks <- seq(zlim[1], zlim[2], length.out=(length(col)+1)) 
 }
 if(missing(breaks) & missing(zlim)){
  zlim <- range(z, na.rm=TRUE)
  zlim[2] <- zlim[2]+c(zlim[2]-zlim[1])*(1E-3)#adds a bit to the range in both directions
  zlim[1] <- zlim[1]-c(zlim[2]-zlim[1])*(1E-3)
  breaks <- seq(zlim[1], zlim[2], length.out=(length(col)+1))
 }
 poly <- vector(mode="list", length(col))
 for(i in seq(poly)){
  poly[[i]] <- c(breaks[i], breaks[i+1], breaks[i+1], breaks[i])
 }
 xaxt <- ifelse(horiz, "s", "n")
 yaxt <- ifelse(horiz, "n", "s")
 if(horiz){YLIM<-c(0,1); XLIM<-range(breaks)}
 if(!horiz){YLIM<-range(breaks); XLIM<-c(0,1)}
 if(missing(xlim)) xlim=XLIM
 if(missing(ylim)) ylim=YLIM
 plot(1,1,t="n",ylim=ylim, xlim=xlim, xaxt=xaxt, yaxt=yaxt, xaxs="i", yaxs="i", ...)  
 for(i in seq(poly)){
  if(horiz){
   polygon(poly[[i]], c(0,0,1,1), col=col[i], border=NA)
  }
  if(!horiz){
   polygon(c(0,0,1,1), poly[[i]], col=col[i], border=NA)
  }
 }
}

#map object to a color (save object to a legend "scatter.plot.legend" in envir = devium, eventually make this defineable)
convert.to.color<-function(object,pallet="rainbow",alpha=.5,legend="color")
	{
		
		#function to add transparency to colors
		alpha.col<-function(color,alpha)
			{
				tmp <- col2rgb(color)/255 
				rgb(tmp[1,],tmp[2,],tmp[3,],alpha=alpha)
			}
		
		fct<-as.factor(unlist(object))
		out<-switch(pallet,
		rainbow	 	= 	rainbow(nlevels(fct),alpha=alpha)[fct],						
		heat 		= 	heat.colors(nlevels(fct),alpha=alpha)[fct],
		terrain 	= 	terrain.colors(nlevels(fct),alpha=alpha)[fct], 
		topo		= 	topo.colors(nlevels(fct),alpha=alpha)[fct],
		chromatic 	= 	cm.colors(nlevels(fct),alpha=alpha)[fct])
		
		#bind with factor for legend
		obj<-list(data.frame(factor = fct,color=out))
		names(obj)<-legend
		#save to legend 
		set.plot.legend(obj,name="scatter.plot.legend",env=devium)
		
		return(out)
	}

#convert/map object to shape
convert.to.shape<-function(object,from=c(21:25,1:20),legend="pch")
	{
		fct<-as.factor(unlist(object))
		out<-as.numeric(from[1:nlevels(fct)][fct])
		
		#bind with factor for legend
		obj<-list(data.frame(factor = fct,pch=out))
		names(obj)<-legend
		#save to legend 
		set.plot.legend(obj,name="scatter.plot.legend",env=devium)
		return(out)
	}

#convert.map object to size
convert.to.size<-function(object,from=c(1:100),legend="cex")
		{
			
			fct<-as.factor(unlist(object))
			if(nlevels(fct)==0)
				{
					olen<-1 
				} else {
					olen<-nlevels(fct)
				}
			
			if(legend=="cex")
				{
					from=seq(if.or("size.min",default=1),if.or("size.max",default=5),length.out=olen)
				} else {
					from=seq(if.or("width.min",default=1),if.or("width.max",default=5),length.out=olen)
				}
				
		
			out<-as.numeric(from[1:nlevels(fct)][fct])
			
			
			#bind with factor for legend
			obj<-list(data.frame(factor = fct,pch=out))
			names(obj)<-legend
			#save to legend 
			set.plot.legend(obj,name="scatter.plot.legend",env=devium)	
			
			#hack to change size with out a mapping obj
			if(olen==1)
				{ 
					out<-from 
				}
				
			return(out)
		}

#add entry in plot legend object
set.plot.legend<-function(obj,name="scatter.plot.legend",env=devium)
	{
		#object = get("scatter.plot.legend.ids", env= devium) contains names of mapped objects
	
		#check or make "scatter.plot.legend"
		if(!exists( name,env=devium)){assign(name,list(),env=devium)}
		record<-get(name,env=env)
		
		#append for legend 
		#get unique joint levels
		tmp<-join.columns(obj)
		if(class(tmp)=="NULL")
			{
				return()
			}else{
				tmp<-do.call("rbind",strsplit(unique(tmp),"\\|"))
				colnames(tmp)<-c("name",names(obj))
				record[[names(obj)]]<-as.data.frame(tmp)
				
				#store for legend
				assign(name,record,env=env)
			}
	}
						
#combine multiple ggplots (no ref)
multiplot <- function(..., plotlist=NULL, cols) {
    require(grid)

    # Make a list from the ... arguments and plotlist
    plots <- c(list(...), plotlist)

    numPlots = length(plots)

    # Make the panel
    plotCols = cols                          # Number of columns of plots
    plotRows = ceiling(numPlots/plotCols) # Number of rows needed, calculated from # of cols

    # Set up the page
    grid.newpage()
    pushViewport(viewport(layout = grid.layout(plotRows, plotCols)))
    vplayout <- function(x, y)
        viewport(layout.pos.row = x, layout.pos.col = y)

    # Make each plot, in the correct location
    for (i in 1:numPlots) {
        curRow = ceiling(i/plotCols)
        curCol = (i-1) %% plotCols + 1
        print(plots[[i]], vp = vplayout(curRow, curCol ))
    }

}

#~time series line plot for multiple groups
time.series.plot<-function(variable,group,time,xlab="Time",color=NULL,alpha=0.9,size=3,text=20,legend="right",background=element_blank(),save=FALSE){
	
	
	tmp.data<-data.frame(variable=variable,group=group,time=time)
	dfc<-summarySE (data=tmp.data, measurevar=colnames(tmp.data)[1], groupvars=colnames(tmp.data)[2:3], na.rm=TRUE, conf.interval=.95, .drop=TRUE)
	
	if(save=="network"){
			#theme for line graphs for network node visualizations
			.theme <- theme(
				#axis.line = element_line(colour = 'black', size = 2), 
				axis.line = element_blank(),
				axis.text.y = element_blank(),
				axis.ticks = element_blank(), 
				#axis.text.x = element_text(size = 80,vjust=20),
				axis.text.x = element_blank(),
				axis.title.x = element_blank(),	
				axis.title.y = element_blank(), 
				axis.ticks.length = unit(1, "lines"), 
				axis.ticks.margin = unit(.1, "lines"), 
				legend.position = "none", 
				panel.background = background, 
				panel.border = element_blank(), 
				panel.grid.major = element_blank(), 
				panel.grid.minor = element_blank(), 
				panel.margin = unit(c(1,.25,.25,.25), "lines"), 
				plot.background = element_blank(), 
				plot.margin = unit(c(.5,.25,.25,.25), "lines")
			)
		 } else {
		 #theme for line graphs for network node visualizations
		.theme<- theme(
				axis.line = element_line(colour = 'gray', size = 1), 
				axis.text.x =       element_text(size = text*.8 , lineheight = 0.9, colour = "grey50", vjust = 1),
				axis.text.y =       element_text(size = text*.8, lineheight = 0.9, colour = "grey50", hjust = 1),
				axis.ticks =        element_line(colour = "grey50"),
				axis.title.x =      element_text(size = text, vjust = 0.5),
				axis.title.y =      element_text(size = text, angle = 90, vjust = 0.5),
				panel.background = background, 
				plot.background = element_blank(),
				legend.position= legend
			 )	
		 }
	
	if (!is.null(color)) {other<-scale_colour_manual(values = color)} else { other <-NULL}
	
	# factors for aesthetics
	group<-factor(dfc[,1], levels=levels(group))
	breaks<-as.numeric(levels(as.factor(dfc[,2])))

	# plot
	if(save=="network"){ # hard coded polygon breaks fix later
		p<-ggplot(dfc, aes(x = as.numeric(as.character(time)), y = as.numeric(as.character(mean)), color = group)) + 
		geom_rect(aes(xmin=breaks[1], xmax=breaks[2], ymin=-Inf, ymax=Inf), fill='gray80', alpha=.1,linetype=0) +
		geom_rect(aes(xmin=breaks[3], xmax=breaks[4], ymin=-Inf, ymax=Inf), fill='gray80', alpha=.1,linetype=0) + # need to make dynamic
		geom_errorbar(aes(ymin=as.numeric(as.character(mean))-se, ymax=as.numeric(as.character(mean))+se), width = 0,size=1,alpha=alpha) +
		geom_line(size=1.5,alpha=alpha) +
		scale_x_continuous(breaks =breaks) + .theme + other
		
		#save to file to use as node images in network visualizations
		filename<-paste(tryCatch(colnames(variable), error=function(e){gsub(":","_",strsplit(as.character(unlist(Sys.time()))," ")[[1]][2])}),".png",sep="")
		png(file = filename,pointsize=1,width=60,height=60) # or 60 X 60 and 1 pt 
		print(p)
		dev.off()
	
	} else {
		p<-ggplot(dfc, aes(x = as.numeric(as.character(time)), y = as.numeric(as.character(mean)), color = group)) + 
					geom_errorbar(aes(ymin=as.numeric(as.character(mean))-se, ymax=as.numeric(as.character(mean))+se), width = size+1,size=size,alpha=alpha) +
					geom_line(size=size,alpha=alpha) +
					scale_x_continuous(breaks = breaks) +
					ylab(colnames(variable)) +
					xlab(xlab) + .theme + other
	}
			
	if(save==TRUE){
			filename<-paste(tryCatch(colnames(variable), error=function(e){gsub(":","_",strsplit(as.character(unlist(Sys.time()))," ")[[1]][2])}),".png",sep="")
			ggsave(filename,p)
		} 
	
	if(save==FALSE){ print(p)}


}

#calculate mean, sd, ci int should go in stats lost ref adaptaion from someone else 
summarySE <- function(data=NULL, measurevar, groupvars=NULL, na.rm=TRUE,
                      conf.interval=.95, .drop=TRUE) {
    require(plyr)

    # New version of length which can handle NA's: if na.rm==T, don't count them
    length2 <- function (x, na.rm=FALSE) {
        if (na.rm) sum(!is.na(x))
        else       length(x)
    }

    # This is does the summary; it's not easy to understand...
    datac <- ddply(data, groupvars, .drop=.drop,
                   .fun= function(xx, col, na.rm) {
                           c( N    = length2(xx[,col], na.rm=na.rm),
                              mean = mean   (as.numeric(as.matrix(xx[,col])), na.rm=na.rm),
                              sd   = sd     (xx[,col], na.rm=na.rm)
                              )
                          },
                    measurevar,
                    na.rm
             )

    # Rename the "mean" column    
    datac$se <- datac$sd / sqrt(datac$N)  # Calculate standard error of the mean

    # Confidence interval multiplier for standard error
    # Calculate t-statistic for confidence interval: 
    # e.g., if conf.interval is .95, use .975 (above/below), and use df=N-1
    ciMult <- qt(conf.interval/2 + .5, datac$N-1)
    datac$ci <- datac$se * ciMult
    return(datac)
}

#get ellipse boundaries
get.ellipse.coords<-function(obj,group=NULL, ellipse.level=.95){
		check.get.packages(c("ellipse","splancs"))
		
		fct<-if(is.null(group)) as.factor(rep(1,nrow(obj))) else as.factor(group)
		.obj<-split(as.data.frame(obj),fct)
		
		#calculate points for ellipse
		#for level of group
		ellipse.var<-lapply(1:nlevels(fct),function(i)
			{

				pts<-.obj[[i]]
				m<-colMeans(pts)
				cbind(tryCatch(ellipse(as.matrix(cov(pts)),centre=c(m[1],m[2]),level=ellipse.level),
					error=function(e){NA}),rep(levels(fct)[i],nrow(pts)))
			})
			
		#format for ggplot 2
		tmp<-do.call("rbind",ellipse.var)
		colnames(tmp)<-c("x","y","group")
		tmp[,1]<-as.numeric(tmp[,1])
		tmp[,2]<-as.numeric(tmp[,2])
		# get area for plotting order
		ellipse.size<-sapply(1:length(ellipse.var),function(i)
			{
				tryCatch(areapl(ellipse.var[[i]]),error=function(e){NA})
			})
		return(list(coords=data.frame(tmp), area=ellipse.size))	
	}		
	
#get polygon coordinates for each group
get.polygon.coords<-function(){ 			
		comps<-obj$total.LVs
		plot.obj<-tryCatch(obj$scores[[1]][,c(comp1,comp2)],error=function(e){obj$scores[,c(comp1,comp2)]}) # not sure how to simply unclass and coerce to data.frame
		
		#format data
		out<-as.data.frame(cbind(plot.obj[,c(comp1,comp2)],join.columns(as.matrix(groups))))
		colnames(out)<-c("LV1","LV2","groups")
			
		out[,1:2]<-as.numeric(as.matrix(out[,1:2]))	
		
		#calculate convex hull for polygons for each group
		data.obj <- split(out, as.factor(unlist(groups)))
		tmp.obj <- lapply(1:length(data.obj), function(i){
			obj<-data.obj[[i]]
			s2<-split(obj,obj[,3])
			do.call(rbind,lapply(1:length(s2),function(j){
				tmp<-s2[[j]]
				tmp[chull(tmp[,1:2]),] 
				}))
		})
		chull.boundaries <- do.call("rbind", tmp.obj)
	
		#custom theme
		.theme<- theme(
							axis.line = element_line(colour = 'gray', size = .75), 
							panel.background = element_blank(), 
							panel.border = element_rect(colour="gray",fill=NA),
							plot.background = element_blank()
						 )
						 
		#make plot
		p<-ggplot(data=out, aes(x=LV1, y=LV2, group=groups,color=groups)) + 
		geom_hline(aes(yintercept=0),color="gray60",linetype="dashed")+ 
		geom_vline(aes(xintercept=0),color=I("gray60"),linetype=2) 
		p<-p+geom_polygon(data=chull.boundaries,aes(x=LV1,y=LV2,fill=groups),alpha=.5) +geom_point(size=2)+.theme
		print(p)
}

#scatter plot matrix in ggplot2