functions {
  real[] dz_dt(real t,       // time
               real[] z,     // system state {prey, predator}
               real[] theta, // parameters
               real[] x_r,   // unused data
               int[] x_i) {
    // Starting values
    real prey = z[1];
    real pred = z[2];
    // Parameters
    real rg = theta[1];
    real ri = theta[2];
    real rm = theta[3];
    real ra = theta[4];
    //Differential equation
    real dprey_dt = rg * prey - ri * pred * prey;
    real dpred_dt = -rm * pred + ra * prey * pred;
    
    return { dprey_dt, dpred_dt };
  }
}
data {
  int<lower = 0> N;          // number of measurement times
  real ts[N];                // measurement times > 0
  real y_init[2];            // initial measured populations
  real<lower = 0> y[N, 2];   // measured populations
  
  // prior parameters
  real mu_rg; // mu for the growth rate
  real mu_ri; // mu for the ingestion rate
  real mu_rm; // mu for the mortality rate
  real mu_ra; // mu for assimilation efficiency
  real mu_sigma;
  real mu_zinit;
}
parameters {
  real<lower = 0> theta[4];   // { alpha, beta, gamma, delta }
  real<lower = 0> z_init[2];  // initial population
  real<lower = 0> sigma[2];   // measurement errors
}
transformed parameters {
  real z[N, 2]
    = integrate_ode_rk45(dz_dt, z_init, 0, ts, theta,
                         rep_array(0.0, 0), rep_array(0, 0),
                         1e-5, 1e-3, 5e2);
}
model {
  theta[1] ~ lognormal(log(mu_rg), 1);
  theta[2] ~ lognormal(log(mu_ri), 1);
  theta[3] ~ lognormal(log(mu_rm), 1);
  theta[4] ~ lognormal(log(mu_ra), 1);
  sigma ~ lognormal(mu_sigma, 1);
  z_init ~ lognormal(log(mu_zinit), 1);
  for (k in 1:2) {
    y_init[k] ~ lognormal(log(z_init[k]), sigma[k]);
    y[ , k] ~ lognormal(log(z[, k]), sigma[k]);
  }
}
generated quantities {
  real y_init_rep[2];
  real y_rep[N, 2];
  matrix[N,2] log_lik1;
  vector[N*2] log_lik;
  for (k in 1:2) {
    y_init_rep[k] = lognormal_rng(log(z_init[k]), sigma[k]);
    for (n in 1:N)
      y_rep[n, k] = lognormal_rng(log(z[n, k]), sigma[k]);
  }
  // Log-likelihood
    for (k in 1:2) {
    for (n in 1:N)
      log_lik1[n, k] = lognormal_lpdf(y[n, k]|log(z[n, k]), sigma[k]);
  }
  log_lik = to_vector(log_lik1);
}