# Complete script to execute spatiall correlated factor analysis
## Empty environment
rm(list = ls())

# Load packages -----------------------------------------------------------
library(tidyverse)
library(reshape2)
library(SpatialTools)
library(rethinking)
library(rstan)
library(vegan)

# Simulate data -----------------------------------------------------------
N <- 100 # Number of data points
S <- 10 # Number of species
D <- 3 # Number of factors
l_true = 1 # Length scale parameter of the process

## Create a 20x20 lattice based on coordinates
lat <- rep(1:10, times = 10)
long <- rep(1:10, rep(10,10))
Coords <- as.matrix(data.frame(lat = lat, long = long))
head(Coords)

## Compute the distance matrix between each point
Dist <- dist1(Coords)

## Compute the correlation between points using squared exponential covariance function
K_f<- exp(-( Dist^2 / (2*l_true^2) ) )
plot(c(Dist),  c(K_f))
melt(K_f) %>% ggplot(aes(x = Var1, y = Var2, fill = value)) +
  geom_tile()

## Compute the spatially structured factors
## Sample the factor scores from a multivariate normal (mean = 0)
FS_true <- rmvnorm2(D, Mu = rep(0, length(diag(K_f)), sigma = diag(K_f),
                           Rho = K_f))
# Sample the loadings (D x S matrix)
## Sample a matrix from a multivariate normal
L_corr <- rlkjcorr(1, S, eta = 0.5) ## eta = 0.5 concentrate the density around -1 and 1
Lambda <- rmvnorm2(D, Mu = rep(0, length(diag(L_corr))), sigma = rep(0.8, length(diag(L_corr))),
                   Rho = L_corr)
head(Lambda)
Lt <- t(Lambda)
head(Lt)
## Force the diag to be positive
for(i in 1:D) Lt[i,i] <- abs(Lt[i,i])
diag(Lt)
## Force the upper-diag to zero
L <- Lt
for(i in 1:(D-1)) {
  for(j in (i+1):(D)){ 
    L[i,j] = 0;
  }
}
head(L)

# Sample a global intercept
alpha <- rnorm(1)
# Sample a deviation parameter per row (plot)
d0 <- rnorm(N)
# Compute the final matrix of predictor
Mu <- exp(alpha + d0 + t(FS_true) %*% t(L))
head(Mu)

# Compute the stochastic observations
Y <- matrix(nrow = N, ncol = S)
for(i in 1:N){
  for(j in 1:S){
    Y[i,j] <- rpois(1, Mu[i,j])
  }
}
#summary(Y)
colnames(Y) <- LETTERS[1:S] ## Attribute names to species
## Remove empty rows
Y1 <- Y[which(rowSums(Y) != 0),]

pairs(log(Y+1), col = scales::alpha('black', 0.5), pch = 16) ## Scatterplot matrix

### Examine data structure with NMDS
NMDS <- metaMDS(Y, k = 3, trymax = 100)
par(mfrow = c(1,2))
plot(NMDS, choices = c(1,2), type = "t")
plot(NMDS, choices = c(1,3), type = "t");par(mfrow = c(1,1))

D_stan <- list(Y = Y, Dist = Dist, N = nrow(Y), S = S, D = D)

BFS <- stan("Poisson_BFM_Reparam.stan", data = D_stan,
            pars = c("Mu", "d0_raw", "L_lower_unif", "L_diag_unif", "sigma_d_unif",
                     "mu_low_unif", "tau_low_unif", "log_lik1"), include = F,
            iter = 1000, init = 0,
            chains = parallel::detectCores()-1, cores = parallel::detectCores()-1,
            control = list(max_treedepth = 8))

print(BFS)
print(BFS, pars = "l", inc_warmup = T)
