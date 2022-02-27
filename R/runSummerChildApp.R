
#' @import shinysurveys
#' @import shiny
#' @export runSummerChildApp

runSummerChildApp <- function(){

  # Import survey questions -------------------------------------------------

  survey_qns <- import_json_for_shinysurvey()
  
  # Launch survey --------------------------------------------------------------
  
  ui <- shiny::fluidPage(
    shinysurveys::surveyOutput(df = survey_qns,
                               survey_title = "Sweet Summer Child Score (SSCS)",
                               survey_description = "SSCS is a scoring mechanism for latent risk. It will help you quickly and efficiently scan for the possibility of harm to people and communities by a socio-technical system. Note that harms to animals and the environment are not considered.
               Please note that all questions are mandatory and you will not be able to submit the survey if there are questions left uncompleted.")
  )
  
  server <- function(input, output, session) {
    renderSurvey()
    observeEvent(input$submit, {
      
      results <- readRDS("data-raw/results.RDS")
      response_data <- getSurveyData()
      assessment <- response_data %>% 
        left_join(survey_qns,
                  by = c("question_id" = "input_id", 
                         "response" = "option"  )) %>%
        select(question_id, multiplier, score) %>% 
        summarise(risk = 99 - (sum(multiplier, na.rm = TRUE) * sum(score, na.rm = T))) %>%
        pull(risk)
      
      find_score <- results %>%
        mutate(score = ifelse(assessment > min_score &
                                assessment <= max_score, T, F)) %>%
        filter(score %in% T)
      str0 = tags$span(
        assessment,
        style = "font-size: 44px;"
      )
      
      str1 = tags$span(
        paste0(find_score$title," [", find_score$score_interval, "]"),
        
        style = "font-size: 25px;"
      )
      
      # str2 = tags$span(
      #   find_score$title,
      #   style = "font-size: 25px"
      # )
      str3 = tags$span(
        find_score$description,
        style = "font-size:16px;font-weight:bold"
      )
      
      showModal(modalDialog(
        title =  'Your sweet summer child score is:',
        tagList(str0, br(), str1, br(), 
                # str2, br(),
                str3)
      ))
      
    })
  }
  
  shinyApp(ui, server)

}

