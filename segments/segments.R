library(stats)
library(ggplot2)
#library(PtProcess)
library(LaplacesDemon)
library(mvtnorm)

polya_urn_model = function(base_distribution, num_draws, alpha) {
	draws <- list()

	k <- 0
	for (i in 1:num_draws) {
		if (runif(1) < alpha / (alpha + length(draws))) {
			new_draw <- base_distribution()
			new_draw$index <- k
			k <- k + 1
			draws[[i]] <- new_draw
		} else {
			old_draw <- draws[[sample(1:length(draws), 1)]]
			draws[[i]] <- old_draw
		}
	}

	draws
}

base_distribution = function() {
	# for shift on x-axis
	mu0 <- 0
	lambda <- 1
	S <- 0.05
	nu <- 4
	result <- rnorminvwishart(n=1, mu0, lambda, S, nu)

	alpha <- 3
	a <- rpareto(n=1, alpha) 
	result$a <- -a
	a <- rpareto(n=1, alpha) 
	result$b <- a

	# make nu one dimensional noise parameter on line
	a <- 10
	b <- 0.1 # spread in size
	Lambda <- 0.002 # should actually be a full matrix..., now simplified to scalar
	mu1 <- c(0,0)
	sigma2 <- rinvgamma(n=1, a, b)
	D <- diag(sigma2 / Lambda, length(mu1))
	nu <- rmvnorm(n=1, mu1, D)
	result$nu <- nu
	result$sigma <- sqrt(sigma2)
	result
}

N <- 1000

alpha <- 1
draws <- polya_urn_model(base_distribution, N, alpha)

NN <- N*2 + N

x <- integer(NN)
y <- integer(NN)
label <- integer(NN)
dotsize <- integer(NN)

j <- 0
for (i in 1:N) {
	hyper <- draws[[i]]

	shift <- hyper$mu
	beta <- hyper$nu
	sigma <- hyper$sigma

	# should come from prior
	a <- hyper$a + shift
	b <- hyper$b + shift

	xj <- a
	xjj <- append(xj, 1, 0)
	yj <- xjj %*% t(beta)
	
	j <- j + 1
	x[j] <- xj
	y[j] <- yj
	label[j] <- hyper$index
	dotsize[j] <- 2

	xj <- b
	print(xj)
	xjj <- append(xj, 1, 0)
	yj <- xjj %*% t(beta)
	
	j <- j + 1
	x[j] <- xj
	y[j] <- yj
	label[j] <- hyper$index
	dotsize[j] <- 2

	xj <- runif(1, a, b)
	xjj <- append(xj, 1, 0)
	yj <- rnorm(1, xjj %*% t(beta), sigma)

	j <- j + 1
	x[j] <- xj
	y[j] <- yj
	label[j] <- hyper$index
	dotsize[j] <- 1
}

dataframe <- data.frame(x, y, label, dotsize)

# label should be treated as a categorical variable (a factor)
dataframe$label <- as.factor(dataframe$label)
#dataframe$dotsize <- as.factor(dataframe$dotsize)

file <- paste("segment", ".png", sep="")
pdf(NULL)

yl=c(-20,20)
xl=c(-20,20)

p <- ggplot(dataframe, aes(x, y, colour=label, palette=3)) + geom_point(aes(size=dotsize)) + 
	theme(legend.position="none") +
#	xlim(xl) + ylim(yl) + 
	ylab(NULL) +
	scale_size_continuous(range = c(1, 2))

ggsave(file)

dev.off()
