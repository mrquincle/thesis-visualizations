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
	stop("Usage: Rscript --vanilla visualize_input.R [input file] [output folder].\n", call.=FALSE)
} 
	
file_in <- args[1]
dir_out <- args[2]

bname <- basename(file_in)

datapoints <- read.table(file_in, sep=separator)

dataframe <- data.frame(
	datapoints
)

pdf(NULL)

p <- ggplot(data=dataframe, aes(x=V1, y=V2, color=factor(V3))) + 
	geom_point() + xlab("") + ylab("") +
	theme(legend.position="none") 

bold.text <- element_text(face = "bold")

dir.create(file.path(dir_out), showWarnings = FALSE)
ggsave(file.path(dir_out, paste("original_", bname, ".png", sep="")))
