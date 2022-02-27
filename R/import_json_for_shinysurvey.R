#' @import dplyr
#' @import tidyr
#' @import stringr

import_json_for_shinysurvey <- function(){
  
  # Question logic ----------------------------------------------------------
  url <- "https://raw.githubusercontent.com/summerscope/summer-child/main/questions.json"
  question_logic <- jsonlite::fromJSON(url, flatten = TRUE) %>%
    dplyr::mutate(qn_text = text, .keep = "unused")
  columns_to_numeric <- question_logic %>%
    dplyr::mutate(dplyr::across(dplyr::ends_with("score"), ~ as.numeric(.x)),
                  dplyr::across(dplyr::ends_with("multiplier"), ~ as.numeric(.x)))
  
  questions_to_long <- columns_to_numeric %>%
    tidyr::pivot_longer(cols = starts_with("answers"),
                        names_to = c("Response", ".value"),
                        names_pattern = "answers\\.(\\w+)\\.(\\w+)"
    ) %>%
    dplyr::filter (!is.na(text))
  
  # Create required data structure for survey ---------------------------------------------------------
  
  # change column names as per shinysurveys
  survey_qns <- questions_to_long %>%
    dplyr::mutate(input_type = ifelse(Response == "Ok", "instructions", "mc"),
                  question = stringr::str_replace(qn_text,"To continue, type 'Ok'", ""),
                  option = text,
                  input_id = id,
                  required = TRUE,
                  dependence = NA,
                  dependence_value = NA,
                  page = stringr::str_extract(question, "Section #[0-9]+"),
                  .keep = "unused") %>%
    tidyr::fill(page) %>% as.data.frame()
  
  # Dependency logic --------------------------------------------------------
  
  # determine questions with dependencies
  qns_with_dependencies <- survey_qns %>%
    dplyr::select(input_id, nextq) %>%
    dplyr::group_by(input_id) %>%
    dplyr::summarise(num_nextq = dplyr::n_distinct(nextq)) %>%
    dplyr::filter(num_nextq > 1)
  
  dependencies <- survey_qns %>%
    dplyr::filter(input_id %in% qns_with_dependencies$input_id) %>%
    dplyr::select(input_id, option, nextq)
  
  # assign dependencies
  qns_id_with_depend <- sort(unique(dependencies$input_id), decreasing = FALSE)
  
  for (qn in qns_id_with_depend){
    
    question_range <- dependencies %>%
      dplyr::filter(input_id == qn) %>%
      dplyr::mutate(nextq = as.numeric(stringr::str_extract(nextq, "([0-9]+)")))
    
    next_option <- question_range %>%
      dplyr::filter(nextq == min(nextq)) %>%
      dplyr::select(option)
    
    question_ranges <- paste0("Q", min(question_range$nextq):(max(question_range$nextq - 1)))
    
    survey_qns <- survey_qns %>%
      dplyr::mutate(
        dependence = ifelse(input_id %in% question_ranges,
                            qn,
                            dependence),
        dependence_value = ifelse(input_id %in% question_ranges,
                                  next_option,
                                  dependence_value)
      )
  }
  
  return(survey_qns)
  
}
