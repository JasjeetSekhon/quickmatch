% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/reg_estimator.R
\name{regression_estimator}
\alias{regression_estimator}
\title{Regression-based average treatment effect estimator}
\usage{
regression_estimator(outcomes, treatments, matching, covariates = NULL,
  subset = NULL)
}
\arguments{
\item{outcomes}{numeric vector with observed outcomes.}

\item{treatments}{factor specifying which treatments the units are assigned to.}

\item{matching}{\code{\link{qm_matching}} or \code{\link[scclust]{scclust}} object with
the matched groups.}

\item{covariates}{vector, matrix or data frame with covariates to include in the estimation.
If \code{NULL}, no covariates are included.}

\item{subset}{units to target the estimation for. If \code{NULL}, the estimate will
pertain to all units in the sample (i.e., ATE). A non-null value
specificies a subset of units that the estimate should pertain to (e.g.,
ATT or ATC). If \code{subset} is a logical vector with the same length as
the sample size, units indicated with \code{TRUE} will be included. If
\code{subset} is an integer vector, the units with indices in \code{subset}
are included. Indices starts at 1 and \code{subset} must be sorted. If
\code{subset} is a character vector, it should contain treatment labels,
and the corresponding units (as given by \code{treatments}) will be
included in the estimation.}
}
\value{
Returns estimated treatment effects. A list with two numeric matrix with
   all estimated treatment effects and their estimated variances is returned.
   The first matrix (\code{effects}) contains estimated treatment effects.
   Rows in this matrix indicate minuends in the treatment effect contrast and
   columns indicate subtrahends. For example, in the matrix:
   \tabular{rrrr}{
     \tab a \tab b \tab c\cr
     a \tab 0.0 \tab 4.5 \tab 5.5\cr
     b \tab -4.5 \tab 0.0 \tab 1.0\cr
     c \tab -5.5 \tab -1.0 \tab 0.0\cr
   }
   the estimated treatment effect between conditions \eqn{a} and \eqn{b} is
   \eqn{4.5}, and the estimated treatment effect between conditions \eqn{c}
   and \eqn{b} is \eqn{-1.0}. Or in symbols: \eqn{E[Y(a) - Y(b)] = 4.5} and
   \eqn{E[Y(c) - Y(b)] = -1.0}.

   The second matrix (\code{effect_variances}) contains estimates of
   variances of the corresponding effect estimators.
}
\description{
\code{regression_estimator} estimates treatment effects from matched groups.
Provided a matching, outcomes and treatment indicators, the function returns
point estimates of the average treatment effects for the units in the sample
and variance estimates for those effects. It is also possible to estimate
treatment effects for subsets of the units. For example, one can estimate the
effects for units assigned to a certain treatment condition (e.g., ATT).
}
\examples{
# Construct example data
my_data <- data.frame(y = rnorm(100),
                      x1 = runif(100),
                      x2 = runif(100),
                      treatments = factor(sample(rep(c("T1", "T2", "C", "C"), 25))))

# Make distances
my_distances <- distances(my_data, dist_variables = c("x1", "x2"))

# Make matching
my_matching <- quickmatch(my_distances, my_data$treatments)

# ATE
regression_estimator(my_data$y, my_data$treatments, my_matching, my_data[c("x1", "x2")])

# ATT for T1
regression_estimator(my_data$y, my_data$treatments, my_matching, my_data[c("x1", "x2")], "T1")

}
