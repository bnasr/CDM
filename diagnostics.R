rm(list = ls())
graphics.off()

library(data.table)

#load local functions
source('funcs.R')

# simulate data

beta = matrix(c(1, 3))
sigma <- 0.01

n = 50 # number of phenological cycles
nd = 100 # number of days in each cycle
# h_onset <- 50
kappa = -40
lambda = 1


data = data.table(year = rep(1:n, each = nd), 
                  doy = rep(1:nd, times = n))

# set.seed(1)

data[, temp := simulate_temp(doy, 
                             tmin = runif(-5, 0, n = 1), 
                             tmax = runif(20, 40, n = 1)), year]

# data[,plot(temp)]

data[doy==1,h:=0, ]

epsilon <- rnorm( n = nrow(data), mean = 0, sd = sigma)
X <- as.matrix(data[,.(1, temp)])
dh=exp(X%*%beta) + epsilon
dh = X%*%beta 
dh[dh<0] <- 0
data$dh <- dh

data[,h:=cumsum(dh), year]

data[year==1,plot(h),]

library(boot)
data[,p:=inv.logit(kappa + lambda*h)]

data[,onset:=rbinom(n = .N, size = 1, prob = p)]

# data[,onset:=(h>h_onset)*1]
data$onset
data[,min(which(onset==1)), year]
data[,min(which(onset==1)), year][,hist(V1)]
Y = data$onset

library(R2jags)

model <- jags(model.file = 'model/onset-model.bugs', 
             data = list(Y = Y, 
                         X = X, 
                         kappa = kappa, 
                         lambda = lambda,
                         np = ncol(X), 
                         # h_onset = h_onset,
                         n = length(Y),
                         HeadNodes = which(data$doy==1),
                         MainNodes = which(data$doy!=1)),
             parameters.to.save = c('beta', 'h'), 
             n.chains = 1,
             n.iter = 4000, 
             n.burnin = 1000
             # inits = list(list(beta= c(0, .0)))
             )

layout(matrix(c(1,2,3,4,5,5), nrow = 2))
gibbs_beta <- model$BUGSoutput$sims.list$beta

hist(gibbs_beta[,1], 100, xlim = range(gibbs_beta[,1], beta[1]))
abline(v = beta[1], col = 'red', lwd = 2)
plot(model$BUGSoutput$sims.list$beta[,1], ylim = range(gibbs_beta[,1], beta[1]))
abline(h = beta[1], col = 'red', lwd = 2)

hist(model$BUGSoutput$sims.list$beta[,2], 100, xlim = range(gibbs_beta[,2], beta[2]))
abline(v = beta[2], col = 'red', lwd = 2)
plot(model$BUGSoutput$sims.list$beta[,2], ylim = range(gibbs_beta[,2], beta[2]))
abline(h = beta[2], col = 'red', lwd = 2)

plot(colMeans(model$BUGSoutput$sims.list$h), data$h)
abline(0,1, col = 'red')



