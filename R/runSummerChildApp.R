
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
    shinysurveys::renderSurvey()
    shiny::observeEvent(input$submit, {
      shiny::showModal(shiny::modalDialog(
        title = "Congrats, you completed your first shinysurvey!",
        "You can customize what actions happen when a user finishes a survey using input$submit."
      ))
      response_data <- shinysurveys::getSurveyData()
      print(response_data %>%
              dplyr::left_join(survey_qns,
                               by = c("question_id" = "input_id",
                                      "response" = "option"  )) %>%
              dplyr::select(question_id, multiplier, score) %>%
              dplyr::summarise(risk = sum(multiplier, na.rm = TRUE) * sum(score, na.rm = T)) %>%
              dplyr::pull(risk) %>%
              cat()
      )
    })
  }
  
  shiny::shinyApp(ui, server)

}

