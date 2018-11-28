#####################################
# Function related to the workshop "Data generating process", given the 28th of November 2018
####################################


# Function to generate the Nemobius data for population estimation --------
gen.nemobius.pop <- function(N = 50, lambda = 4){
  Nemobius <- data.frame(quadrat = 1:N, abundance = rpois(50, 4)) ## Observed counts
}


# switched and scaled student-t functions -----------------------------------------------------
## Likelihood function
dstudent_t <- function (x, df, mu = 0, sigma = 1, log = FALSE) 
{
  # if (any(sigma <= 0)) {
  #   stop2("sigma must be greater than 0.")
  # }
  if (log) {
    dt((x - mu)/sigma, df = df, log = TRUE) - log(sigma)
  }
  else {
    dt((x - mu)/sigma, df = df)/sigma
  }
}

## Sampler
rstudent_t <- function (n, df, mu = 0, sigma = 1) 
{
  # if (any(sigma <= 0)) {
  #   stop2("sigma must be greater than 0.")
  # }
  mu + sigma * rt(n, df = df)
}


# Function to generate Nemobius data for regression --------
# Function to generate the Nemobius data for population estimation --------
gen.nemobius.reg <- function(N = 100){
  ## Generate parameters
  alpha <- rnorm(1,0,1)
  beta <- rnorm(1,0.5,0.1)
  
  ## Sample litter thickness
  x <- rlnorm(N, log(2), log(1.5))
  ## Compute predictors
  pred <- exp(alpha + beta*x)
  ## Sample from poisson distribution
  y <- rpois(pred, pred)
  
  Nemobius <- data.frame(quadrat = 1:N, litter_thickness = x, abundance = y) ## Observed counts
  
  return(list(Nemobius = Nemobius, Truea = alpha, Trueb = beta))
}

# Gibbs sampler for poisson regression ------------------------------------
## https://theoreticalecology.wordpress.com/2010/09/17/metropolis-hastings-mcmc-in-r/

# ## Likelihood
# likelihood <- function(param, x, y){
#   alpha = param[1]
#   beta = param[2]
#   
#   pred = exp(alpha + beta*x)
#   singlelikelihoods = dpois(y, lambda = pred, log = T)
#   sumll = sum(singlelikelihoods)
#   return(sumll)   
# }
# 
# ## Prior distribution
# prior <- function(param){
#   alpha = param[1]
#   beta = param[2]
#   
#   aprior = dnorm(alpha, mean = 0, sd = 5, log = T)
#   bprior = dnorm(beta, mean = 0, sd = 5, log = T)
#   
#   return(aprior+bprior)
# }
# 
# ## Posterior
# posterior <- function(param, x, y){
#   return (likelihood(param, x, y) + prior(param))
# }
# 
# ## Function to get a new proposal
# proposalfunction <- function(param){
#   return(rnorm(2,mean = param, sd= c(0.1,0.5)))
# }
# 
# ## Metropolis-Hasting sampler
# run_metropolis_MCMC <- function(startvalue, iterations, x, y){
#   chain = array(dim = c(iterations+1,2))
#   chain[1,] = startvalue
#   for (i in 1:iterations){
#     proposal = proposalfunction(chain[i,])
#     
#     probab = exp(posterior(proposal, x, y) - posterior(chain[i,], x, y))
#     if (runif(1) < probab){
#       chain[i+1,] = proposal
#     }else{
#       chain[i+1,] = chain[i,]
#     }
#   }
#   return(chain)
# }


# Logistic functions ------------------------------------------------------
logistic <- function(rmax, N, K){
  dN <- rmax * ((K-N)/ K) * N
  return(list(dN))
}

logistic.ode <-function(t, state, parameters) {
  with(as.list(c(state, parameters)),{
    # rate of change
    dN <- rmax * ((K-N)/ K) * N
    # return the rate of change
    list(dN)
  })
}


# Function to generate preay and predators data ---------------------------
## Lotka-Volterra model, with exponential growth of prey
LVmod.exp <- function(Time, State, Pars) {
  with(as.list(c(State, Pars)), {
    Ingestion    <- rIng  * Prey * Predator
    GrowthPrey   <- rGrow * Prey
    MortPredator <- rMort * Predator
    
    dPrey        <- GrowthPrey - Ingestion
    dPredator    <- Ingestion * rAss - MortPredator
    
    return(list(c(dPrey, dPredator)))
  })
}

## Lotka-Volterra model, with logistic growth of prey
LVmod.logit <- function(Time, State, Pars) {
  with(as.list(c(State, Pars)), {
    Ingestion    <- rIng  * Prey * Predator
    GrowthPrey   <- rGrow * Prey * (1 - Prey/K)
    MortPredator <- rMort * Predator
    
    dPrey        <- GrowthPrey - Ingestion
    dPredator    <- Ingestion * rAss - MortPredator
    
    return(list(c(dPrey, dPredator)))
  })
}

## Function to generate predator-prey data
gen.nemobius.pred <- function(P = 10, t = 40, logit = T,
                              mu_rg = 0.55, mu_ri = 0.028,
                              mu_rm = 0.84, mu_ra = 0.25,
                              K = 500){
  ## Needed libraries
  require(deSolve)
  
  ## Create list to store results
  Nlist <-  list()
  ## Define parameters
  pars  <- c(rGrow  = rlnorm(1,log(mu_rg), log(1.1)),    # /day, growth rate of prey
             rIng   = rlnorm(1,log(mu_ri), log(1.1)),    # /day, rate of ingestion
             rMort  = rlnorm(1,log(mu_rm), log(1.1)) ,   # /day, mortality rate of predator
             rAss = rlnorm(1,log(mu_ra), log(1.1)),    # -, assimilation efficiency
             K      = K)     # mmol/m3, carrying capacity
  ## Define years for which to solve
  times = seq(2,t, by = 1)

  for(p in 1:P){
    ## Stochastic initial state
    yini <- c(Prey = rlnorm(1, log(35), 1) , Predator = rlnorm(1, log(6), 1))
    ## Compute lambdas for each years
    ### Exponential or logistic growth of preys?
    if(logit == T) mus <- as.data.frame(ode(yini, times, LVmod.logit, pars,
                                                method = "ode45"))
    if(logit == F) mus <- as.data.frame(ode(yini, times, LVmod.exp, pars,
                                                method = "ode45"))
    ## Store the final observed abundances
    Nlist[[p]] <- data.frame(trap = as.character(p), times = c(1, times), 
                             Prey = c(yini[1], rlnorm(mus$Prey,
                                                      log(mus$Prey), 0.25)),
                             Pred = c(yini[2], rlnorm(mus$Predator,
                                                      log(mus$Predator), 0.25)))
  }
  ## Tranform the list into a data frame
  Nemobius <- bind_rows(Nlist)
  
  return(list(Nemobius = Nemobius, pars = pars, yini = yini))
}

