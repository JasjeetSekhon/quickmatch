# ==============================================================================
# quickmatch -- Quick Generalized Full Matching
# https://github.com/fsavje/quickmatch
#
# Copyright (C) 2017  Fredrik Savje -- http://fredriksavje.com
#
# This program is free software: you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with this program. If not, see http://www.gnu.org/licenses/
# ==============================================================================

library(quickmatch)
context("Input checking in R code")


# ==============================================================================
# new_error & new_warning
# ==============================================================================

t_new_error <- function(...) {
  temp_func <- function(...) {
    new_error(...)
  }
  temp_func(...)
}

t_new_warning <- function(...) {
  temp_func <- function(...) {
    new_warning(...)
  }
  temp_func(...)
}

test_that("`new_error` & `new_warning` make warnings and errors.", {
  expect_error(t_new_error("This is an error."),
               regexp = "This is an error.")
  expect_error(t_new_error("This is", " also ", "an error."),
               regexp = "This is also an error.")
  expect_warning(t_new_warning("This is a warning."),
                 regexp = "This is a warning.")
  expect_warning(t_new_warning("This is", " also ", "a warning."),
                 regexp = "This is also a warning.")
})


# ==============================================================================
# is.numeric_integer
# ==============================================================================

test_that("`is.numeric_integer` makes correct output.", {
  expect_true(is.numeric_integer(c(1, 2, 3, 4, 5)))
  expect_true(is.numeric_integer(1:5))
  expect_true(is.numeric_integer(c(1, 2, NA, 4, 5)))
  expect_false(is.numeric_integer(c(1, 2, NaN, 4, 5)))
  expect_false(is.numeric_integer(c(1, 2, 3, Inf, 5)))
  expect_false(is.numeric_integer(c(1, 2.5, 3, 4, 5)))
})


# ==============================================================================
# ensure_distances
# ==============================================================================

t_ensure_distances <- function(t_distances = distances::distances(matrix(1:10, nrow = 5))) {
  ensure_distances(t_distances)
}

test_that("`ensure_distances` checks input.", {
  expect_silent(t_ensure_distances())
  expect_error(t_ensure_distances(t_distances = "a"),
               regexp = "`t_distances` is not a `distances` object.")
})


# ==============================================================================
# ensure_matching
# ==============================================================================

t_ensure_matching <- function(t_matching = qm_matching(c("A", "A", "B", "C", "B", "C", "C", "A", "B", "B")),
                              t_req_length = 10L) {
  ensure_matching(t_matching, t_req_length)
}

test_that("`ensure_matching` checks input.", {
  expect_silent(t_ensure_matching())
  expect_silent(t_ensure_matching(t_req_length = NULL))
  expect_silent(t_ensure_matching(scclust::scclust(c("A", "A", "B", "C", "B", "C", "C", "A", "B", "B"))))
  expect_error(t_ensure_matching(t_matching = "a"),
               regexp = "`t_matching` is not a valid matching object.")
  expect_error(t_ensure_matching(t_req_length = 5L),
               regexp = "`t_matching` does not contain `t_req_length` units.")
})


# ==============================================================================
# ensure_caliper
# ==============================================================================

t_ensure_caliper <- function(t_caliper = 0.5) {
  ensure_caliper(t_caliper)
}

test_that("`ensure_caliper` checks input.", {
  expect_silent(t_ensure_caliper())
  expect_silent(t_ensure_caliper(t_caliper = 1L))
  expect_silent(t_ensure_caliper(t_caliper = NULL))
  expect_error(t_ensure_caliper(t_caliper = "a"),
               regexp = "`t_caliper` must be numeric or `NULL`.")
  expect_error(t_ensure_caliper(t_caliper = c(0.5, 0.3)),
               regexp = "`t_caliper` must be scalar.")
  expect_error(t_ensure_caliper(t_caliper = NA),
               regexp = "`t_caliper` may not be NA.")
  expect_error(t_ensure_caliper(t_caliper = -1.0),
               regexp = "`t_caliper` must be positive or `NULL`.")
})


# ==============================================================================
# coerce_covariates
# ==============================================================================

t_coerce_covariates <- function(t_covariates = as.numeric(1:10),
                                t_req_length = 10L) {
  coerce_covariates(t_covariates, t_req_length)
}

test_that("`coerce_covariates` checks input.", {
  expect_silent(t_coerce_covariates())
  expect_silent(t_coerce_covariates(t_covariates = matrix(as.numeric(1:20), ncol = 2L)))
  expect_silent(t_coerce_covariates(t_covariates = data.frame(x1 = as.numeric(1:10), x2 = as.numeric(11:20))))
  expect_silent(t_coerce_covariates(t_covariates = 1:10))
  expect_silent(t_coerce_covariates(t_covariates = matrix(1:20, ncol = 2L)))
  expect_silent(t_coerce_covariates(t_covariates = data.frame(x1 = 1:10, x2 = 11:20)))

  expect_error(t_coerce_covariates(t_covariates = dist(1:10)),
               regexp = "`t_covariates` must be vector, matrix or data frame.")
  expect_error(t_coerce_covariates(t_covariates = letters[1:10]),
               regexp = "`t_covariates` is not numeric.")
  expect_error(t_coerce_covariates(t_req_length = 5L),
               regexp = "`t_covariates` is not of length `t_req_length`.")
})

test_that("`coerce_covariates` coerces correctly.", {
  expect_identical(t_coerce_covariates(),
                   matrix(as.numeric(1:10), ncol = 1L))
  expect_identical(t_coerce_covariates(t_covariates = matrix(as.numeric(1:20), ncol = 2L)),
                   matrix(as.numeric(1:20), ncol = 2L))
  expect_identical(t_coerce_covariates(t_covariates = data.frame(x1 = as.numeric(1:10), x2 = as.numeric(11:20))),
                   matrix(as.numeric(1:20), ncol = 2L))
  expect_identical(t_coerce_covariates(t_covariates = 1:10),
                   matrix(as.numeric(1:10), ncol = 1L))
  expect_identical(t_coerce_covariates(t_covariates = matrix(1:20, ncol = 2L)),
                   matrix(as.numeric(1:20), ncol = 2L))
  expect_identical(t_coerce_covariates(t_covariates = data.frame(x1 = 1:10, x2 = 11:20)),
                   matrix(as.numeric(1:20), ncol = 2L))
})


# ==============================================================================
# coerce_double
# ==============================================================================

t_coerce_double <- function(t_x = 1:10,
                            t_req_length = NULL) {
  coerce_double(t_x, t_req_length)
}

test_that("`coerce_double` checks input.", {
  expect_silent(t_coerce_double())
  expect_silent(t_coerce_double(t_x = as.numeric(1:10)))
  expect_silent(t_coerce_double(t_req_length = 10))
  expect_error(t_coerce_double(t_x = letters[1:10]),
               regexp = "`t_x` is not numeric.")
  expect_error(t_coerce_double(t_req_length = 8),
               regexp = "`t_x` is not of length `t_req_length`.")
})

test_that("`coerce_double` coerces correctly.", {
  expect_identical(t_coerce_double(), as.numeric(1:10))
  expect_identical(t_coerce_double(t_x = as.numeric(1:10)), as.numeric(1:10))
  expect_identical(t_coerce_double(t_req_length = 10), as.numeric(1:10))
})


# ==============================================================================
# coerce_size_constraint
# ==============================================================================

t_coerce_size_constraint <- function(t_size_constraint = 4L,
                                     t_sum_treatment_constraints = 3L,
                                     t_num_data_points = 100L) {
  coerce_size_constraint(t_size_constraint,
                         t_sum_treatment_constraints,
                         t_num_data_points)
}

test_that("`coerce_size_constraint` checks input.", {
  expect_silent(t_coerce_size_constraint())
  expect_silent(t_coerce_size_constraint(t_size_constraint = NULL))
  expect_silent(t_coerce_size_constraint(t_size_constraint = 4.0))

  expect_error(t_coerce_size_constraint(t_size_constraint = c(10L, 3L)),
               regexp = "`t_size_constraint` must be scalar.")
  expect_error(t_coerce_size_constraint(t_size_constraint = "a"),
               regexp = "`t_size_constraint` must be integer.")
  expect_error(t_coerce_size_constraint(t_size_constraint = as.integer(NA)),
               regexp = "`t_size_constraint` may not be NA.")
  expect_error(t_coerce_size_constraint(t_size_constraint = 1L),
               regexp = "`t_size_constraint` must be greater or equal to two.")
  expect_error(t_coerce_size_constraint(t_size_constraint = 2L),
               regexp = "`t_size_constraint` must be greater or equal to the sum of the treatment constraints.")
  expect_error(t_coerce_size_constraint(t_size_constraint = 200L),
               regexp = "`t_size_constraint` may not be great than the number of units.")
})

test_that("`coerce_size_constraint` coerces correctly.", {
  expect_identical(t_coerce_size_constraint(), 4L)
  expect_identical(t_coerce_size_constraint(t_size_constraint = NULL), 3L)
  expect_identical(t_coerce_size_constraint(t_size_constraint = 4.0), 4L)
})


# ==============================================================================
# coerce_subset
# ==============================================================================

t_coerce_subset <- function(t_subset = c("A", "B"),
                            t_treatments = factor(c("A", "A", "B", "B", "B", "A", "B", "A"))) {
  coerce_subset(t_subset, t_treatments)
}

test_that("`coerce_subset` checks input.", {
  expect_silent(t_coerce_subset())
  expect_silent(t_coerce_subset(t_subset = c("A")))
  expect_silent(t_coerce_subset(1:5))
  expect_error(t_coerce_subset(t_subset = c("A", "B", "A")),
               regexp = "`t_subset` may not contain duplicates.")
  expect_error(t_coerce_subset(t_subset = c("A", "B", "C", "D")),
               regexp = "`t_subset` contains unknown treatment labels: \"C\", \"D\".")
})

test_that("`coerce_subset` coerces correctly.", {
  expect_identical(t_coerce_subset(), NULL)
  expect_identical(t_coerce_subset(t_subset = c("A")),
                   c(1L, 2L, 6L, 8L))
  expect_identical(t_coerce_subset(1:5), 1:5)
})


# ==============================================================================
# coerce_treatments
# ==============================================================================

t_coerce_treatments <- function(t_treatments = 1:10,
                                t_req_length = 10L) {
  coerce_treatments(t_treatments, t_req_length)
}

test_that("`coerce_treatments` checks input.", {
  expect_silent(t_coerce_treatments())
  expect_silent(t_coerce_treatments(t_treatments = factor(letters[1:10])))
  expect_silent(t_coerce_treatments(t_treatments = letters[1:10]))
  expect_warning(t_coerce_treatments(t_treatments = as.numeric(1:10)),
                 regexp = "Coercing `t_treatments` to factor.")
  expect_warning(t_coerce_treatments(t_treatments = rep(c(TRUE, FALSE), 5L)),
                 regexp = "Coercing `t_treatments` to factor.")
  expect_error(t_coerce_treatments(t_treatments = dist(1:10)),
               regexp = "Do not know how to coerce `t_treatments` to factor.")
  expect_error(t_coerce_treatments(t_req_length = 5L),
               regexp = "Length of `t_treatments` does not match distances object.")
})

test_that("`coerce_treatments` coerces correctly.", {
  expect_identical(t_coerce_treatments(),
                   factor(1:10))
  expect_identical(t_coerce_treatments(t_treatments = factor(letters[1:10])),
                   factor(letters[1:10]))
  expect_identical(t_coerce_treatments(t_treatments = letters[1:10]),
                   factor(letters[1:10]))
  expect_warning(expect_identical(t_coerce_treatments(t_treatments = as.numeric(1:10)),
                                  factor(1:10)))
  expect_warning(expect_identical(t_coerce_treatments(t_treatments = rep(c(TRUE, FALSE), 5L)),
                                  factor(rep(c(TRUE, FALSE), 5L))))
})


# ==============================================================================
# coerce_treatment_constraints
# ==============================================================================

t_coerce_treatment_constraints <- function(t_treatment_constraints = c("A" = 1L, "B" = 2L),
                                           t_treatment_levels = factor(c("A", "A", "B", "B", "B", "A", "B", "A"))) {
  coerce_treatment_constraints(t_treatment_constraints, t_treatment_levels)
}

test_that("`coerce_treatment_constraints` checks input.", {
  expect_silent(t_coerce_treatment_constraints())
  expect_silent(t_coerce_treatment_constraints(t_treatment_constraints = c("A" = 1.0, "B" = 2.0)))

  expect_error(t_coerce_treatment_constraints(t_treatment_constraints = c(1L, 2L)),
               regexp = "`t_treatment_constraints` must be named.")
  expect_error(t_coerce_treatment_constraints(t_treatment_constraints = c("A" = 1L, "B" = 2L, "B" = 3L)),
               regexp = "`t_treatment_constraints` may not contain duplicate names.")
  expect_error(t_coerce_treatment_constraints(t_treatment_constraints = c("A" = 1L, "B" = 2L, "C" = 3L, "D" = 3L)),
               regexp = "`t_treatment_constraints` contains unknown treatment labels: \"C\", \"D\".")
  expect_error(t_coerce_treatment_constraints(t_treatment_constraints = c("A" = "1.0", "B" = "2.0")),
               regexp = "`t_treatment_constraints` must be integer.")
  expect_error(t_coerce_treatment_constraints(t_treatment_constraints = c("A" = 1L, "B" = NA)),
               regexp = "`t_treatment_constraints` may not contain NAs.")
  expect_error(t_coerce_treatment_constraints(t_treatment_constraints = c("A" = 1L, "B" = -2L)),
               regexp = "`t_treatment_constraints` must be non-negative.")
})

test_that("`coerce_treatment_constraints` coerces correctly.", {
  expect_identical(t_coerce_treatment_constraints(),
                   c("A" = 1L, "B" = 2L))
  expect_identical(t_coerce_treatment_constraints(t_treatment_constraints = c("A" = 1.0, "B" = 2.0)),
                   c("A" = 1L, "B" = 2L))
})
