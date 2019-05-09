con <- url("http://www4.stat.ncsu.edu/~reich/ABA/Code/gambia.RData")

load(con)

Y <- pos
n <- length(Y)
X <- as.matrix(X)

mle <- glm(Y~X,family="binomial")
summary(mle)

logistic_model <- "model{

   # Likelihood

   for(i in 1:n){
    Y[i] ~ dbern(q[i])
    logit(q[i]) <- beta[1] + beta[2]*X[i,1] + beta[3]*X[i,2] + 
                   beta[4]*X[i,3] + beta[5]*X[i,4] + beta[6]*X[i,5]
   }

   #Priors

   for(j in 1:6){
    beta[j] ~ dnorm(0,0.1)
   }

  }"


library(rjags)

dat   <- list(Y=Y,n=n,X=X)
model <- jags.model(textConnection(logistic_model),data = dat,n.chains=3, quiet=FALSE)

update(model, 10000, progress.bar="none")

samp <- coda.samples(model, 
                     variable.names=c("beta"), 
                     n.iter=100, progress.bar="none")
