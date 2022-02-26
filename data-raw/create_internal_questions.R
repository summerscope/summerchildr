library(dplyr)

# Removed Q3 - second multiplier
dat <- jsonlite::fromJSON("questions_reduced.json", flatten = TRUE) %>%
  mutate(qn_text = text, .keep = "unused")

usethis::use_data(dat, internal = TRUE)
