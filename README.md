README
================

-   [Run Summer Child app](#run-summer-child-app)
    -   [From RStudio](#from-rstudio)
    -   [From the terminal](#from-the-terminal)

# Run Summer Child app

## From RStudio

**Install and load the R package**

``` r
devtools::install_github("summerscope/summer-child-r")
library(SummerChildR)
```

**Run the app**

``` r
shiny::runApp(runSummerChildApp())
```

## From the terminal

    make run

And click on the `http` link that appears in the terminal.
