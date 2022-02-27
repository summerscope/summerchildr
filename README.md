README
================

-   [Sweet Summer Child Score](#sweet-summer-child-score)
-   [Run Summer Summer Child app to assess the risk of your
    socio-technical
    system](#run-summer-summer-child-app-to-assess-the-risk-of-your-socio-technical-system)
    -   [1. From RStudio](#1-from-rstudio)
    -   [2. From the terminal](#2-from-the-terminal)

# Sweet Summer Child Score

Sweet Summer Child Score (SSCS) is a scoring mechanism for latent risk.
It will help you quickly and efficiently scan for the possibility of
harm to people and communities by a socio-technical system. This package
is an R version of Python code found at:
<https://github.com/summerscope/summerchildpy>

# Run Summer Summer Child app to assess the risk of your socio-technical system

## 1. From RStudio

**Install and load the R package**

``` r
if(!require(devtools,quietly = TRUE))
  install.packages("devtools")
devtools::install_github("summerscope/summerchildr")
library(summerchildr)
```

**Run the app**

``` r
shiny::runApp(runSummerChildApp())
```

## 2. From the terminal

Clone this repository and change directory to repository folder.

    git clone git@github.com:summerscope/summerchildr.git
    cd summerchildr

Run the app

    make run

Click the `http` link that appears in the terminal.
