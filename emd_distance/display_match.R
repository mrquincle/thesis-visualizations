#!/usr/bin/env Rscript
args = commandArgs(trailingOnly=TRUE)

# Make sure the data is properly formatted.
# It should be separated by tabs. It should start with non-white space.
# It should have three columns, x, y and class
# The last column will be used for coloring

separator <- ','
space_separator <- ' '

if (length(args) < 4) {
	stop("Usage: Rscript --vanilla visualize_input.R <cloud 1> <cloud 2> <match> <output folder>.\n", call.=FALSE)
} 

library(ggplot2)
library(doBy)

source("read.octave.R")
	
cloud1 <- args[1]
cloud2 <- args[2]
match  <- args[3]
dir_out <- args[4]

bname <- basename(match)

# Read table creates dataframes
datapoints1 <- read.table(cloud1, sep=separator)
datapoints2 <- read.table(cloud2, sep=separator)

datamatch <- read.table(match, sep=space_separator)

# Append the dataframe with a column with ones
dataframe1 <- data.frame(
	datapoints1, 0
)
names(dataframe1) <- c("x","y","index")

# Append the dataframe with a column with twos
dataframe2 <- data.frame(
	datapoints2, 1
)
names(dataframe2) <- c("x","y","index")

# Create a frame where every point in a separate row and where index indices which cluster it corresponds with
dataframe <- rbind(dataframe1, dataframe2)

#print(head(dataframe,n=10))

matchframe <- data.frame(
	datamatch
)

# Remove latest entry from each value (probably space delimiting takes end of line such that NA is in there at the end)
matchframe <- matchframe[,1:(length(matchframe)-1)]

# Create new data frame with single vector
matchframe <- unlist(matchframe)

nc <- ncol(matchframe)

# Make into array 
matchframe <- data.frame(
	matchframe
)
#matchframe <- array(matchframe)

# R version of meshgrid (pairwise combinations of datapoints with datapoints2)
product=merge(datapoints1, datapoints2, by=NULL);

class(product)
class(matchframe)
fframe <- cbind(product, matchframe)

names(fframe) <- c("x0", "y0", "x1", "y1", "weight");

# Make sure the colors are in the same "scale" as the indices in the dataframe (from 0 to 1)
fframe$color <- fframe$weight

top_n <- 100

fmax <- data.frame ( 
	fframe[which.maxn(fframe$weight, n=top_n),]
)

head(fmax$color,n=top_n)

pdf(NULL)

p <- ggplot() +
	geom_point(data=dataframe, aes(x=x, y=y, color=index)) + 
	coord_fixed() + 
	xlab("") + ylab("") +
	theme(legend.position="none") +
	geom_segment(aes(x=x0, y=y0, xend = x1, yend = y1, color=color), data = fmax) #+
#	scale_fill_gradient(low="blue", high="red")

bold.text <- element_text(face = "bold")


dir.create(file.path(dir_out), showWarnings = FALSE)
ggsave(file.path(dir_out, paste(bname, ".png", sep="")))
