#' Perform post hoc analysis based on residuals of Pearson's Chi-squared Test for Count Data.
#'
#' @param x A matrix passed on to the chisq.test function.
#' @param method The p adjustment method to be used. This is passed on to the p.adjust function.
#' @param round Number of digits to round the p.value to. Defaults to 6.
#' @param ... Additional arguments passed on to the chisq.test function.
#'
#' @return A table with the adjusted p value for each x y combination.
#' @examples
#' # Data from Agresti(2007) p.39
#' M <- as.table(rbind(c(762, 327, 468), c(484, 239, 477)))
#' dimnames(M) <- list(gender = c("F", "M"),
#'                    party = c("Democrat","Independent", "Republican"))
#'
#' # Pass data matrix to chisq.posthoc.test function
#' chisq.posthoc.test(M)
#' @references
#' Agresti, A. (2007). \emph{An Introduction to Categorical Data Analysis}, 2nd
#' ed. New York: John Wiley & Sons. Page 38.
#'
#' Beasley, T. M., & Schumacker, R. E. (1995). Multiple Regression Approach
#' to Analyzing Contingency Tables: Post Hoc and Planned Comparison
#' Procedures. \emph{The Journal of Experimental Education}, 64(1), 79--93.
#' @importFrom stats chisq.test p.adjust pchisq
#' @export

chisq.posthoc.test <-
  function(x,
           method = "bonferroni",
           round = 6,
           ...) {
    # Perform the chi square test and save the residuals
    stdres <- chisq.test(x, ...)$stdres
    # Calculate the chi square values based on the residuls
    chi_square_values <- stdres ^ 2
    # Get the p values for the chi square values
    p_values <- pchisq(chi_square_values, 1, lower.tail = FALSE)
    # Adjust the p values with the chosen method
    adjusted_p_values <- p_values
    for (i in 1:nrow(adjusted_p_values)) {
      adjusted_p_values[i, ] <- p.adjust(
        adjusted_p_values[i, ],
        method = method,
        n = ncol(adjusted_p_values) * nrow(adjusted_p_values)
      )
    }
    # Round the adjusted p values
    adjusted_p_values <- round(adjusted_p_values, digits = round)
    # Convert stdres and adjusted p values into data frames
    stdres <- as.data.frame.matrix(stdres)
    adjusted_p_values <- as.data.frame.matrix(adjusted_p_values)
    # Combine residuals and p values into one table
    results <-
      as.data.frame(matrix(
        data = NA,
        nrow = nrow(adjusted_p_values) * 2,
        ncol = ncol(adjusted_p_values) + 2
      ))
    odd_rows <- seq(1, nrow(results), 2)
    even_rows <- seq(2, nrow(results), 2)
    results[odd_rows, c(3:ncol(results))] <- stdres
    results[even_rows, c(3:ncol(results))] <- adjusted_p_values
    results[odd_rows, 2] <- "Residuals"
    results[even_rows, 2] <- "p values"
    colnames <- dimnames(x)[[2]]
    colnames <- append(colnames, c("Dimension", "Value"), after = 0)
    colnames(results) <- colnames
    rownames <- dimnames(x)[[1]]
    results[odd_rows, 1] <- rownames
    results[even_rows, 1] <- rownames
    # Return the results
    results
  }
