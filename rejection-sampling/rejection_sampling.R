#library(plot3D)
library(rgl)
library(ggplot2)

if (!(exists("plot_to_file"))) {
	plot_to_file = 0
}

# A gaussian function (mu, sigma)
gaussf = function(x, mu, sigma) 1/(sqrt(2*pi)*sigma) * exp(-1/2*((x-mu)/sigma)^2)

# An absolute sine wave with f as frequency
abssinef = function(x, f) abs(sin(x*f))

# Create a "complicated" function
complicatedf = function(x) gaussf(x, 1, 1) * abssinef(x, 3)

x <- seq(-5, 5, length.out = 1000)

N=1000000
set.seed(1234)

# Sample from gaussian with (mu,sigma) = (1,1)
samp <- rnorm(N, 1, 1)

# Sample from uniform distribution 
threshold <- runif(N, 0, 1)

M <- 1

accept <- subset(samp, threshold < (complicatedf(samp) / (M * (gaussf(samp, 1, 1) ) )))
#accept <- subset(samp, threshold < complicatedf(samp) )

y0 <- complicatedf(x)

y1 <- gaussf(x,1,1)

df <- data.frame(x, y0, y1)

df1 <- data.frame(accept)

filename = 'rejection_sampling.png'

if (plot_to_file) {
	png(filename, 640, 480)
}
#pdf(NULL)
burgundy=rgb(0.647, .129, .149)

gg <- ggplot(df, aes(x=x)) + geom_line(aes(y=y0), size=1) + geom_line(aes(y=y1), color=burgundy, size=1) + 
	geom_histogram(data=df1, aes(x=accept, y=6*..count../sum(..count..)), binwidth=0.05) + xlab(NULL) + ylab(NULL)

plot(gg)

if (plot_to_file) {
	dev.off()
}
