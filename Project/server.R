# Load needed packages
suppressMessages(library(UsingR))                                                  
suppressMessages(library(ggplot2))
suppressMessages(library(dplyr))
data(father.son)

# Set up needed variables
mean_p = mean(father.son$fheight); mean_c = mean(father.son$sheight)                                              # Calculate means for parent and child's height
sum_error = 0; sum_total = 0                                                                                      # Setup variables for SSE and R^2
m = nrow(father.son)                                                                                              # Get # of observations of galton dataset

X = matrix(c(rep(1, m), father.son$fheight), nrow = m, ncol = 2, byrow = F)                                       # Create matrix contains features
y = matrix(father.son$sheight, nrow = m, ncol = 1)                              				  # Create matrix contains actual values of dependent variable
theta = matrix(nrow = 2, ncol = 1)                                        					  # Assign theta as a matrix that will contain b0 and b1
all_J = vector()                                                          					  # Assign all_J as a vector that will contain all Js depending on b0 and b1 = 0 t0 1

# Create data frame for cost.function plot
cost.data = data.frame(b1 = seq(0, 1, 1/(m-1)))                           					  # Set up b1 or slope from 0 to 1 for x-axis 
cost.data = mutate(cost.data, b0 = mean_c - (mean_p * b1))                					  # Calculate b0 or intercept depending on b1 
cost.data = as.matrix(cost.data[, c(2, 1)])                               					  # Swap column 1 and 2

# Create cost function to calculate J
cost = function(theta, X, y){
        J = (1 / (2*m)) * sum(((X %*% theta) - y)^2)                      					  # Cost function
}

# Calculate all J values with b1 = 0 to 1 for plotting cost function curve
for(i in 1:m) {
        J = cost(cost.data[i, ], X, y)
        all_J = c(all_J, J)
}
cost.data = as.data.frame(cost.data)                                      					  # Transform matrix to data frame                                    
cost.data$J = as.vector(all_J)                                            					  # Add additional column for all_J

# Shiny Server
shinyServer(
        function(input, output) {
                
# Plot scatter plot of galton dataset and linear fit line
                output$newScatter = renderPlot({
                        s = input$s                                       					  # Slope input from slider
                        intercept = mean_c - (mean_p * s)                 					  # Calculate intercept depending on slope
                        g = ggplot(data = father.son, aes(x = fheight, y = sheight))
                        g = g + geom_point(colour = "blue", size = 2, alpha = 0.2)
                        g = g + geom_abline(intercept = intercept, slope = s, colour = "red", size = 1, alpha = 0.5)
                        g = g + ggtitle("Scatter Plot of Pearson's Data Set") + 
                                xlab("Father's Height (inch)") +
                                ylab("Son's Height (inch)")
                        g
                })
                
# Plot cost function value vs. b1 or slope
                output$CostFuntion = renderPlot({
                        s = input$s                                       					  
                        theta[2] = input$s                                					  # Assign input b1 or slope to theta matrix 
                        theta[1] = mean_c - (mean_p * s)                  					  # Assign b0 or intercept to theta matrix
                        g = ggplot(data = cost.data, aes(x = b1, y = J))
                        g = g + geom_line(colour = "blue")
                        g = g + geom_point(aes(x = s, y = cost(theta, X, y)), size = 4, colour = "red") +
                                xlab("Slope b1") +
                                ylab("Cost Function Value J") +
                                ggtitle("Cost Function Value J vs. Slope")
                        g
                })
                
# Display formula of the relationship between child and parent's height
                output$f = renderText({               
                        s = input$s                                       				       
                        intercept = mean_c - (mean_p * s)                 
                        paste("Son = ", round(intercept, 2), " + ", s, " * ", "Father", sep = "")
                })
                
# Display the least sum of squared error (SSE)
                output$ls = renderText({
                        s = input$s
                        intercept = mean_c - (mean_p * s)
                        for (i in 1:m) {
                                error = (father.son$sheight[i] - (intercept + (father.son$fheight[i] * s)))^2
                                sum_error = sum_error + error
                        }
                        paste("SSE = ", round(sum_error, 2), sep = "")
                })
# Display R^2 value
                output$R2 = renderText({
                        s = input$s
                        intercept = mean_c - (mean_p * s)
                        for (i in 1:m) {
                                error = (father.son$sheight[i] - (intercept + (father.son$fheight[i] * s)))^2
                                sum_error = sum_error + error
                        }
                        for (i in 1:m) {
                                total = (father.son$sheight[i] - mean_c)^2
                                sum_total = sum_total + total
                        }
                        paste("R^2 = ", 1 - round(sum_error/sum_total, 4), sep = "")
                })
# Display cost function value J                
                output$Jvalue = renderText({
                        s = input$s                                       
                        theta[2] = input$s                                					  # Assign input b1 or slope to theta matrix 
                        theta[1] = mean_c - (mean_p * s)                  					  # Assign b0 or intercept to theta matrix
                        J.value = cost(theta, X, y)                       					  # Calculate J by "cost" function 
                        paste("J = ", round(J.value, 5), sep = "")
                })
                
# Setup actionButton feature and display correctness of the answer              
                ans = eventReactive(input$sb, {
                        input$t1
                })
                output$ans = renderText({
                        if (ans() >= 0.48 & ans() <= 0.50 | ans() >= 0.52 & ans() <= 0.54) {
                                "Good! You are close! But not its optimal fit!"
                        } else if (ans() == 0.51) {
                                "Excellent! You have found its optimal fit!"
                        } else if (ans() < 0.48 & ans() >= 0 | ans() > 0.54 & ans() <= 1) {
                                "Not its optimal fit! Try again!"
                        } else {
                                "Check Your Answer Here"
                                }
                })
        }
)