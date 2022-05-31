#####################################################################################
# Analyses for Paper:                                                               #
# Domain Experts about Automated Audiological Diagnostics -                         #
# Validating Machine-Predicted Common Audiological Functional Parameters (CAFPAs)   #
# as Intermediate Representation in a Clinical Decision-Support System              #
# Script authors: Andrea Hildebrandt, Mareike Buhl, Samira Saak & Gülce Akin        #
#####################################################################################

# Density Plots for Predicted and Expert CAFPAs

# clear console, objects and plots 
cat("\014")  
rm(list = ls())
# dev.off()
graphics.off()

library(ggplot2)
library(ggpubr) 
library(grid)


setwd(paste0(dirname(rstudioapi::getSourceEditorContext()$path), ""))
path_plot <- "plots/a3/"

# different audiological findings
finding <- c("high", "bb", "nh", "high+bb")

for (n in 1:4){
# load data 
expert <- read.delim(paste0("results/a2/cafpas_E1_", finding[n], ".txt"), header=TRUE)
predicted <- read.delim(paste0("results/a2/cafpas_M_", finding[n], ".txt"), header=TRUE)

# colnames
cafpas <- c("CA1", "CA2", "CA3", "CA4", "CU1", "CU2", "CB", "CN", "CC", "CE")

# general plot settings
col_breaks = c(seq(0,0.3,length=100),       # for green
               seq(0.31,0.7,length=100),    # for yellow
               seq(0.71,1,length=100))      # for red 

my_palette <- colorRampPalette(c("#006401", "#FCD402", "#B12322"))(n = 100)
g <- rasterGrob(t(my_palette), width=unit(1,"npc"), height = unit(1,"npc"), interpolate = TRUE)

axis_size = 80
line_size = 3
y_lim <- c(0,8)
x_lim <- c(0,1)
bandwidth = 0.015
axis_x <- element_blank()
axis_rf <- element_text(face = "bold", size = axis_size, color = "black")
plot_width <- 600
plot_height <- 600


# density plots for model-predicted and expert-validated CAFPAs ---------------------------------------
for (i in 1:10){
  if (i == 1){axis_y = element_text(face = "bold", size = axis_size, color = "black")
  } else {axis_y = element_blank()}
  # expert-validated CAFPAs
  png(paste0(path_plot,"E1_", cafpas[i], "_", finding[n], ".png"), width = plot_width, height = plot_height)
  print(ggplot(expert, aes_string(x = cafpas[i])) + 
          annotation_custom(g, xmin=-Inf, xmax=Inf, ymin=-Inf, ymax=Inf) +
          geom_density(size = line_size, bw = bandwidth) + 
          geom_vline(aes(xintercept=median(expert[,i], na.rm = TRUE)),
                     color="black", linetype="dashed", size=1) +
          theme(axis.line = element_line(colour = "black", size = line_size, linetype = "solid"),
                axis.text.x= axis_x, 
                axis.text.y= axis_y,
                plot.background = element_rect(fill = "#E6E6E6")) + 
          labs(x = "", y = "") + 
          xlim(x_lim) + 
          if ( i == 1){scale_y_continuous(breaks = y_lim, limits = y_lim)} else {ylim(y_lim)} 
        
  )
  dev.off()
  
  # model-predicted CAFPAs 
  png(paste0(path_plot,"M_", cafpas[i], "_", finding[n], ".png"), width = plot_width, height = plot_height)
  print(ggplot(predicted, aes_string(x = cafpas[i])) + 
          annotation_custom(g, xmin=-Inf, xmax=Inf, ymin=-Inf, ymax=Inf) +
          geom_density(size = line_size, bw = bandwidth) + 
          geom_vline(aes(xintercept=median(predicted[,i], na.rm = TRUE)),
                     color="black", linetype="dashed", size=1) +
          theme(axis.line = element_line(colour = "black", size = line_size, linetype = "solid"),
                axis.text.x= axis_x, 
                axis.text.y= axis_y,
                plot.background = element_rect(fill = "#E6E6E6")) + 
          labs(x = "", y = "") + 
          xlim(x_lim) + 
          if ( i == 1){scale_y_continuous(breaks = y_lim, limits = y_lim)} else {ylim(y_lim)} 
        
  )
  dev.off()
}
}
