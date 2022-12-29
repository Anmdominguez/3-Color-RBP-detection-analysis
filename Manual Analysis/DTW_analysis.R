#Will check to see if the required packages are installed and if not, will install them
packages <- c( "dplyr", "tidyr", "ggplot2", "patchwork", "plotly", "stringr", "tidyverse", "tibble", "dtwclust")
check.package <- function(package){
  if(!(package %in% installed.packages())) install.packages(package)
}
sapply(packages, check.package)
sapply(packages, require, character.only = T)

inputdata <- read.csv('/Users/andrewd/Desktop/TimeLapse_Focianalysis/10.For analysis (aligned)/Stationary/3780_stat_with_copper/Outputs/PerCell_Intensity.csv')
CellIds <- as.list(unique(inputdata$CELL))
CellIds <- append("TIME", CellIds)


Ch1_data <- inputdata[, c(3, 14, 15)]
Ch1_data <- reshape(Ch1_data, idvar = "TIME", timevar = "CELL", direction = "wide")
Ch1_data <- Ch1_data[c(1:21),]
names(Ch1_data) <- CellIds
rownames(Ch1_data) <- Ch1_data$TIME
Ch1_data$TIME <- NULL
Ch1_data <- Ch1_data[ , colSums(is.na(Ch1_data))==0]
tCh1_data <- t(Ch1_data)

Ch2_data <- inputdata[, c(3, 13, 15)]
Ch2_data <- reshape(Ch2_data, idvar = "TIME", timevar = "CELL", direction = "wide")
Ch2_data <- Ch2_data[c(1:21),]
names(Ch2_data) <- CellIds
rownames(Ch2_data) <- Ch2_data$TIME
Ch2_data$TIME <- NULL
Ch2_data <- Ch2_data[ , colSums(is.na(Ch2_data))==0]
tCh2_data <- t(Ch2_data)


pc1 <- tsclust(tCh1_data, k = 3L,
              distance = "dtw2", centroid = "pam",
              seed = 100, trace = TRUE,
              return.objects = TRUE)

pc2 <- tsclust(tCh2_data, k = 3L,
               distance = "dtw2", centroid = "pam",
               seed = 100, trace = TRUE,
               return.objects = TRUE)



plot(pc1) / plot(pc2)
png(file="tsclusters.png",width=3000, height=1800, res=100)
plot(plot(pc1) / plot(pc2))
dev.off()


#=============================
# can we subset on each individual cluster, Calculate the average and then perform Cross correlation analysis

df1 <- data.frame(pc1@datalist)
df1 <- rbind(df1, pc1@cluster)
dfRows1 <- nrow(df1)
Positives_Ch1 <- df1[, df1[dfRows, ] == "1"]
PositiveCells_Ch1 <- colnames(Positives_Ch1)
Neutrals_Ch1 <- df1[, df1[dfRows1, ] == "2"]
NeutralCells_Ch1 <- colnames(Neutrals_Ch1)
Negatives_Ch1 <- df1[, df1[dfRows1, ] == "3"]
NegativeCells_Ch1 <- colnames(Negatives_Ch1)


df2 <- data.frame(pc2@datalist)
df2 <- rbind(df2, pc2@cluster)
dfRows2 <- nrow(df2)
Positives_Ch2 <- df2[, df2[dfRows2, ] == "1"]
PositiveCells_Ch2 <- colnames(Positives_Ch2)
Neutrals_Ch2 <- df2[, df2[dfRows2, ] == "2"]
NeutralCells_Ch2 <- colnames(Neutrals_Ch2)
Negatives_Ch2 <- df2[, df2[dfRows2, ] == "3"]
NegativeCells_Ch2 <- colnames(Negatives_Ch2)




CellClusters_all <- data.frame(cbind.fill(PositiveCells_Ch1, NeutralCells_Ch1, NegativeCells_Ch1, PositiveCells_Ch2, NeutralCells_Ch2, NegativeCells_Ch2))
colnames(CellClusters_all) <- c('PositiveCells_Ch1', 'NeutralCells_Ch1', 'NegativeCells_Ch1', 'PositiveCells_Ch2', 'NeutralCells_Ch2', 'NegativeCells_Ch2')
CellClusters_all$PositiveCells_Ch1<-gsub("X","",as.character(CellClusters_all$PositiveCells_Ch1))
CellClusters_all$NeutralCells_Ch1<-gsub("X","",as.character(CellClusters_all$NeutralCells_Ch1))
CellClusters_all$NegativeCells_Ch1<-gsub("X","",as.character(CellClusters_all$NegativeCells_Ch1))
CellClusters_all$PositiveCells_Ch2<-gsub("X","",as.character(CellClusters_all$PositiveCells_Ch2))
CellClusters_all$NeutralCells_Ch2<-gsub("X","",as.character(CellClusters_all$NeutralCells_Ch2))
CellClusters_all$NegativeCells_Ch2<-gsub("X","",as.character(CellClusters_all$NegativeCells_Ch2))

TwoPositive <- as.list(intersect(CellClusters_all$PositiveCells_Ch1, CellClusters_all$PositiveCells_Ch2))
TwoNeutral <- as.list(intersect(CellClusters_all$NeutralCells_Ch1, CellClusters_all$NeutralCells_Ch2))
TwoNegative <- as.list(intersect(CellClusters_all$NegativeCells_Ch1, CellClusters_all$NegativeCells_Ch2))
Doubles <- cbind.fill(TwoPositive, TwoNeutral, TwoNegative)
colnames(Doubles) <- c("DoublePositive", "DoubleNeutrals", "DoubleNegatives")

CellClusters <- cbind.fill (CellClusters_all, Doubles)

write.csv( CellClusters, "CellClusters.csv")
