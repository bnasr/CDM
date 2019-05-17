library(data.table)

library(boot) # for inverse logit function

library(R2jags)

simulate_met <- function(doy = 1:365, 
                         min = -10, 
                         max = 35, 
                         phase = 0.5){
  nd <- length(doy)
  
  met <- 
    sin(
      (doy + runif(nd, -20, 20))/365*2*pi*runif(nd, 0.9, 1.05)
      -
        phase*pi*runif(nd, 0.8, 1.2)
    )*
    (max*runif(nd, 0.8, 1.2) - min*runif(nd, 0.8, 1.2))/2 + 
    (max*runif(nd, 0.8, 1.2) + min*runif(nd, 0.8, 1.2))/2
  
  met
}


# simulate data
simulate_data <- function(
  h_max = 100,
  beta = matrix(c(1, 3, 0.5)),  # vector of coefficients
  sigma = 0.01, #process error
  n = 50, # number of phenological cycles
  nd = 100, # number of days in each cycle
  kappa = -40, # logit control parameters 1
  lambda = 1 # logit contol parameters 2
){
  data = data.table(year = rep(1:n, each = nd), 
                    day = rep(1:nd, times = n))
  
  data[, temp := simulate_met(day, 
                              phase = 0.75,
                              min = runif(-5, 0, n = 1), 
                              max = runif(20, 40, n = 1)), year]
  
  data[, solar := simulate_met(day, 
                               phase = 0.5,
                               min = runif(100, 200, n = 1), 
                               max = runif(500, 600, n = 1)), year]
  
  data[day==1,h:=0, ]
  
  epsilon = rnorm( n = nrow(data), mean = 0, sd = sigma)
  
  X = as.matrix(data[,.(1, scale(temp), scale(solar))])
  
  # dh = exp(X%*%beta) + epsilon
  
  dh = X%*%beta 
  
  dh[dh<0] <- 0
  
  data$dh <- dh
  
  f <- function(dh){
    h <- dh*0
    for(i in 2:length(dh))
      h[i] <- h[i-1] + dh[i-1]*(1 - h[i-1]/h_max)
    h
  }
  
  data[,h:=f(dh), year]  
  
  
  data[,p:=inv.logit(kappa + lambda*h)]
  
  data[,onset:=rbinom(n = .N, size = 1, prob = p)]
  
  Y = data$onset
  
  head_nodes = which(data$day==1)
  
  main_nodes = which(data$day!=1)
  
  sim <- list(
    params = list(
      sigma = sigma,
      beta = beta,
      # lambda = lambda,
      kappa = kappa
    ),
    
    latents = list(
      dh = data$dh,
      h = data$h
    ),
    
    table = data,
    
    data = list(
      X = X, 
      Y = Y,
      h_max = h_max,
      np = ncol(X),
      n = length(Y),
      # lambda = 1,
      main_nodes = main_nodes,
      head_nodes = head_nodes)
  )
}