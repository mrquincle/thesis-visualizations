#!/usr/bin/env Rscript
args = commandArgs(trailingOnly=TRUE)

# This script expects a directory with multiple "resultK.txt" files. For each cluster K a separate file is created.
# The general "results.txt" file contains information on how large K is and what the parameters are of the discovered
# entities (clusters, lines).

# This file was first only meant for lines. It now can visualize clusters as well. However, the gaussian mixture model

# I have not actualy experimented with. I assumed the K matrices that come out of it where indications of the
# 2D variance of the corresponding Gaussians. I might be wrong though...

# Packages can be installed by running R on the CLI:
# R>
# R> install.packages("ggforce")

library(ggplot2)
library(ggforce)

thisPath <- function() {
        cmdArgs <- commandArgs(trailingOnly = FALSE)
        needle <- "--file="
        match <- grep(needle, cmdArgs)
		#cat(cmdArgs, sep = "\n")
        if (length(match) > 0) {
                # Rscript
                thisFile <- normalizePath(sub(needle, "", cmdArgs[match]))
        } else {
                # sourced via R console
                thisFile <- normalizePath(sys.frames()[[1]]$ofile)
        }
		return(dirname(thisFile))
}
path <- thisPath();

source(file.path(path, "../util/read.octave.R"))

if (length(args) < 3) {
	stop("Usage: Rscript --vanilla visualize_single_fit.R <input folder> <output folder> <clustering|regression>.\n", call.=FALSE)
} 

dir_in <- args[1]
dir_out <- args[2]

method <- args[3]

if (method == 'regression') {
} else if (method == 'clustering') {

} else {
	stop("Unkown method.\n", call.=FALSE);
}

bname <- basename(dir_in)
wpath <- file.path(dir_in)

results <- read.octave(file.path(wpath, 'results.txt'), options.skip_line=0)

dataframe <- data.frame(
	results
)

# Obtain the means (mu) of each cluster
mu <- data.matrix( dataframe[c(1,2)] )

# Obtain the number of clusters (from the # rows of mu)
K <- nrow(mu)

if (method == 'clustering') {
	# Needs to be transformed to K objects of size 2x2
	sigma_ext <- data.matrix( dataframe[(1:2),-(1:2)] )
	dim(sigma_ext) <- c(2,2,K)
	sigma <- sigma_ext[1,1,]
}

# Let index iterate over all clusters
index <- 1:K

# Get all data points from 1 to K from the individual "resultsK.txt" files
datalist = list()
for (i in index) {
	j <- i - 1
	fname = paste('results', j, '.txt', sep='')
	dat <- read.table(file.path(wpath, fname))
	dat$index <- i
	datalist[[i]] <- dat
}

ldata = do.call(rbind, datalist)
#print(ldata)

if (method == 'regression') {

	mu_df <- data.frame ( 
		mu,
		index
	)
}

if (method == 'clustering') {

	mu_df <- data.frame ( 
		mu,
		index,
		sigma
	)
}

if (method == 'regression') {
	names(mu_df) <- c("intercept", "slope")
} 

if (method == 'clustering') {
	names(mu_df) <- c("x", "y", "class", "sigma")
}
print(mu_df)

pdf(NULL)

if (method == 'regression') {
	p <- ggplot(data=ldata, aes(x=V2, y=V3, color=factor(index))) + 
		geom_point() + xlab("") + ylab("") + 
		theme(legend.position="none") + 
		geom_abline(data=mu_df, aes(intercept=intercept, slope=slope, color=factor(index)))
}
	
if (method == 'clustering') {
	p <- ggplot(NULL) + #, aes(x=V1, y=V2, color=factor(index))) + 
		geom_point(data=ldata, aes(x=V1, y=V2, color=factor(index))) + xlab("") + ylab("") + 
		theme(legend.position="none") + 
		geom_circle(aes(x0=x,y0=y,r=sigma,color=factor(index)), data=mu_df) +
		coord_fixed()
}

bold.text <- element_text(face = "bold")

dir.create(file.path(dir_out), showWarnings = FALSE)
ggsave(file.path(dir_out, paste("fit_", bname, ".png", sep="")))
