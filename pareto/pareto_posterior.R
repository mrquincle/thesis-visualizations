library(stats)
library(ggplot2)
library(PtProcess)

N=100;
	
# generate all data points at once and select subset later on
u <- runif(N, min=-4, max=2) 

plot_n = c(1, 3, 10, 100)

for (n in 1:N) {
	# data points till now
	up <- u[1:n]

	shape=5;

	lambda=0.01;

	m=max(up)

	lenR=max(m,lambda);

	x_right <- rpareto(1, lambda=shape+n, a=lenR) 
	
	lambdaL=0.01;
	mL=max(-up)
	lenL=max(mL,lambdaL);
	
	x_left <- -rpareto(1, lambda=shape+n, a=lenL) 

	x <- c(x_left, x_right)

	if (is.element(n, plot_n)) {

		file <- paste("pareto_posterior_", n, ".png", sep="")
		pdf(NULL)

		xl=c(-5,5)

		endpoints <- integer(length(x)) 
		data <- integer(n) + 10
		
		label <- c(data, endpoints)

		y <- integer(n + length(x))

		x <- c(up, x)

		dataframe <- data.frame(x, y, label)

		# label should be treated as a categorical variable (a factor)
		dataframe$label <- as.factor(dataframe$label)

		p <- ggplot(dataframe, aes(x, y, colour=label, palette=3)) + geom_point(size = 3) + 
			theme(legend.position="none", axis.text.y=element_blank()) +
			xlim(xl) + ylab(NULL)

		ggsave(file)

		dev.off()
	}

}

