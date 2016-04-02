library(shiny)
shinyUI(pageWithSidebar(
        headerPanel("Linear Fit for Pearson's Data Set"),
        sidebarPanel(
                helpText("This Shiny app is about finding the optimal linear fit for Pearson's data set by finding the minimum point of Cost Function curve! 
                         Use slider to change slope and try to find the least Cost Function Value J and highest R^2."),
                helpText("(Note: Cost Function J is just Sum of Squared Error divided by number of total observation.)"),
                sliderInput("s", "Slope Slider", value = 0, min = 0, max = 1, step = 0.01),
                h5("Formula: y = b0 + b1 * x"),
                helpText("where b1 is slope of the red line"),
                verbatimTextOutput("f"),
                h5("Sum of Squared Error"),
                verbatimTextOutput("ls"),
                h5("Cost Function Value J"),
                verbatimTextOutput("Jvalue"),
                h5("R Squared Value"),
                verbatimTextOutput("R2"),
                br(),
                helpText("Type in the slope you find to see if it is the best fit"),
                textInput("t1", label = "Slope:"),
                actionButton("sb", "Submit"),
                h5("Answer"),
                verbatimTextOutput("ans"),
                img(src = "images.jpg", height = 50, width = 50),
                "Programmed by Brian Wang from Taiwan, March 2016"
        ),
        mainPanel(
                plotOutput("newScatter"),
                plotOutput("CostFuntion")
        )
))