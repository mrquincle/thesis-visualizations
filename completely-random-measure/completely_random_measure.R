library(plot3D)
library(rgl)
library(spatstat)

if (!(exists("plot_to_file"))) {
	plot_to_file = 0
}

beta_process <- 0
gamma_process <- 1

high_resolution <- 1

process <- beta_process
process <- gamma_process

w_scale = 1

if (high_resolution) {
	w_resolution = 200
} 

if (process == gamma_process) {
	w_scale = 2
	w_resolution <- w_resolution * 4
} 

if (!(exists("w_resolution"))) {
	w_resolution = 40
}

if (!(exists("t_resolution"))) {
	t_resolution = 10
}

w <- seq(0.02, 0.98 * w_scale, length.out = w_resolution)
t <- seq(0, 100, length.out = t_resolution)

if (process == beta_process) {

	# An improper beta distribution
	alpha <- 10
	intenfun <- function(x,y) alpha * x^-1 * (1 - x)^(alpha - 1)
	lmax <- 50
	title = "The Beta Process as a Completely Random Measure\n with an improper beta distribution"
	w_title = "Improper beta distribution"
	filename = 'crm_beta.png'
	win <- as.owin(c(0,1,0,100))
} else if (process == gamma_process) {

	# An improper gamma distribution
	alpha <- 1
	intenfun <- function(x,y) x^(-1) * exp(-alpha * x) 
	lmax <- 50 
	title = "The Gamma Process as a Completely Random Measure\n with an improper gamma distribution"
	w_title = "Improper gamma distribution"
	filename = 'crm_gamma.png'
	win <- as.owin(c(0,2,0,100))
}

nu <- intenfun(w)
nu_grid <- matrix(rep(nu, 10), nrow = w_resolution, ncol = t_resolution)

# The point we sample first uniformly. Then 

#density <- 40
density <- 0.1
lmax <- lmax * density
densfun <- function(x,y) density * intenfun(x,y)

# Generate poisson process from the function "intenfun"
xy_ppp <- rpoispp(densfun, lmax, win)
xy <- coords(xy_ppp)
x <- xy$x
y <- xy$y 
z <- replicate(length(x), 0)

# Only plot to file when plot_to_file evaluates true.
if (plot_to_file) {
	png(filename, 640, 480)
}

# Compare figure with Hierarchical Models, Nested Models and Completely Random Measures (2012) Jordan
# See: https://bit.ly/2HjVgBl 
# The parameter eta is the rate measure for the (homogenous) poisson process.
# The color used in thesis is "burgundy", which is defined as 0.647,0.129,0.149.
# The scatter3D plot is from the plot3D package by Soetaert 
# See: https://cran.r-project.org/web/packages/plot3D/plot3D.pdf
scatter3D(x, y, z, 
	pch = 19, 
	cex = 1, 
    theta = -40, phi = 20,
	ticktype = "detailed", 
	colkey = FALSE, 
	xlim = c(0,1 * w_scale),
	ylim = c(0,100),
	zlim = c(0,50),
	col = ramp.col(c(rgb(0.647, .129, .149, 0), rgb(0, 0, 0))),
	colvar = x,
	#clim = c(0, 1),
    xlab = w_title, ylab = "Uniform distribution", zlab = "Levy intensity", bty = "g",
    surf = list(x = w, y = t, z = nu_grid, 
	colvar = nu_grid,
	clim = c(50, 0),
	alpha = 0.5,
    facets = TRUE), 
	main = title)

if (plot_to_file) {
	dev.off()
}

