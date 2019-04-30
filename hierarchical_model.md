---
title: "Continuous Development Models for Greenup Phenology"
author: | 
  | Bijan Seyednasrollah
  | http://bnasr.github.io/
  | bijan.s.nasr@gmail.com
  
date: "4/28/2019"
output:
  pdf_document: default
---



This document explains how the two-stage and three-stage phenology models are set up and structured. 

---

## Two-Stage Phenology Model
The two-stage model is based on only a single transition point: **_Onset_**. And therefore, the two stages are 1) pre-onset and 2) post-onset. Here, I explain the theoretical  framework for a Hierarchical Bayesian model that can simulate the process. 

We first define a latent development state where the greenup continuously develops:

\begin{equation}
h_{p,y,d+1}  = h_{p,y,d} + \delta h_{p,y,d}
\end{equation}

where $h_{p,y,d}$ is the latent state for pixel *p*, in year *y* and day *d*. $\delta h_{p,y,d}$ is the latent state increment.
We use a exponential increment function that 

\begin{equation}
\delta h_{p,y,d} = e^{X_{p,y,d}\beta + \epsilon}(1 - h_{p,y,d}/h_{max})[T_{p,y,d}-T_{base}]
\end{equation}

where $X_{p,y,d}$ is the matrix of predictors and $\epsilon$ is the process error, defined as:
\begin{equation}
\epsilon \sim Normal(0, \sigma^2)
\end{equation}


We set $h_{p,y,1} = 0$, and $h_{max} = 1$. To link the discrete observations (pre-onset/post-onset or True/False) to the continuous scale that the development happens, we use a logit transformation:
\begin{equation}
logit(P_{p,y,d}) = \kappa + \lambda*h_{p,y,d}
\end{equation}


where $\kappa$ and $\lambda$ are the intercept and slope of the transformation and $P_{p,y,d}$ is the probability that the onset occurs at pixel *P* in year *y* and day *d*.
$P_{p,y,d}$ has the Bernoulli distribution:


\begin{equation}
Y_{p,y,d} \sim Bernoulli(P_{p,y,d})
\end{equation}

where $Y_{p,y,d}$ is the observed phenological stage for pixel *p* in year *y* and day *d*.

---

## Three-Stage Phenology Model

The three-stage model is based on two transition points: **_Onset_** and **_Maturity_**. And therefore, the three stages are 1) pre-greenup and 2) greenup and 3) post-greenup. Here, I explain the theoretical  framework for a Hierarchical Bayesian model that can simulate the process. 

The process level of the three-stage model is the same as the two-stage phenology model. However the link function level would be slightly different 

Similar to two-stage model, the latent states are defined as:

\begin{equation}
h_{p,y,d+1}  = h_{p,y,d} + \delta h_{p,y,d}
\end{equation}

\begin{equation}
\delta h_{p,y,d} = e^{X_{p,y,d}\beta + \epsilon}(1 - h_{p,y,d}/h_{max})[T_{p,y,d}-T_{base}]
\end{equation}

\begin{equation}
\epsilon \sim Normal(0, \sigma^2)
\end{equation}

\begin{equation}
h_{p,y,1} = 0 
\end{equation}

\begin{equation}
h_{max} = 1
\end{equation}

Since the latent state continuously increases over different phenology stages, we define $\theta_{p,y,d,m}$ as the probability that pixel *p* is in stage *m* in year *y* and day *d*, while $P_{p,y,d,m}$ is the the probability that pixel *p* is in any of stage 1 to *m* in year *y* and day *d*. The cumulative probability accounts for the compatibility with the development function.

The observations and the latent states are linked with the Multinomial distribution:

\begin{equation}
Y_{p,y,d} \sim Multinomial(1, \Theta_{p,y,d})
\end{equation}
where $\Theta_{p,y,d}$ is the probabililty that pixel *p* in year *y* and day *d* is in any of the stages 1 to *M* (in this case $M = 3$) and 
\begin{equation}
\theta_{p,y,d,1} = P_{p,y,d,1}
\end{equation}

\begin{equation}
\theta_{p,y,d,2} = P_{p,y,d,2} - P_{p,y,d,1}
\end{equation}

\begin{equation}
\theta_{p,y,d,3} = 1 - P_{p,y,d,2}
\end{equation}

To link the discrete observations (pre-onset/post-onset or True/False) to the continuous scale that the development happens, we use a logit transformation:
\begin{equation}
logit(P_{p,y,d,1}) = \kappa_1 + \lambda_1*h_{p,y,d}
\end{equation}

\begin{equation}
logit(P_{p,y,d,2}) = \kappa_2 + \lambda_2*h_{p,y,d}
\end{equation}

\begin{equation}
P_{p,y,d,3} = 1
\end{equation}

where $\kappa_m$ and $\lambda_m$ are the intercept and slope of the transformation for stage *m*.

---
