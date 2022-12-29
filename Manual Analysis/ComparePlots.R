#Will check to see if the required packages are installed and if not, will install them
packages <- c("GenomicFeatures", "dplyr", "tidyr", "ggplot2", "patchwork", "plotly", "stringr", "tidyverse", "tibble", "dtwclust")
check.package <- function(package){
  if(!(package %in% installed.packages())) install.packages(package)
}
sapply(packages, check.package)
sapply(packages, require, character.only = T)

wd <- setwd('/Users/andrewd/Desktop/TimeLapse_Focianalysis/10.For analysis (aligned)/Stationary/')

Induced <- read.csv('3780_stat_with_copper/Outputs/AvgCell_intensity.csv')
NonInduced <- read.csv('3780_stat_no_copper/Outputs/AvgCell_intensity.csv')



#=======================================================
# Format Induced data frame
Induced <- Induced[, -c(1:2)]
InducedNames <- paste("Induced", colnames(Induced),  sep = "_")
colnames(Induced) <- InducedNames
names(Induced)[1]<-paste("Time")

# Format NON-Induced data frame
NonInduced <- NonInduced[, -c(1:2)]
NonInducedNames <- paste("NonInduced", colnames(NonInduced),  sep = "_")
colnames(NonInduced) <- NonInducedNames
names(NonInduced)[1]<-paste("Time")


#Merge the two dataframes
MergedDFs <- merge(Induced, NonInduced, by = "Time", all = TRUE)

#Scaling the dataframes so nonInduced = 0
MergedDFs$Ch1ScaleFactor <- 0-(MergedDFs$NonInduced_AverageINT_Ch1)
MergedDFs$Ch1_nonInd_Scaled <- MergedDFs$NonInduced_AverageINT_Ch1 + MergedDFs$Ch1ScaleFactor
MergedDFs$Ch1_Ind_Scaled <- MergedDFs$Induced_AverageINT_Ch1 + MergedDFs$Ch1ScaleFactor

MergedDFs$Ch2ScaleFactor <- 0-(MergedDFs$NonInduced_AverageINT_Ch2)
MergedDFs$Ch2_nonInd_Scaled <- MergedDFs$NonInduced_AverageINT_Ch2 + MergedDFs$Ch2ScaleFactor
MergedDFs$Ch2_Ind_Scaled <- MergedDFs$Induced_AverageINT_Ch2 + MergedDFs$Ch2ScaleFactor

##### PLOTS ###
#Generates and outputs a plot superimposing average intensities of Channel 1 and Channel 2
Ch1 <- ggplot(MergedDFs, aes(x=Time, y=`NonInduced_AverageINT_Ch1`, color="No Induction (Ch1)")) +
  geom_smooth( se=FALSE) +
  ggtitle("Average Normalized Foci Intensity") +
  ylab("Normlized Mean Intensity") +
  xlab("Time (s)") +
  #ylim(-0.025, 0.025) +
  xlim(0, 200) +
  geom_vline(xintercept=0, linetype="dashed", color = "Darkgrey") +
  geom_vline(xintercept=15, linetype="solid", color = "Darkgrey") +
  theme(legend.position = "none", axis.text.x = element_text(angle = 90, vjust = 0.5, hjust=0.5), plot.title = element_text(hjust = 0.5)) +
  geom_smooth(mapping =aes(x=Time, y=`Induced_AverageINT_Ch1`,color = "Induction (Ch1)"), se=FALSE) +
  scale_colour_manual(name = "", 
                      values = c("No Induction (Ch1)" = "darkgrey", 
                                 "Induction (Ch1)" = "Chartreuse3"))

Ch2 <- ggplot(MergedDFs, aes(x=Time, y=`NonInduced_AverageINT_Ch2`, color="No Induction (Ch2)")) +
  geom_smooth(se=FALSE) +
  ggtitle("Average Normalized Foci Intensity") +
  ylab("Normlized Mean Intensity") +
  xlab("Time (s)") +
  #ylim(-0.025, 0.025) +
  xlim(0, 200) +
  geom_vline(xintercept=0, linetype="dashed", color = "Darkgrey") +
  geom_vline(xintercept=15, linetype="solid", color = "Darkgrey") +
  geom_smooth(mapping =aes(x=Time, y=`Induced_AverageINT_Ch2`,color = "Induction (Ch2)"), se=FALSE) +
  theme(legend.position = "none", axis.text.x = element_text(angle = 90, vjust = 0.5, hjust=0.5), plot.title = element_text(hjust = 0.5)) +
  scale_colour_manual(name = "", 
                      values = c("No Induction (Ch2)" = "darkgrey", 
                                 "Induction (Ch2)" = "darkviolet"))




#Will generate plot with scaled Ch1 and Ch2 intensities
Overlap <- ggplot(MergedDFs, aes(x=Time, y=`Ch1_nonInd_Scaled`, color="No Induction")) +
  geom_smooth( se=FALSE) +
  ggtitle("Scaled Average Normalized Foci Intensity") +
  ylab("Scaled Mean Intensity") +
  xlab("Time (s)") +
  #ylim(-0.025, 0.025) +
  xlim(0, 200) +
  geom_vline(xintercept=0, linetype="dashed", color = "Darkgrey") +
  geom_vline(xintercept=15, linetype="solid", color = "Darkgrey") +
  annotate("text", x=17, y=0.02, label=  "Acquisition", angle = 90, color= "Darkgrey") +
  annotate("text", x=2, y=0.02, label=  "Induction", angle = 90, color= "Darkgrey") +
  theme(axis.text.x = element_text(angle = 90, vjust = 0.5, hjust=0.5), plot.title = element_text(hjust = 0.5)) +
  geom_smooth(mapping =aes(x=Time, y=`Ch1_Ind_Scaled`,color = "Induction (Ch1)"), se=FALSE) +
  geom_smooth(mapping =aes(x=Time, y=`Ch2_Ind_Scaled`,color = "Induction (Ch2)"), se=FALSE) +
  scale_colour_manual(name = "", 
                      values = c("No Induction" = "grey",
                                 "Induction (Ch1)" = "Chartreuse3",
                                 "Induction (Ch2)" = "darkviolet"))


Ch1+Ch2 
Overlap
(Ch1 | Ch2) / Overlap


png(file="CompareTraces.png",width=1500, height=900, res=100)
plot((Ch1 | Ch2) / Overlap)
dev.off()
