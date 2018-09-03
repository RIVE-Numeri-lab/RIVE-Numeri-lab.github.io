data{
  int N; // sample size
  int S; // number of species
  int D; // number of factors
  int<lower=0> Y[N,S]; // data matrix of order [N,S]
}
transformed data{
  int<lower=1> M;
  vector[D] FS_mu; // factor means
  vector<lower=0>[D] FS_sd; // factor standard deviations
  M = D*(S-D)+ D*(D-1)/2;  // number of lower-triangular, non-zero loadings
  for (m in 1:D) {
    FS_mu[m] = 0; //Mean of factors = 0
    FS_sd[m] = 1; //Sd of factors = 1
  }
}
parameters{
  //Parameters
  real alpha; //Global intercept
  vector[N] d0_raw; //Uncentered row intercepts
  vector<lower=-pi()/2, upper=pi()/2>[M] L_lower_unif; //Uncentered lower diagonal loadings
  vector<lower=0, upper=pi()/2>[D] L_diag_unif; //Uncentered positive diagonal elements of loadings
  matrix[N,D] FS; //Factor scores, matrix of order [N,D]
  cholesky_factor_corr[D] Rho; //Correlation matrix between factors
  //Hyperparameters
  real<lower=0, upper=pi()/2> sigma_d_unif; //Uncentered sd of the row intercepts
  real<lower=-pi()/2, upper=pi()/2> mu_low_unif; //Uncentered mean of lower diag loadings
  real<lower=0, upper=pi()/2> tau_low_unif; //Uncentered scale of lower diag loadings
}
transformed parameters{
  // Final parameters
  vector[N] d0; //Final row intercepts
  vector[D] L_diag; //Final diagonal loadings
  vector[M] L_lower; // Final lower diagonal loadings
  cholesky_factor_cov[S,D] L; //Final matrix of laodings
  matrix[D,D] Ld; // cholesky decomposition of the covariance matrix between factors
  // Final hyperparameters
  real sigma_d; //Final sd of the row intercepts
  real mu_low; //Final mean of lower diag loadings
  real tau_low; //Final scale of lower diag loadings
  //Predictors
  matrix[N,S] Ups; //intermediate predictor
  matrix<lower=0>[N,S] Mu; //predictor
  
  // Compute the final hyperparameters
  sigma_d = 0 + 1 * tan(sigma_d_unif); //sigma_d ~ Halfcauchy(0,2.5)
  mu_low = 0 + 1 * tan(mu_low_unif); //mu_low ~ cauchy(0,2.5)
  tau_low = 0 + 1 * tan(tau_low_unif); //sigma_low ~ Halfcauchy(0,2.5)
  
  //Compute the final parameters
  d0 = 0 + sigma_d * d0_raw; //do ~ Normal(0, sigma_d)
  L_diag = 0 + 2.5 * tan(L_diag_unif); //L_diag ~ Halfcauchy(0, 2.5)
  L_lower = mu_low + tau_low * tan(L_lower_unif); //L_lower ~ cauchy(mu_low, tau_low)
  
  // Correlation matrix of factors
  Ld = diag_pre_multiply(FS_sd, Rho); //Fs_sd fixed to 1, Rho estimated
  
  {
    int idx2; //Index for the lower diagonal loadings
    idx2 = 0;
    
    // Constraints to allow identifiability of loadings
  	 for(i in 1:(D-1)) { for(j in (i+1):(D)){ L[i,j] = 0; } } //0 on upper diagonal
  	 for(i in 1:D) L[i,i] = L_diag[i]; //Positive values on diagonal
  	 for(j in 1:D) {
  	   for(i in (j+1):S) {
  	     idx2 = idx2+1;
  	     L[i,j] = L_lower[idx2]; //Insert lower diagonal values in loadings matrix
  	   }
  	 }
  }
  
  // Predictors
  Ups = FS * L';
  for(n in 1:N) Mu[n] = exp(alpha + d0[n] + Ups[n]);
  
}
model{
  // Uncentered hyperpriors : the sampling will be automaticaly done as if they were defined on an uniform distribution between 0 or -pi/2 and pi/2 (see constraints)
  
  // Priors
  alpha ~ student_t(3,0,5); //Weakly informative prior for global intercept
  d0_raw ~ normal(0,1); //Uncentered regularizing prior for row deviations
  Rho ~ lkj_corr_cholesky(1); //Uninformative prior for Rho
  
  for(i in 1:N){	
    Y[i,] ~ poisson(Mu[i,]);
    FS[i,] ~ multi_normal_cholesky(FS_mu, Ld);
  }
}
generated quantities{
  matrix[S,S] cov_L;
  matrix[S,S] cor_L;
  matrix[N,S] Y_pred;
  matrix[N,S] log_lik1;
  vector[N*S] log_lik;
  
  cov_L = multiply_lower_tri_self_transpose(L); //Create the covariance matrix
  
  // Compute the correlation matrix from de covariance matrix
  for(i in 1:S){
    for(j in 1:S){
      cor_L[i,j] = cov_L[i,j]/sqrt(cov_L[i,i]*cov_L[j,j]);
    }
  }
  
  //Compute the likelihood and predictions for each observation
  for(n in 1:N){
    for(s in 1:S){
      log_lik1[n,s] = poisson_lpmf(Y[n,s] | Mu[n,s]);
      Y_pred[n,s] = poisson_rng(Mu[n,s]);
    }
  }
  log_lik = to_vector(log_lik1); //Tranform in a vector usable by loo package
}

