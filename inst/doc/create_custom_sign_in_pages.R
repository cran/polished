## ---- include = FALSE---------------------------------------------------------
knitr::opts_chunk$set(
  collapse = TRUE,
  comment = "#>"
)

## ---- eval = FALSE------------------------------------------------------------
#  sign_in_module()
#  sign_in_module_2()

## ---- eval = FALSE------------------------------------------------------------
#  sign_in_js()
#  sign_in_check_jwt()

## ---- eval = FALSE------------------------------------------------------------
#  library(shiny)
#  library(polished)
#  
#  
#  my_custom_sign_in_module_ui <- function(id) {
#    ns <- NS(id)
#  
#    tagList(
#      shinyjs::useShinyjs(),
#      # your custom sign in inputs
#  
#      div(
#        id = ns("sign_in_page"),
#        email_input(
#          ns("sign_in_email")
#        ),
#        password_input(
#          ns("sign_in_password")
#        ),
#        actionButton(
#          ns("sign_in_submit"),
#          "Sign In"
#        ),
#        actionLink(
#          ns("go_to_register"),
#          "Not a member? Register!"
#        )
#      ),
#  
#      # your custom registration inputs.  Your inputs
#      shinyjs::hidden(
#        div(
#          id = ns("register_page"),
#          password_input(
#            ns("register_password")
#          ),
#          password_input(
#            ns("register_password_verify")
#          ),
#          actionButton(
#            ns("register_submit"),
#            "Register"
#          ),
#          actionLink(
#            ns("go_to_sign_in"),
#            "Already a member? Sign in!"
#          )
#        )
#      ),
#  
#  
#      # make sure to call this function somewhere in your sign in page UI.  It loads
#      # the JavaScript used in the sign in and registration process.
#      sign_in_js(ns)
#    )
#  
#  }
#  
#  my_custom_sign_in_module <- function(input, output, session) {
#    ns <- session$ns
#    # your custom sign in and registration server logic
#    # We provide an example showing the sign in & registration pages separately
#  
#    # show the registration inputs & button
#    observeEvent(input$go_to_register, {
#      shinyjs::hideElement("sign_in_page")
#      shinyjs::showElement("register_page")
#    })
#  
#    # show the sign in inputs & button
#    observeEvent(input$go_to_sign_in, {
#      shinyjs::hideElement("register_page")
#      shinyjs::showElement("sign_in_page")
#    })
#  
#    jwt <- reactive({
#      # optional: include additional authorization checks here
#      input$check_jwt
#    })
#  
#    sign_in_check_jwt(jwt)
#  }
#  
#  ui <- secure_ui(
#    ui = fluidPage(
#      h1("I am a Shiny app!")
#    ),
#    # you must pass "sign_in" sign in to your custom module `id` argument
#    # as done below:
#    sign_in_page_ui = my_custom_sign_in_module_ui("sign_in")
#  )
#  
#  server <- secure_server(
#    server = function(input, output, session) {},
#    custom_sign_in_server = my_custom_sign_in_module
#  )
#  
#  
#  shinyApp(
#    ui,
#    server,
#    onStart = function() {
#      global_sessions_config(
#        api_key = "<your polished.tech API key>",
#        app_name = "<your app name from polished.tech>"
#      )
#    }
#  )
#  

