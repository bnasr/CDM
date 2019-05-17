rm(list = ls())
graphics.off()

#load local functions
source('funcs.R')

set.seed(20190516)

sim <- simulate_data(sigma = 0, kappa = -50)

graphics.off()

plot(sim$latents$h)

table(sim$table$onset)

sim$table[,min(which(onset==1)), year][,hist(V1, 50)]

model <- jags(model.file = 'model/onset-model.bugs', 
              data = sim$data,
              parameters.to.save = c('beta', 'h'), 
              n.chains = 1,
              n.iter = 2000, 
              n.burnin = 500
              # inits = list(list(beta= c(0, .0)))
)

layout(matrix(c(1,2,3,4,5,6, 7,7), nrow = 2))
gibbs_beta <- model$BUGSoutput$sims.list$beta

hist(gibbs_beta[,1], 100, xlim = range(gibbs_beta[,1], sim$params$beta[1]))
abline(v = sim$params$beta[1], col = 'red', lwd = 2)
plot(model$BUGSoutput$sims.list$beta[,1], ylim = range(gibbs_beta[,1], sim$params$beta[1]))
abline(h = sim$params$beta[1], col = 'red', lwd = 2)

hist(model$BUGSoutput$sims.list$beta[,2], 100, xlim = range(gibbs_beta[,2], sim$params$beta[2]))
abline(v = sim$params$beta[2], col = 'red', lwd = 2)
plot(model$BUGSoutput$sims.list$beta[,2], ylim = range(gibbs_beta[,2], sim$params$beta[2]))
abline(h = sim$params$beta[2], col = 'red', lwd = 2)

hist(model$BUGSoutput$sims.list$beta[,3], 100, xlim = range(gibbs_beta[,3], sim$params$beta[3]))
abline(v = sim$params$beta[3], col = 'red', lwd = 2)
plot(model$BUGSoutput$sims.list$beta[,3], ylim = range(gibbs_beta[,3], sim$params$beta[3]))
abline(h = sim$params$beta[3], col = 'red', lwd = 2)

plot(colMeans(model$BUGSoutput$sims.list$h), sim$table$h)
abline(0,1, col = 'red')



