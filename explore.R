load('data/h12v04_0002145419.rda')
# load('data/h12v04_0002464709.rda')
# load('data/h12v04_0004997729.rda')

hist(rbinom(1000,size = 1, prob = 0.5))
hist(rmultinom(1000,size = 1, prob = c(0.2, 0.8))[2,])

