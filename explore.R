library(data.table)

load('data/h12v04_0002145419.rda')
dt <- data.table( site =1, tim)

load('data/h12v04_0002464709.rda')
dt <- rbind(dt, data.table( site =2, tim))

load('data/h12v04_0004997729.rda')
dt <- rbind(dt, data.table( site =3, tim))
rm(tim)

dt[,date:=as.Date(doy, 
                  origin = paste0(year, "-01-01"))]
dt[, plot(doy, evi2)]
dt[,onset:=NA]
dt[evi2>0.4,onset:=TRUE]
dt[evi2<0.4&doy<200,onset:=FALSE]

dt[,plot(doy, onset)]
dt[,intercept := 1]
dt[,tmean := (tmax + tmin)/2]

beta <- c(intercept=.1, tmean = 1, tmin = 0.2, dayl = 0.5)
sigma <- 0.1

dt <- dt[year!=2000]

X <- dt[,.(intercept, 
          tmean = scale(tmean), 
          tmin = scale(tmin), 
          dayl = scale(dayl))]

Y <- dt$onset*1

epsilon <- rnorm(n = nrow(X), mean = 0, sd = sigma)
dt[,dh0:=(exp(as.matrix(X)%*%beta)+ epsilon)]

fun <- function(dh0){
  h <- 0*dh0
  for(i in 1:(length(dh0)-1))  h[i+1] <- h[i] + dh0[i]*(1-h[i]/400)
  h
}

dt[,h:=fun(dh0),.(year,site)]

dt[site==1,plot(date, h)]
dt[site==2,plot(date, h)]
dt[site==3,plot(date, h)]

n <- nrow(dt)

kappa = -10
lambda = .5
plot(1/(1 + exp(-(kappa + lambda*dt[site==1&year==2017, h]))))

kappa = -20
lambda = .5
lines(1/(1 + exp(-(kappa + lambda*dt[site==1&year==2017, h]))))


kappa = -20
lambda = .1
lines(1/(1 + exp(-(kappa + lambda*dt[site==1&year==2017, h]))), col ='red')


# plot(rbinom(365, 1, 1/(1 + exp(-(kappa + lambda*dt[site==1&year==2017, h])))))

p <- 1/(1 + exp(-(kappa + lambda*dt$h)))
Y <- rbinom(n, 1, p)
# plot(Y, type = 'l')

library(rjags)

HeadNodes <- which(dt$doy==1)
MainNodes <- which(dt$doy!=1)
any(MainNodes%in%HeadNodes)

model <- jags.model(file = 'model/two-stage.bugs', 
                    data = list(Y = Y, 
                                X = X,
                                n = length(n),
                                np = ncol(X),
                                HeadNodes = HeadNodes,
                                MainNodes = MainNodes
                                ), 
                    # inits = list(kappa = -10),
                    # n.chains = 4,
                    # n.adapt = 1000,
                    quiet = FALSE
                    )

out <- coda.samples(model, 
                    # variable.names = c('kappa', 'lambda', 'beta', 'sigma', 'h'), 
                    variable.names = c('kappa', 'lambda', 'h'), 
                    n.iter = 1000)


# summary(out)
str(out)
n <- length(dt$h)
hist(as.numeric(out[[1]][,n+1]), 100) 
abline(v= kappa, col = 'red', lwd = 2)

hist(as.numeric(out[[1]][,n+2]), 100 )
abline(v= lambda, col = 'red', lwd = 2)

plot(as.numeric(out[[1]][,n+1]))
plot(as.numeric(out[[1]][,n+2]))

plot(apply(out[[1]], 2, mean)[1:n], cex =.01)
plot(apply(out[[1]], 2, mean)[1:n], dt$h)

cor(apply(out[[1]], 2, mean)[1:n], dt$h)

abline(0,1, col= 'red')
gelman.plot(out)

            






kappa = 10
lambda = -1
x <- seq(1, 400)
p <- 
  Y <- rbinom(n, 1, p)
plot(p)
library(manipulate)
manipulate(plot(x, 1/(1 + exp(-(k + l*x))), ylim = c(0,1)), 
           k=slider(-1000,0, initial = -100),  
           l=slider(0, 10, step = .01, initial = 1))
