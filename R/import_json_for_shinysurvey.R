#' Load file with risk assessment logics from https://github.com/summerscope/summerchildpy/blob/main/questions.json 
#' and parse into (1) the input format required for `shinysurveys` and the survey result categorisation.  

import_json_for_shinysurvey <- function(){
  

  # Questions ---------------------------------------------------------------

  import_qns <- import_questions_logics()
  questions_to_long <- convert_questions_logics_to_df(import_qns)
  survey_qns <- format_dependencies_logic(questions_to_long)


  # Results -----------------------------------------------------------------
  
  results <- convert_questions_logics_to_results(import_qns)
    
  return(list(survey_qns = survey_qns, results = results))
  
}


#' Load file with risk assessment logics from https://github.com/summerscope/summerchildpy/blob/main/questions.json 
#' 
#' @import dplyr
#' @importFrom jsonlite fromJSON

import_questions_logics <- function(){
  
  # Read in json data ----------------------------------------------------------
  
  url <- "https://raw.githubusercontent.com/summerscope/summer-child/main/questions.json"
  question_logic <- jsonlite::fromJSON(url, flatten = TRUE) %>%
    dplyr::mutate(qn_text = text, .keep = "unused")
  
  columns_to_numeric <- question_logic %>%
    dplyr::mutate(dplyr::across(dplyr::ends_with("score"), ~ as.numeric(.x)),
                  dplyr::across(dplyr::ends_with("multiplier"), ~ as.numeric(.x)))
  
  return(columns_to_numeric)
}

#' Format survey questions from json file into data frame required for `shinysurveys`.  
#' 
#' @import dplyr
#' @import tidyr
#' @import stringr

convert_questions_logics_to_df <- function(columns_to_numeric){
  # Question logic ----------------------------------------------------------
  
  questions_to_long <- columns_to_numeric %>%
    dplyr::select(- tidyr::starts_with("Result")) %>%
    tidyr::pivot_longer(cols = starts_with("answers"),
                        names_to = c("Response", ".value"),
                        names_pattern = "answers\\.(\\w+)\\.(\\w+)"
    ) %>%
    dplyr::filter (!is.na(text))
  
  survey_qns <- questions_to_long %>%
    dplyr::mutate(input_type = ifelse(tolower(Response) == "ok", "instructions", "mc"),
                  question = stringr::str_replace(qn_text,"To continue, type 'Ok'", ""),
                  option = text,
                  input_id = id,
                  required = FALSE,
                  dependence = NA,
                  dependence_value = NA,
                  page = stringr::str_extract(question, "Section #[0-9]+"),
                  .keep = "unused") %>%
    tidyr::fill(page) %>% as.data.frame()
  
  # Temporary fix
  survey_qns <- survey_qns %>% dplyr::filter(!(input_id %in%  "Q3"))
  survey_qns$nextq <- ifelse(survey_qns$nextq %in% "Q3", "Q4", survey_qns$nextq)
  
  return(survey_qns)
}

#' Format survey results from json file into data frame.  
#' 
#' @import dplyr
#' @import tidyr

convert_questions_logics_to_results <- function(columns_to_numeric){
  # Results logic -----------------------------------------------------------

  results <- columns_to_numeric %>% 
    dplyr::filter(tolower(id) == "results") %>%
    dplyr::select(tidyr::starts_with("result")) %>%
    tidyr::pivot_longer(cols = starts_with("result"),
                        names_to = c("Result", ".value"),
                        names_pattern = "results\\.T(\\w+)\\.(\\w+)"
    )  %>%
    dplyr::filter(!is.na(text)) %>%
    dplyr::rename(score_interval = range, description = text) %>%
    dplyr::mutate(score_interval_to_split = score_interval) %>%
    tidyr::separate(score_interval_to_split, c("min_score", "max_score")) %>%
    dplyr::mutate(min_score = as.numeric(min_score) - 1) %>% ### Fix for current results where min and max are not the same for consecutive intervals
    dplyr::select(-Result)
    
  return(results)
}

#' Given an input data frame formatted with the columns names required for `shinysurvey`, add 
#' questions dependencies. 
#' 
#' @import stringr
#' @import dplyr

format_dependencies_logic <- function(survey_qns){
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


