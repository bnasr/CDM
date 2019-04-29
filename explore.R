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

X <- dt[,.(intercept, 
          tmean = scale(tmean), 
          tmin = scale(tmin), 
          dayl = scale(dayl))]

Y <- dt$onset*1

epsilon <- rnorm(n = nrow(X), mean = 0, sd = sigma)
h  <- exp(as.matrix(X)%*%beta)+ epsilon







