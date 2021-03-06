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


# ==============================================================================
# Helper functions
# ==============================================================================

# Throw error
new_error <- function(...) {
  stop(structure(list(message = paste0(...),
                      call = match.call(definition = sys.function(-2),
                                        call = sys.call(which = -2),
                                        expand.dots = TRUE,
                                        envir = sys.frame(-3))),
                 class = c("error", "condition")))
}


# Throw warning
new_warning <- function(...) {
  warning(structure(list(message = paste0(...),
                         call = match.call(definition = sys.function(-2),
                                           call = sys.call(which = -2),
                                           expand.dots = TRUE,
                                           envir = sys.frame(-3))),
                    class = c("warning", "condition")))
}


# Is `x` a numeric that can be coerced into integer without loss of information?
is.numeric_integer <- function(x) {
  is.numeric(x) &&
    !any(is.nan(x)) &&
    !any(is.infinite(x)) &&
    all(is.na(x) | as.integer(x) == x)
}


# ==============================================================================
# Ensure functions
# ==============================================================================

# Ensure that `distances` is `distances` object
ensure_distances <- function(distances) {
  if (!distances::is.distances(distances)) {
    new_error("`", match.call()$distances, "` is not a `distances` object.")
  }
}


# Ensure that `matching` is a `scclust` object
ensure_matching <- function(matching,
                            req_length = NULL) {
  if (!scclust::is.scclust(matching)) {
    new_error("`", match.call()$matching, "` is not a valid matching object.")
  }
  if (!is.null(req_length) && (length(matching) != req_length)) {
    new_error("`", match.call()$matching, "` does not contain `", match.call()$req_length, "` units.")
  }
}


# Ensure `caliper` is NULL or a scalar, positive, non-na, numeric
ensure_caliper <- function(caliper) {
  if (!is.null(caliper)) {
    if (length(caliper) != 1L) {
      new_error("`", match.call()$caliper, "` must be scalar.")
    }
    if (is.na(caliper)) {
      new_error("`", match.call()$caliper, "` may not be NA.")
    }
    if (!is.numeric(caliper)) {
      new_error("`", match.call()$caliper, "` must be numeric or `NULL`.")
    }
    if (caliper <= 0.0) {
      new_error("`", match.call()$caliper, "` must be positive or `NULL`.")
    }
  }
}


# ==============================================================================
# Coerce functions
# ==============================================================================

# Coerce `covariates`
coerce_covariates <- function(covariates, req_length) {
  if (!is.null(covariates)) {
    if (is.data.frame(covariates)) {
      covariates <- as.matrix(covariates)
    } else if (is.vector(covariates)) {
      covariates <- as.matrix(covariates, ncol = 1)
    }
    if (!is.matrix(covariates)) {
      new_error("`", match.call()$covariates, "` must be vector, matrix or data frame.")
    }
    covariates <- unname(covariates)
    if (!is.double(covariates)) {
      if (is.numeric(covariates)) {
        storage.mode(covariates) <- "double"
      } else {
        new_error("`", match.call()$covariates, "` is not numeric.")
      }
    }
    if (nrow(covariates) != req_length) {
      new_error("`", match.call()$covariates, "` is not of length `", match.call()$req_length, "`.")
    }
  }
  covariates
}


# Coerce `x` to double
coerce_double <- function(x, req_length = NULL) {
  if (!is.double(x)) {
    if (is.numeric(x)) {
      x <- as.double(x)
    } else {
      new_error("`", match.call()$x, "` is not numeric.")
    }
  }
  if (!is.null(req_length) && (length(x) != req_length)) {
    new_error("`", match.call()$x, "` is not of length `", match.call()$req_length, "`.")
  }
  x
}


# Coerce `size_constraint` to scalar, non-NA integer with default as `sum(type_constraints)`
coerce_size_constraint <- function(size_constraint,
                                   sum_treatment_constraints,
                                   num_data_points) {
  if (is.null(size_constraint)) {
    size_constraint <- sum_treatment_constraints
  }
  if (length(size_constraint) != 1L) {
    new_error("`", match.call()$size_constraint, "` must be scalar.")
  }
  if (!is.integer(size_constraint)) {
    if (is.numeric_integer(size_constraint)) {
      storage.mode(size_constraint) <- "integer"
    } else {
      new_error("`", match.call()$size_constraint, "` must be integer.")
    }
  }
  if (is.na(size_constraint)) {
    new_error("`", match.call()$size_constraint, "` may not be NA.")
  }
  if (size_constraint < 2L) {
    new_error("`", match.call()$size_constraint, "` must be greater or equal to two.")
  }
  if (size_constraint < sum_treatment_constraints) {
    new_error("`", match.call()$size_constraint, "` must be greater or equal to the sum of the treatment constraints.")
  }
  if (size_constraint > num_data_points) {
    new_error("`", match.call()$size_constraint, "` may not be great than the number of units.")
  }
  size_constraint
}


# Coerce `subset` to indicator vector if character
coerce_subset <- function(subset,
                          treatments) {
  if (is.character(subset)) {
    if (anyDuplicated(subset)) {
      new_error("`", match.call()$subset, "` may not contain duplicates.")
    }
    non_exist <- !(subset %in% levels(treatments))
    if (any(non_exist)) {
      new_error("`", match.call()$subset,
                "` contains unknown treatment labels: ",
                paste0(paste0("\"", subset[non_exist], "\""), collapse = ", "),
                ".")
    }
    subset <- get_subset_indicators(subset, treatments)
  }
  subset
}


# Coerce `treatments` to factor
coerce_treatments <- function(treatments,
                              req_length) {
  if (!is.factor(treatments)) {
    if (!is.vector(treatments)) {
      new_error("Do not know how to coerce `", match.call()$treatments, "` to factor.")
    }
    if (!is.integer(treatments) && !is.character(treatments)) {
      new_warning("Coercing `", match.call()$treatments, "` to factor.")
    }
    treatments <- as.factor(treatments)
  }
  if (length(treatments) != req_length) {
    new_error("Length of `", match.call()$treatments, "` does not match distances object.")
  }
  treatments
}


# Coerce `treatment_constraints` to valid constraints
coerce_treatment_constraints <- function(treatment_constraints,
                                         treatment_levels) {
  if (is.null(names(treatment_constraints))) {
    new_error("`", match.call()$treatment_constraints, "` must be named.")
  }
  if (anyDuplicated(names(treatment_constraints))) {
    new_error("`", match.call()$treatment_constraints, "` may not contain duplicate names.")
  }
  non_exist <- !(names(treatment_constraints) %in% treatment_levels)
  if (any(non_exist)) {
    new_error("`", match.call()$treatment_constraints,
              "` contains unknown treatment labels: ",
              paste0(paste0("\"", names(treatment_constraints)[non_exist], "\""), collapse = ", "),
              ".")
  }
  if (!is.integer(treatment_constraints)) {
    if (is.numeric_integer(treatment_constraints)) {
      storage.mode(treatment_constraints) <- "integer"
    } else {
      new_error("`", match.call()$treatment_constraints, "` must be integer.")
    }
  }
  if (any(is.na(treatment_constraints))) {
    new_error("`", match.call()$treatment_constraints, "` may not contain NAs.")
  }
  if (any(treatment_constraints < 0L)) {
    new_error("`", match.call()$treatment_constraints, "` must be non-negative.")
  }
  treatment_constraints
}
