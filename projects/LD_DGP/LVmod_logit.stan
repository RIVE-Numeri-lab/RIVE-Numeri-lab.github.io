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
    real K = 50;
    //Differential equation
    real dprey_dt = rg * prey * (1 - prey/K) - ri * pred*prey;
    real dpred_dt = (-rm + ra * prey) * pred;
    
    return { dprey_dt, dpred_dt };
  }
}
data {
  int<lower = 0> N;          // number of measurement times
  real ts[N];                // measurement times > 0
  int<lower = 0> y_init[2];  // initial measured populations
  int<lower = 0> y[N, 2];   // measured populations
}
parameters {
  real<lower = 0> theta[4];   // { alpha, beta, gamma, delta }
  real<lower = 0> z_init[2];  // initial population
}
transformed parameters {
  real<lower = 0> z[N, 2]
  = integrate_ode_rk45(dz_dt, z_init, 0, ts, theta,
                       rep_array(0.0, 0), rep_array(0, 0),
                       1e-5, 1e-3, 5e2);
}
model {
  theta[{1, 3}] ~ normal(1, 0.5);
  theta[{2, 4}] ~ normal(0.5, 0.5);
  z_init ~ lognormal(10, 1);
  for (k in 1:2) {
    y_init[k] ~ poisson(z_init[k]);
    y[ , k] ~ poisson(z[, k]);
  }
}
generated quantities {
  real y_init_rep[2];
  real y_rep[N, 2];
  matrix[N, 2] log_lik1;
  vector[N*2] log_lik;
  
  // Predicted data
  for (k in 1:2) {
    y_init_rep[k] = poisson_rng(z_init[k]);
    for (n in 1:N)
      y_rep[n, k] = poisson_rng(z[n, k]);
  }
  // Log-likelihood
    for (k in 1:2) {
    for (n in 1:N)
      log_lik1[n, k] = poisson_lpmf(y[n, k]|z[n, k]);
  }
  log_lik = to_vector(log_lik1);
}