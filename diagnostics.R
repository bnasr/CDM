rm(list = ls())
# graphics.off()

#load local functions
source('funcs.R')

set.seed(20190516)

sim <- simulate_data(sigma = 0, 
                     kappa = -40,
                     n =  100,
                     nd = 100, 
                     h_max = 1000)

# dev.off()
plot(sim$latents$h)

table(sim$table$onset)

onset = sim$table[,min(c(Inf,which(onset==1))), year]
onset
onset[,hist(V1, 20)]

model <- jags(model.file = 'model/onset-model.bugs', 
              data = sim$data,
              parameters.to.save = c('beta', 'kappa', 'Y_pred', 'h_max'), 
              n.chains = 1,
              n.iter = 400, 
              n.burnin = 100
              # inits = list(list(beta= c(0, .0)))
)



layout(matrix(c(1:4, 5,6), nrow = 2))
gibbs <- model$BUGSoutput$sims.list

hist(gibbs$beta[,1], 100, xlim = range(gibbs$beta[,1], sim$params$beta[1]))
abline(v = sim$params$beta[1], col = 'red', lwd = 2)
# plot(gibbs$beta[,1], ylim = range(gibbs$beta[,1], sim$params$beta[1]))
# abline(h = sim$params$beta[1], col = 'red', lwd = 2)

hist(gibbs$beta[,2], 100, xlim = range(gibbs$beta[,2], sim$params$beta[2]))
abline(v = sim$params$beta[2], col = 'red', lwd = 2)
# plot(gibbs$beta[,2], ylim = range(gibbs$beta[,2], sim$params$beta[2]))
# abline(h = sim$params$beta[2], col = 'red', lwd = 2)

hist(gibbs$beta[,3], 100, xlim = range(gibbs$beta[,3], sim$params$beta[3]))
abline(v = sim$params$beta[3], col = 'red', lwd = 2)
# plot(gibbs$beta[,3], ylim = range(gibbs$beta[,3], sim$params$beta[3]))
# abline(h = sim$params$beta[3], col = 'red', lwd = 2)

hist(gibbs$kappa, 100, xlim = range(gibbs$kappa, sim$params$kappa))
abline(v = sim$params$kappa, col = 'red', lwd = 2)
# plot(gibbs$kappa, ylim = range(gibbs$kappa, sim$params$kappa))
# abline(h = sim$params$kappa, col = 'red', lwd = 2)

hist(gibbs$h_max, 100, xlim = range(gibbs$h_max, sim$params$h_max))
abline(v = sim$params$h_max, col = 'red', lwd = 2)

# plot(colMeans(gibbs$h), sim$table$h)
# abline(0,1, col = 'red')
# R = cor(colMeans(gibbs$h), sim$table$h)
# mtext(paste('R² = ', signif(R^2, 3)), line = -2, adj = .1)

pred <- data.table(year = sim$table$year, 
                   Ypred = apply(gibbs$Y_pred, 2, median),
                   Y = sim$data$Y)

onset = pred[,.(onset_pred = min(c(Inf, which(Ypred==1))),
        onset = min(c(Inf, which(Y==1)))), year]

plot(onset$onset, onset$onset_pred)
abline(0,1, col = 'red')
R <- (onset[onset+onset_pred<Inf,cor(onset_pred, onset)])
mtext(paste('R² = ', signif(R^2,2)), line = -2, adj = .1)

