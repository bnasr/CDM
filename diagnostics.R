rm(list = ls())
# graphics.off()

#load local functions
source('funcs.R')

set.seed(20190516)

sim <- simulate_data(sigma = 0, 
                     kappa = -20, 
                     nd = 200, 
                     h_max = 50)

graphics.off()

plot(sim$latents$h)

table(sim$table$onset)

sim$table[,min(which(onset==1)), year][,hist(V1, 50)]

model <- jags(model.file = 'model/onset-model.bugs', 
              data = sim$data,
              parameters.to.save = c('beta', 'h', 'kappa', 'lambda'), 
              n.chains = 1,
              n.iter = 1000, 
              n.burnin = 500
              # inits = list(list(beta= c(0, .0)))
)

layout(matrix(c(1:9, 9), nrow = 2))
gibbs <- model$BUGSoutput$sims.list

hist(gibbs$beta[,1], 100, xlim = range(gibbs$beta[,1], sim$params$beta[1]))
abline(v = sim$params$beta[1], col = 'red', lwd = 2)
plot(gibbs$beta[,1], ylim = range(gibbs$beta[,1], sim$params$beta[1]))
abline(h = sim$params$beta[1], col = 'red', lwd = 2)

hist(gibbs$beta[,2], 100, xlim = range(gibbs$beta[,2], sim$params$beta[2]))
abline(v = sim$params$beta[2], col = 'red', lwd = 2)
plot(gibbs$beta[,2], ylim = range(gibbs$beta[,2], sim$params$beta[2]))
abline(h = sim$params$beta[2], col = 'red', lwd = 2)

hist(gibbs$beta[,3], 100, xlim = range(gibbs$beta[,3], sim$params$beta[3]))
abline(v = sim$params$beta[3], col = 'red', lwd = 2)
plot(gibbs$beta[,3], ylim = range(gibbs$beta[,3], sim$params$beta[3]))
abline(h = sim$params$beta[3], col = 'red', lwd = 2)

hist(gibbs$kappa, 100, xlim = range(gibbs$kappa, sim$params$kappa))
abline(v = sim$params$kappa, col = 'red', lwd = 2)
plot(gibbs$kappa, ylim = range(gibbs$kappa, sim$params$kappa))
abline(h = sim$params$kappa, col = 'red', lwd = 2)


plot(colMeans(gibbs$h), sim$table$h)
abline(0,1, col = 'red')



