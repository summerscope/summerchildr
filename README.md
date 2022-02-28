README
================

-   [Sweet Summer Child Score](#sweet-summer-child-score)
-   [Run Summer Summer Child app to assess the risk of your
    socio-technical
    system](#run-summer-summer-child-app-to-assess-the-risk-of-your-socio-technical-system)
    -   [1. From RStudio](#1-from-rstudio)
    -   [2. From the terminal](#2-from-the-terminal)
    -   [3. If you’re having issues with remote R packages
        installation](#3-if-youre-having-issues-with-remote-r-packages-installation)

# Sweet Summer Child Score

Sweet Summer Child Score (SSCS) is a scoring mechanism for latent risk.
It will help you quickly and efficiently scan for the possibility of
harm to people and communities by a socio-technical system. This package
is an R version of Python code found at:
<https://github.com/summerscope/summerchildpy>

# Run Summer Summer Child app to assess the risk of your socio-technical system

How it looks like when you run it.

<img src="README_files/figure-gfm/unnamed-chunk-1-1.png" style="display: block; margin: auto;" />

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

Run the following code in a terminal window - **Requires R (&gt;= 2.10)
to be installed**

    R -e "devtools::install_github('summerscope/summer-child-r', force = TRUE); library(summerchildr); runSummerChildApp()"

Then simply copy and paste the `http` link that appears in the terminal
into a browser.

## 3. If you’re having issues with remote R packages installation

1. Installation through GitHub repo. 

- Clone the repository

<!-- -->

    git clone git@github.com:summerscope/summerchildr.git
    cd summerchildr

- Run the app in the terminal after restoring the environment:

<!-- -->

    R -e "renv::restore(); library(summerchildr); shiny::runApp(runSummerChildApp())"

The same commands in the chunk above can be run in R Studio to restore
the environment before running the app.

2. If 1 doesn't work (ouch!) and you're getting `HTTP error 401` OR `Bad credentials`, please try following steps.

- Open an R session on terminal, simply by typing `R` and Unset GitHUB's PAT environment variable (for context https://github.com/r-lib/devtools/issues/1566)

<!-- -->

    Sys.unsetenv("GITHUB_PAT")
    # you can confirm the above command has worked if the following command returns an empty string (i.e. `""`)
    Sys.getenv("GITHUB_PAT")

- Run the app in R session 

<!-- -->

    devtools::install_github('summerscope/summer-child-r', force = TRUE); library(summerchildr); runSummerChildApp()"
 
You're all set to dive deeper 🙌🏼


