

simulate_temp <- function(doy = 1:365, 
                          tmin = -10, 
                          tmax = 35){
  nd <- length(doy)
  
  temp <- 
    sin(
      (doy + runif(nd, -20, 20))/365*2*pi*runif(nd, 0.9, 1.05)
      -
        pi/2*runif(nd, 0.8, 1.2)
    )*
    (tmax*runif(nd, 0.8, 1.2) - tmin*runif(nd, 0.8, 1.2))/2 + 
    (tmax*runif(nd, 0.8, 1.2) + tmin*runif(nd, 0.8, 1.2))/2
  
  temp
}