#!/usr/bin/env Rscript
args = commandArgs(trailingOnly=TRUE)

library(ggplot2)

if (length(args)<4) {
	stop("Usage: Rscript --vanilla visualize.R [method] [application] [input folder] [output folder].\n", call.=FALSE)
} 

method <- args[1]
application <- args[2]
dir_in <- args[3]
dir_out <- args[4]

# To create Fig. 3.3 and Fig. 3.4
#plot_type <- 1;
# To create Fig. 4.6x
# plot_type <- 2;
# To create Fig. 5.4x
plot_type <- 3;

# Warning, this should be lower than any value!! However, it should be the same for all plots or else it is hard to
# compare. I used -0.5 for the plots in chapter 3 and 4. While -0.1 for the plots in chapter 5.
lowest_value <- -0.5

if (application == 'line') {
	application_title <- 'Line estimation'
} else if (application == 'segment') {
	application_title <- 'Segment estimation'
} else if (application == 'cube') {
	application_title <- '3D cube estimation'
} else {
	application_title = "Unknown"
	print("Unknown application");
}

if (method == 'triadic') {
	method_title = "the Triadic MCMC sampler"
} else if (method == 'algorithm1') {
	method_title = "Neal's First Gibbs MCMC sampler"
} else if (method == 'algorithm2') {
	method_title = "Neal's Second Gibbs MCMC sampler"
} else if (method == 'algorithm8') {
	method_title = "the Auxiliary variable MCMC sampler"
} else if (method == 'jain-neal') {
	method_title = "the Jain/Neal Split-Merge MCMC sampler"
} else {
	method_title = "Unknown"
	print("Unknown method");
}

title <- paste(application_title, 'with', method_title, sep=" ");

wpath <- file.path(dir_in)

if (plot_type == 1) {
	# To create Fig. 3.3 and Fig. 3.4
	metrics=c('skip','ri.avg','ar.avg', 'mi.avg', 'hi.avg')
} else if (plot_type == 2) {
	# To create Fig. 4.6a and b
	metrics=c('skip','ri.avg','ar.avg', 'skip', 'hi.avg')
} else if (plot_type == 3) {
	metrics=c('purity','rand','adjusted_rand', 'mirkin', 'hubert')
	# Overwrite for this plot
	lowest_value <- -0.1
} else {
	print("Unknown plot type")
}

metric_names=c('Purity', 'Rand Index', 'Adjusted Rand Index', 'Mirkin Index', 'Hubert Index')

for (i in 1:length(metrics)) {

	fName <- paste0(metrics[i], ".txt")
	fFullname <- file.path(wpath, fName);

	if (file.exists(fFullname)) {
		print(paste("File:", fFullname, "loaded"))
		table <- read.table(fFullname, header=FALSE)
	} else {
		print(paste("File:", fFullname, "does not exist"))
		next
	}

	#purity <- read.table(file.path(wpath, 'purity.txt'), header=FALSE)
	#rand <- read.table(file.path(wpath, 'rand.txt'), header=FALSE)
	#adjusted_rand <- read.table(file.path(wpath, 'adjusted_rand.txt'), header=FALSE)

	if (exists('dataframe')) { #//&& is.dataframe.frame(get('dataframe'))) {
		dataframe[, metric_names[i]] <- table
	} else {
		dataframe <- data.frame(table)
		names(dataframe) <- c(metric_names[i])
	}
	#dataframe <- data.frame(
	#	purity,
	#	rand,
	#	adjusted_rand
	#)
	#names(dataframe) <- c("Purity", "Rand Index", "Adjusted Rand Index")
}

s <- summary(dataframe)
print(s)

if (min(dataframe) < lowest_value) {
	print(paste("Error: the minimum value", lowest_value, "is not low enough, should be lower than", min(dataframe)));
	quit();
}

dataframe.m <- reshape2::melt(dataframe, id.vars = NULL)

bold.text <- element_text(face = "bold")

pdf(NULL)

ggplot(dataframe.m, aes(x = variable, y = value)) + 
	geom_violin() + 
	ggtitle(title) +
	scale_x_discrete(name = "Clustering metric") + 
	scale_y_continuous(name = "Clustering performance", limits = c(lowest_value,1) ) +
	theme(title = bold.text, axis.title = bold.text) + 
	theme(plot.title = element_text(hjust = 0.5)) +
	geom_boxplot(width=.1, outlier.size=0) +
	stat_summary(fun.y=mean,shape=1,col='black',geom='point')

dir.create(file.path(dir_out), showWarnings = FALSE)
ggsave(file.path(dir_out, paste(method, "png", sep=".")))
