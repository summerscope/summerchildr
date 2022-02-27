
#' @import shinysurveys
#' @import shiny
#' @import dplyr
#' @export runSummerChildApp

runSummerChildApp <- function(){

  # Import survey questions -------------------------------------------------

  json_output <- import_json_for_shinysurvey()   
  survey_qns <- json_output$survey_qns
  results <- json_output$results
  
  # Launch survey --------------------------------------------------------------
  
  ui <- shiny::fluidPage(
    shinysurveys::surveyOutput(df = survey_qns,
                               survey_title = "Sweet Summer Child Score (SSCS)",
                               survey_description = "SSCS is a scoring mechanism for latent risk. It will help you quickly and efficiently scan for the possibility of harm to people and communities by a socio-technical system. Note that harms to animals and the environment are not considered.
               Please note that all questions are mandatory and you will not be able to submit the survey if there are questions left uncompleted.")
  )
  
  server <- function(input, output, session) {
    shinysurveys::renderSurvey()
    shiny::observeEvent(input$submit, {
      response_data <- shinysurveys::getSurveyData()
      assessment <- response_data %>% 
        dplyr::left_join(survey_qns,
                  by = c("question_id" = "input_id", 
                         "response" = "option"  )) %>%
        dplyr::select(question_id, multiplier, score) %>% 
        dplyr::summarise(risk = 99 - (sum(multiplier, na.rm = TRUE) * sum(score, na.rm = T))) %>%
        dplyr::pull(risk)
      
      recs <- response_data %>% 
        dplyr::left_join(survey_qns,
                  by = c("question_id" = "input_id", 
                         "response" = "option"  )) %>%
        dplyr::select(recommendation) %>% 
        dplyr::filter(!(is.na(recommendation)) & !recommendation %in% "" ) 
      recs <- ifelse(nrow(recs) == 0,
                     "No recommendations at this stage",
                     paste(recs$recommendation , sep = "\n"))
      
      find_score <- results %>%
        dplyr::mutate(score = ifelse(assessment > min_score &
                                assessment <= max_score, T, F)) %>%
        dplyr::filter(score %in% T)
      str0 = tags$span(
        "Your sweet summer child score is:    ",
        style = "font-size: 25px;"
      )
      str1 <- tags$span(
        assessment,
        style = "font-size: 44px;")
      
      str2 = tags$span(
        paste0(find_score$title," [", find_score$score_interval, "]"),
        style = "font-size: 25px;"
      )
      
      str3 = tags$span(
        find_score$description,
        style = "font-size:16px"
      )
      
      str4 = tags$span(
        "Recommendations for improving your score:",
        style = "font-size:25px"
      )
      
      str5 = tags$span(
        p(HTML(paste("<ul><li>", paste(recs, collapse = "</li><li>"), "</li>"))),
        style = "font-size:16px"
      )
      shiny::showModal(shiny::modalDialog(
        title =  'Results',
        tagList(str0, str1, br(), br(), hr(),br(), str2, br(), br(),
                str3, br(), br(), hr(),br(), str4, str5)
      ))
      
    })
  }
  
  shiny::shinyApp(ui, server)

}

