#!/usr/bin/Rscript

# Workaround to allow calling from R (interactively) as well as from command line
if(!exists("vargs")) {
	vargs = commandArgs(trailingOnly=TRUE)
} 

# Make sure the data is properly formatted.
# It should be separated by tabs. It should start with non-white space.
# It should have four columns, x, y, z, and class
# The last column will be used for coloring

# Regretfully, ggplot cannot be used to visualize 3D scatter plots
separator <- '\t'

# See for the package details
# http://www.sthda.com/english/wiki/impressive-package-for-3d-and-4d-graph-r-software-and-data-visualization

library(plot3D)
library(rgl)
library(plot3Drgl)

if (length(vargs) < 2) {
	stop("\n\nUsage:\t./display_cube.R <input file> <output folder>\n\nor\n\tR> vargs=c(<input file>,<output folder>)\n\tR> source('display_cube.R')", call.=FALSE)
} 

source("../util/read.octave.R")
	
file_in <- vargs[1]
dir_out <- vargs[2]

interactive <- FALSE
if (length(vargs) > 2 && vargs[3] == 'interactive') {
	interactive <- TRUE
}

bname <- basename(file_in)

datapoints <- read.table(file_in, sep=separator)

dataframe <- data.frame(
	datapoints
)

if (!interactive) {
	filename <- paste(dir_out, "/", "original_", bname, ".pdf", sep="")
	dir.create(file.path(dir_out), showWarnings = FALSE)
	pdf(filename)
	par(mar=c(0,0,0,0))
}

N <- nrow(dataframe)
print(N)

x <- dataframe$V1
y <- dataframe$V2
z <- dataframe$V3
if (ncol(dataframe) > 3) {
	color <- dataframe$V4
} else {
	color <- rep(2, N);
}

# add xlim, ylim, and zlim
dx <- max(x) - min(x)
dy <- max(y) - min(y)
dz <- max(z) - min(z)

dT <- max(dx, dy, dz)

# Overwrite
dT <- 10

dxmid <- min(x) + dx/2
dymid <- min(y) + dy/2
dzmid <- min(z) + dz/2

dxmid <- 0
dymid <- 0
dzmid <- 0

xlim <- c(dxmid-dT/2,dxmid+dT/2)
ylim <- c(dymid-dT/2,dymid+dT/2)
zlim <- c(dzmid-dT/2,dzmid+dT/2)


# byt="g" gives gray background with white grid lines
# pch is point shape, cex is point size
# colkey = FALSE removes legend
# theta and phi are viewing angles (default is 40 for both, theta rotates from right to left, phi from bottom to top)
# with theta = 60 we look more at the right side, with phi = 25 we look less from the top
# main = "Title"
scatter3D(x, y, z, xlim = xlim, ylim = ylim, zlim = zlim, colvar=color, colkey = FALSE, theta = 60, phi = 25, bty = "g", pch = 20, cex = 0.5, col = gg.col(N))
#scatter3D(x, y, z, colvar=color, colkey = FALSE, theta = 60, phi = 0, bty = "g", pch = 20, cex = 1)

if (!interactive) {
	invisible(dev.off())
	cat("Written to \"", filename, "\"\n", sep="")
} else {
	# Make the rgl version
	library("plot3Drgl")
	plotrgl()
}
