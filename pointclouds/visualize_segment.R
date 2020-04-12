#!/usr/bin/env Rscript
args = commandArgs(trailingOnly=TRUE)

# Make sure the data is properly formatted.
# It should be separated by tabs. It should start with non-white space.
# It should have three columns, x, y and class
# The last column will be used for coloring

separator <- '\t'

library(ggplot2)
source("../util/read.octave.R")

if (length(args) < 2) {
	stop("Usage: Rscript --vanilla visualize_input.R [input pnts] [input segments] [output folder].\n", call.=FALSE)
} 
	
pnts_in <- args[1]
segments_in <- args[2]
dir_out <- args[3]

bname <- basename(pnts_in)

datapoints <- read.table(pnts_in, sep=separator)

df1 <- data.frame(
	datapoints
)

linepoints <- read.table(segments_in, sep=separator)

df2 <- data.frame(
	linepoints
)

print(df2)

pdf(NULL)

p <- ggplot(NULL, aes(x=V1, y=V2, color=factor(V3))) + 
	geom_point(data=df1) + xlab("") + ylab("") + 
	theme(legend.position="none") +
	geom_line(data=df2) + coord_cartesian(xlim=c(-10,10), ylim=c(-10,10))

bold.text <- element_text(face = "bold")

dir.create(file.path(dir_out), showWarnings = FALSE)
ggsave(file.path(dir_out, paste("original_", bname, ".png", sep="")))
