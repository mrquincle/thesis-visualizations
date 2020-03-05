library(PtProcess)

# In R lambda is the shape parameter. On wikipedia this is the range parameter. 
# We call the shape parameter "shape" and the range parameter(s) "len?".
shape <- 5
len0 <- 2
len1 <- -4

# Calculate center point... and then deviation w.r.t. center point
shift <- mean(c(len0,len1))
len <- shift - len1

histogram_granularity=200

xp <- rpareto(1000, lambda=shape, a=len) 
xn <- rpareto(1000, lambda=shape, a=len) 
x  <- c(xp+shift, -xn+shift)
x0 <- seq(min(x)-0.1, max(x)+0.1, length=histogram_granularity)

# Use png devices
png("pareto_pair.png", 640, 480)

#xlim=range(x0)
xl=c(-12,12)
hist(x, freq=FALSE, breaks=x0, xlim=xl, xlab="x", ylab="p(x)",
	      main="Pareto pair distribution and histogram")

x0p <- seq(min(xp), max(xp)+0.1, length=200)
y0p = dpareto(x0p, lambda=shape, a=len) 

x0n <- seq(min(xn), max(xn)+0.1, length=200)
y0n = dpareto(x0n, lambda=shape, a=len) 

x1 <- seq(len1, len0, length=200)
y1 <- numeric(length(x1))

xx=c(rev(-x0n+shift),x1,x0p+shift)
yy=c(rev(y0n),y1,y0p)

points(xx, yy, type="l", col="red")

dev.off()
