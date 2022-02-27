run:
	R -e "devtools::install_github('summerscope/summer-child-r', force = TRUE);library(summerchildr); shiny::runApp(runSummerChildApp())"
