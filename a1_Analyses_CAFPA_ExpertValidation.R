#####################################################################################
# Analyses for Paper:                                                               #
# Domain Experts about Automated Audiological Diagnostics -                         #
# Validating Machine-Predicted Common Audiological Functional Parameters (CAFPAs)   #
# as Intermediate Representation in a Clinical Decision-Support System              #
# Script authors: Andrea Hildebrandt, Mareike Buhl, Samira Saak & Gülce Akin        #
#####################################################################################

# clear console, objects and plots 
cat("\014")  
rm(list = ls())
dev.off()

##################
# Prepare
##################

# Packages
if (!require(tidyverse)) install.packages('tidyverse')
if (!require(car)) install.packages('car')
if (!require(reshape)) install.packages('reshape')
if (!require(ggplot2)) install.packages('ggplot2')
if (!require(cowplot)) install.packages('cowplot')
if (!require(ggpubr)) install.packages('ggpubr')
if (!require(patchwork)) install.packages('patchwork')
if (!require(esquisse)) install.packages('esquisse')
if (!require(psych)) install.packages('psych')
if (!require(Hmisc)) install.packages('Hmisc')
if (!require(lme4)) install.packages('lme4')
if (!require(lmerTest)) install.packages('lmerTest')
if (!require(gridExtra)) install.packages('gridExtra')
if (!require(gridtext)) install.packages('gridtext')

library(tidyverse)
library(car)
library(reshape)
library(ggplot2)
library(cowplot)
library(ggpubr)
library(patchwork)
library(esquisse)
library(psych)
library(Hmisc)
library(lme4)
library(lmerTest)
library(gridExtra)
library(gridtext)

##################################################################################
# Read data
# Note: Data processing and organisation was carried out on Matlab (see: s0-s9_)
##################################################################################

setwd(paste0(dirname(rstudioapi::getSourceEditorContext()$path), "/Datasets/"))

dat_cor <- read.delim("DATA_correlation.txt", header=TRUE)
head(dat_cor)

# check
summary(dat_cor)
CAFPAs = colnames(dat_cor[,grepl("C", colnames(dat_cor))])
CAFPAs = dat_cor[, CAFPAs] 
sapply(seq_len(ncol(CAFPAs)),function(i) hist(CAFPAs[,i],main=colnames(CAFPAs)[i],xlab="x"))

# load data
dat_ICC_all <- read.delim("DATA_for_ICC.txt", header=TRUE)
head(dat_ICC_all)

dat_ICC_E1_M <- read.delim("DATA_for_ICC_E1_M.txt", header=TRUE)
head(dat_ICC_E1_M)

dat_ICC_withinE1 <- read.delim("DATA_for_stability_Expert1.txt", header=TRUE)
head(dat_ICC_withinE1)

dat_ICC_withinE2 <- read.delim("DATA_for_stability_Expert2.txt", header=TRUE)
head(dat_ICC_withinE2)

dat_LMM <- read.delim("150_sub_meas_MLM_nan.txt", header=TRUE)
head(dat_LMM)

# survey data

dat_conf <- read.delim("survey-confidence.txt", header=TRUE)
head(dat_conf) 

dat_meas <- read.delim("survey-cafpas-measurements.txt", header=TRUE)
head(dat_meas) 

dat_appr <- read.delim("survey-expert-approach.txt", header=TRUE)
head(dat_appr) 

##############################################################################################################
# Analyses
# RQ1: Do the audiology experts agree with the CAFPAs predicted by machine learning models?
##############################################################################################################

# ICC
calculate_ICC = function(dat_ICC_all, CAFPA, timevar){
  VarsICC_C <- names(dat_ICC_all) %in% c("Subject", timevar,CAFPA) 
  ICCEM_C <- dat_ICC_all[VarsICC_C]
  print(head(ICCEM_C))
  ICCEM_Cw <- reshape(ICCEM_C, idvar = "Subject", timevar = timevar, direction = "wide")
  ICCEM_Cw <- subset(ICCEM_Cw, select = -Subject )
  print(head(ICCEM_Cw))
  ICC_res = ICC(ICCEM_Cw, missing=TRUE, alpha=.05)
  print(ICC_res)
  
  res = list(VarsICC_C = VarsICC_C,
             ICCEM_C = ICCEM_C,
             ICCEM_Cw = ICCEM_Cw,
             ICC_res = ICC_res)
  return(res)
}

##############################################################################################################
# 1a Relative agreement between M and Experts - based on 15 patients
# ICC 
# ICC3: Two-way mixed effects model. Here the raters are considered as fixed. 
# with dat_ICC_all


M_Experts_agreement.res = list()
for (cafpa in c("CA1", "CA2", "CA3", "CA4", "CU1", "CU2", "CB", "CN", "CC", "CE")){
  
  M_Experts_agreement.res[[cafpa]] = calculate_ICC(dat_ICC_all, cafpa, "Evaluator")
  
}

###########################################################################################################
# 1b Relative agreement between M and Expert 1 - based on 150 patients
# ICC + scatterplots
# with dat_ICC_E1_M

# ICC
M_E1_agreement.res = list()
for (cafpa in c("CA1", "CA2", "CA3", "CA4", "CU1", "CU2", "CB", "CN", "CC", "CE")){
  
  M_E1_agreement.res[[cafpa]] = calculate_ICC(dat_ICC_E1_M, cafpa, "Evaluator")
  
}

# Scatterplot

png("ScatterplotM_E1.png", width = 1200, height = 400)

CME1 = list()
for (cafpa in c("CA1", "CA2", "CA3", "CA4", "CU1", "CU2", "CB", "CN", "CC", "CE")){
  
  CME1[[cafpa]] = ggplot(M_E1_agreement.res[[cafpa]][["ICCEM_Cw"]],
                         aes_string(x = paste0(cafpa,".M"), y = paste0(cafpa,".E1"))) +
    geom_abline(color = "grey", linetype = "dotted")+
    geom_point(shape = "circle open", size = 1.35, colour = "#112446") + 
    geom_smooth(method = "lm", colour = "blue") + labs(x = "M", y = "E1") +
    labs(title = cafpa) +
    annotate("text", x = 0.5,y= 1, label = cafpa,fontface=2, size=5)+
    theme_bw() +
    theme(plot.title = element_blank(), 
          plot.margin=margin(l=1,r=1),
          text = element_text(size = 15),
          axis.title.y = element_blank(),
          axis.title.x = element_blank())+
    ylim(0,1)+xlim(0,1)
  
  
}

yleft = richtext_grob('**E1**', rot=90, hjust=-1)
bottom = richtext_grob(text = '**M**', hjust =-1.5)

grid.arrange(CME1$CA1 + theme(plot.margin=margin(r=1),axis.text.x = element_blank(), axis.title.x = element_blank(),axis.ticks.x = element_blank()), 
             CME1$CA2 + theme(axis.text.y = element_blank(), axis.title.y = element_blank(), axis.ticks = element_blank(),axis.text.x = element_blank(), axis.title.x = element_blank()),
             CME1$CA3 + theme(axis.text.y = element_blank(), axis.title.y = element_blank(), axis.ticks = element_blank(),axis.text.x = element_blank(), axis.title.x = element_blank()),
             CME1$CA4 + theme(axis.text.y = element_blank(), axis.title.y = element_blank(), axis.ticks = element_blank(),axis.text.x = element_blank(), axis.title.x = element_blank()),
             CME1$CU1 + theme(axis.text.y = element_blank(), axis.title.y = element_blank(), axis.ticks = element_blank(),axis.text.x = element_blank(), axis.title.x = element_blank()),
             CME1$CU2 + theme(plot.margin=margin(r=1)),
             CME1$CB + theme(axis.text.y = element_blank(), axis.title.y = element_blank(), axis.ticks.y = element_blank()),
             CME1$CN + theme(axis.text.y = element_blank(), axis.title.y = element_blank(), axis.ticks.y = element_blank()),
             CME1$CC + theme(axis.text.y = element_blank(), axis.title.y = element_blank(), axis.ticks.y = element_blank()),
             CME1$CE + theme(axis.text.y = element_blank(), axis.title.y = element_blank(), axis.ticks.y = element_blank()),
             ncol = 5, nrow = 2,
             left = yleft, bottom = bottom,
             widths = c(1.15,1,1,1,1),
             heights = c(1,1.1)
)

dev.off()

###########################################################################################################
# 1c Stability of experts' ratings
# ICC + scatterplots (in the supplement)

# ICC for agreement
dat_ICC_E1 <- dat_ICC_all[which(dat_ICC_all$Evaluator=='E1'), ]
dat_ICC_E2 <- dat_ICC_all[which(dat_ICC_all$Evaluator=='E2'), ]
dat_ICC_E1E2 <- rbind(dat_ICC_E1, dat_ICC_E2)
head(dat_ICC_E1E2)


# ICC
E1E2_agreement.res = list()
for (cafpa in c("CA1", "CA2", "CA3", "CA4", "CU1", "CU2", "CB", "CN", "CC", "CE")){
  
  E1E2_agreement.res[[cafpa]] = calculate_ICC(dat_ICC_E1E2, cafpa, "Evaluator")
  
}


# Scatterplot

png("ScatterplotE1_E2-non-agreement.png", width = 500, height = 400)

CE1E2 <- list()
for (cafpa in c("CU1", "CB", "CN", "CC")){

  CE1E2[[cafpa]] <- ggplot(E1E2_agreement.res[[cafpa]]$ICCEM_Cw, aes_string(x = paste0(cafpa,".E1"), y = paste0(cafpa,".E2"))) +
    geom_point(shape = "circle open", size = 1.35, colour = "#112446") + 
    geom_smooth(method = "lm", colour = "blue") +
    labs(x = "E1", y = "E2") +labs(title = cafpa) +
    annotate("text", x = 0.5,y= 1, label = cafpa,fontface=2, size=5)+
    theme_bw() + 
    theme(plot.title = element_blank(), 
          plot.margin=margin(l=1,r=1),
          text = element_text(size = 15),
          axis.title.y = element_blank(),
          axis.title.x = element_blank())+
    xlim(0, 1) + ylim(0, 1)

}
  

yleft = richtext_grob('**E2**', rot=90, hjust=-1)
bottom = richtext_grob(text = '**E1**', hjust =-0.8)

grid.arrange(CE1E2$CU1+ theme(plot.margin=margin(r=1),axis.text.x = element_blank(), axis.title.x = element_blank(),axis.ticks.x = element_blank()), 
             CE1E2$CB + theme(axis.text.y = element_blank(), axis.title.y = element_blank(), axis.ticks = element_blank(),axis.text.x = element_blank(), axis.title.x = element_blank()),
             CE1E2$CN + theme(plot.margin=margin(r=1)),
             CE1E2$CC + theme(axis.text.y = element_blank(), axis.title.y = element_blank(), axis.ticks.y = element_blank()),
             ncol = 2, nrow = 2,
             left = yleft, bottom = bottom,
             widths = c(1.15,1),
             heights = c(1,1.1)
)

dev.off()

# ICC for stability E1 with dat_ICC_withinE1
head(dat_ICC_withinE1)
nrow(dat_ICC_withinE1)

withinE1_agreement.res = list()
for (cafpa in c("CA1", "CA2", "CA3", "CA4", "CU1", "CU2", "CB", "CN", "CC", "CE")){
  
  withinE1_agreement.res[[cafpa]] = calculate_ICC(dat_ICC_withinE1, cafpa, "Session")
  
}

# Scatterplot for supplement

png("ScatterplotE1_E1.png", width = 1200, height=400)

CwithinE1 <- list()
for (cafpa in c("CA1", "CA2", "CA3", "CA4", "CU1", "CU2", "CB", "CN", "CC", "CE")){
  
  CwithinE1[[cafpa]] <- ggplot(withinE1_agreement.res[[cafpa]]$ICCEM_Cw, aes_string(x = paste0(cafpa,".1"), y = paste0(cafpa,".2"))) +
    geom_point(shape = "circle open", size = 1.35, colour = "#112446") + 
    geom_smooth(method = "lm", colour = "blue") + 
    labs(x = "E1", y = "E2") +labs(title = cafpa) +
    theme_bw() + 
    labs(title = cafpa) +
    annotate("text", x = 0.5,y= 1, label = cafpa,fontface=2, size=5)+
    theme_bw() +
    theme(plot.title = element_blank(), 
          plot.margin=margin(l=1,r=1),
          text = element_text(size = 15),
          axis.title.y = element_blank(),
          axis.title.x = element_blank())+
    xlim(0, 1) + ylim(0, 1)
  
}

yleft = richtext_grob('**E2**', rot=90, hjust=-1)
bottom = richtext_grob(text = '**E1**', hjust =-0.5)

grid.arrange(CwithinE1$CA1 + theme(plot.margin=margin(r=1),axis.text.x = element_blank(), axis.title.x = element_blank(),axis.ticks.x = element_blank()), 
             CwithinE1$CA2 + theme(axis.text.y = element_blank(), axis.title.y = element_blank(), axis.ticks = element_blank(),axis.text.x = element_blank(), axis.title.x = element_blank()),
             CwithinE1$CA3 + theme(axis.text.y = element_blank(), axis.title.y = element_blank(), axis.ticks = element_blank(),axis.text.x = element_blank(), axis.title.x = element_blank()),
             CwithinE1$CA4 + theme(axis.text.y = element_blank(), axis.title.y = element_blank(), axis.ticks = element_blank(),axis.text.x = element_blank(), axis.title.x = element_blank()),
             CwithinE1$CU1 + theme(axis.text.y = element_blank(), axis.title.y = element_blank(), axis.ticks = element_blank(),axis.text.x = element_blank(), axis.title.x = element_blank()),
             CwithinE1$CU2 + theme(plot.margin=margin(r=1)),
             CwithinE1$CB + theme(axis.text.y = element_blank(), axis.title.y = element_blank(), axis.ticks.y = element_blank()),
             CwithinE1$CN + theme(axis.text.y = element_blank(), axis.title.y = element_blank(), axis.ticks.y = element_blank()),
             CwithinE1$CC + theme(axis.text.y = element_blank(), axis.title.y = element_blank(), axis.ticks.y = element_blank()),
             CwithinE1$CE + theme(axis.text.y = element_blank(), axis.title.y = element_blank(), axis.ticks.y = element_blank()),
             ncol = 5, nrow = 2,
             left = yleft, bottom = bottom,
             widths = c(1.15,1,1,1,1),
             heights = c(1,1.1)
)

dev.off()

# ICC for stability E2 with dat_ICC_withinE2
head(dat_ICC_withinE2)
nrow(dat_ICC_withinE2)
180/15

withinE2_agreement.res = list()
for (cafpa in c("CA1", "CA2", "CA3", "CA4", "CU1", "CU2", "CB", "CN", "CC", "CE")){
  
  withinE2_agreement.res[[cafpa]] = calculate_ICC(dat_ICC_withinE2, cafpa, "Session")
  
}


###########################################################################################################
# 1d Absolute agreement between M and Expert 1
# LMM (without patient level predictors)


calculate_LMM = function(dat_LMM, cafpa){
  cafpa_rs = paste0(cafpa, "_rs")
mC <- lmer(dat_LMM[[cafpa_rs]] ~ Evaluator + (1|Subject), data=dat_LMM)  
print(summary(mC))
print(confint(mC))

mCp <- ggplot(data=dat_LMM, aes_string(x="EvaluatorL2" , y=cafpa_rs, group = "Subject")) + geom_line(aes(color=Subject)) + geom_point(aes(color=Subject)) + theme_bw() +labs(x = "Evaluator", y = cafpa)
mCp <- mCp + theme(legend.position="none")

return(mCp)
}

# with dat_LMM
head(dat_LMM)

# rescale the CAFPA range, instead 0-1, 1-100
dat_LMM$CA1_rs <- 100 * dat_LMM$CA1
dat_LMM$CA2_rs <- 100 * dat_LMM$CA2
dat_LMM$CA3_rs <- 100 * dat_LMM$CA3
dat_LMM$CA4_rs <- 100 * dat_LMM$CA4
dat_LMM$CU1_rs <- 100 * dat_LMM$CU1
dat_LMM$CU2_rs <- 100 * dat_LMM$CU2
dat_LMM$CB_rs <- 100 * dat_LMM$CB
dat_LMM$CN_rs <- 100 * dat_LMM$CN
dat_LMM$CC_rs <- 100 * dat_LMM$CC
dat_LMM$CE_rs <- 100 * dat_LMM$CE

dat_LMM$EvaluatorL2 <- ifelse(dat_LMM$Evaluator == 0, c("0=M"), c("1=E1"))

mCp_plots = list()
for (cafpa in c("CA1", "CA2", "CA3", "CA4", "CU1", "CU2", "CB", "CN", "CC", "CE")){
  mCp_plots[[cafpa]] =calculate_LMM(dat_LMM, cafpa)
}

png("AbsoluteDifferencePatients.png", width = 1000, height=600)
plot_grid(plotlist = mCp_plots) 
dev.off()

plot_grid(mCp_plots$CA1, mCp_plots$CA2)
plot_grid(mCp_plots$CA3, mCp_plots$CA4)
plot_grid(mCp_plots$CU1, mCp_plots$CU2)
plot_grid(mCp_plots$CB, mCp_plots$CN)
plot_grid(mCp_plots$CC, mCp_plots$CE)

dev.off()

###############################################################################################
# RQ2: 2.	Is the potential disagreement between expert- and machine-estimated CAFPAs depending 
# on the measurement data of the patients? 
###############################################################################################

# with dat_LMM

CLMM.res = lapply(dat_LMM[,27:36], function(x) lmer(x ~ Evaluator + PTA + m.age + m.gender + m.swi_sum + 
                                   m.goesa_srt + m.wst_raw + m.demtect + m.tinnitus_ri + m.tinnitus_le +
                                   m.acalos_1_5_worst_L2_5 + m.acalos_1_5_worst_L50 + m.acalos_4_worst_L2_5 +
                                   PTA*Evaluator + m.age*Evaluator + m.gender*Evaluator + m.swi_sum*Evaluator + 
                                   m.goesa_srt*Evaluator + m.wst_raw*Evaluator + m.demtect*Evaluator + m.tinnitus_ri*Evaluator + m.tinnitus_le*Evaluator +
                                   m.acalos_1_5_worst_L2_5*Evaluator + m.acalos_1_5_worst_L50*Evaluator + m.acalos_4_worst_L2_5*Evaluator + 
                                   (1|Subject), data=dat_LMM)   )

lapply(CLMM.res, summary)
lapply(CLMM.res, confint)


