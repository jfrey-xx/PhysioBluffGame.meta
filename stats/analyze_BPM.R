
# Analyse BPM between PPG and ECG

library(ggplot2)
library(Hmisc)
library(reshape)
library(zoo)
# gives "unit" command for margins
library("grid")
library(stats)

# data location
data_path = "~/bluff_game/data_validation/results/";

# will spam this folder with data
output_folder = data_path
output_plot_folder = paste(data_path, 'figs/', sep="");

tag <- "PPG_BPM"

# sampling rate of the data
srate <- 8

# retain a portion of data points (in seconds)
cutofftime <- 600

# output file
sink(paste(output_folder, "results_R_", tag, ".txt", sep=""), split=TRUE)


## info about dataset

# lda analysis output once applied to EEG xp
data_filename = 'validation_PPG_replay_3sub_ecg-ppg.csv'

## load data
data <- read.table(paste(data_path,data_filename, sep=""), header=TRUE, sep=",")

# rename columns which names were kept for "historical" reasons (aka laziness to change anything)
names(data)[names(data)=="channel"] <- "device"
names(data)[names(data)=="points"] <- "HR"
names(data)[names(data)=="subject"] <- "session"

# rename some devices
levels(data$device)[levels(data$device)=="BPM"] <- "ECG"
levels(data$device)[levels(data$device)=="Logitech"] <- "Logitech_C270"
levels(data$device)[levels(data$device)=="PSEyeRaw"] <- "PSEye_Raw"
levels(data$device)[levels(data$device)=="Kinect2RGB"] <- "Kinect2_RGB"
levels(data$device)[levels(data$device)=="Kinect2IR"] <- "Kinect2_IR"

# reverse order so as we got ps eye, logitech, kinect rgb, kinect ir
data$device=factor(data$device,rev(levels(data$device)))

# discard data after cutofftime
data <- data[data$time<=600,]

# make factor of session + rename
data$session <- factor(data$session)
levels(data$session) <- paste("Session", levels(data$session), sep="_")

# set a time across sessions
data$n_across <- NA
for (dev in unique(data$device)) {
  data[data$device == dev,]$n_across <- 1:nrow(data[data$device == dev,])
}
data$time_across <- data$n_across/srate


## moving average

# sliding window size (in seconds)
averageWindow <- 1;
  
data$av <- NA
for (dev in levels(data$device)) {
  for (s in levels(data$session)) {
    dataSelect <- data[data$device == dev & data$session == s,]
   
    #Make zoo object of data
    temp.zoo<-zoo(dataSelect$HR,dataSelect$n)
    m.av<-rollmean(temp.zoo, ceil(averageWindow*srate))
    #Ugly, redo that only to get proper values for first and lasts :D
    m.av<-rollmean(temp.zoo, ceil(averageWindow*srate),fill = list(m.av[1], NULL, tail(m.av, 1)))
    data[data$device == dev & data$session == s,]$av <- m.av
  }
}

## set ECG reference everywhere

# will ease later side-by-side plots
data$ref_av <- NA
data$ref_HR <- NA
for (s in levels(data$session)) {
  dataRef <- data[data$device == "ECG" & data$session == s,]
  for (dev in levels(data$device)) {

    data[data$device == dev & data$session == s,]$ref_av <- dataRef$av
    data[data$device == dev & data$session == s,]$ref_HR <- dataRef$HR
  }
}

## plot across time, one panel for each PPG device

dataPPG <- droplevels(data[data$construct == "ppg",])

splot <- ggplot(data=dataPPG, aes(x = time, y = av))  + 
    # ref ECG, base02 color
    geom_line(aes(y = ref_av), color="#073642", alpha=0.66) +
    geom_line(aes(color=device), alpha=0.66) +
    # let's free the Y axis! (in case one channel goes bersek)... but less meaningful in regular scenarios
    facet_grid(device ~ session) +
    # remove legend for device
    guides(colour=FALSE)+
    # labels
    labs(x = "Time (s)", y="Heart rate (BPM)") +
    # remove margins, we need max space + increase font size
    theme(plot.margin = unit(c(0,0,0,0), "cm"), text = element_text(size=20))
ggsave(path=output_plot_folder , filename=paste(tag, ".pdf",sep=""), plot=splot, width=14, height=7)


## correlation

cat("# correlation\n\n")

# PPG against the world
dataPPG <- droplevels(data[data$construct == "ppg",])

# holders for p value and R score
nbSessions <- length(unique(dataPPG$session))
nbDevices <- length(unique(dataPPG$device))

# pearson -- linear correlation
cor_r <- array(dim=c(nbSessions,nbDevices))
rownames(cor_r) <- levels(dataPPG$session)
colnames(cor_r) <- levels(dataPPG$device)
cor_p <- cor_r

# spearman -- monotonic, for info
cor_p_spear <- cor_r
cor_r_spear <- cor_r

for (s in 1:length(levels(dataPPG$session))) {
   sub <- levels(dataPPG$session)[s]
   dataSelect <- dataPPG[dataPPG$session == sub,]
   keeps <- c("device", "time", "HR")
   dataSelect <- dataSelect[keeps]
   
   # Hmisc works on matrix. first long to wide, drop freq column
   dataSelectWide <- reshape(dataSelect, idvar = "time", timevar = "device", direction = "wide")
   dataSelectWide <- dataSelectWide[,2:length(dataSelectWide)]
   
   # take out the ECG column of on device (it's the same for all)
   ref_HR <- dataPPG[dataPPG$session == sub & dataPPG$device == levels(dataPPG$device)[1],]$ref_HR
   
   # run correlation
   resCor <- rcorr(as.matrix(dataSelectWide), ref_HR, type="pearson")  
   # keep data for later (y row of rcorr results)
   cor_r[s, ] <- resCor$r[nbDevices+1,1:nbDevices]
   cor_p[s, ] <- resCor$P[nbDevices+1,1:nbDevices]
   
   # juste for the record
   resCor_spear <- rcorr(as.matrix(dataSelectWide), ref_HR, type="spearman")
   cor_r_spear[s, ] <- resCor_spear$r[nbDevices+1,1:nbDevices]
   cor_p_spear[s, ] <- resCor_spear$P[nbDevices+1,1:nbDevices]
}

## correlation summary

# now some descriptive stats

cat("\n\n\n ---------------------- \n\n\n")

cat("# correlation - summary \n\n")

# get all p-values right
cor_p_adjust <- array(
  p.adjust(cor_p, method = "fdr", n = length(cor_p)),
  dim=c(nbSessions,nbDevices)
)
rownames(cor_p_adjust) <- levels(dataPPG$session)
colnames(cor_p_adjust) <- levels(dataPPG$device)

cor_p_spear_adjust <- array(
  p.adjust(cor_p_spear, method = "fdr", n = length(cor_p_spear)),
  dim=c(nbSessions,nbDevices)
)
rownames(cor_p_spear_adjust) <- levels(dataPPG$session)
colnames(cor_p_spear_adjust) <- levels(dataPPG$device)

# print all of that

cat("\n\n ==== Pearson correlation ==== \n")

cat("\n\n -- R scores -- \n\n")
print(cor_r)

cat("\n\n -> summary \n")
summary(cor_r)

cat("\n\n -> SD \n")
apply(cor_r, 2, sd)

cat("\n\n -- p values -- \n\n")
print(cor_p)

cat("\n\n -> summary \n")
summary(cor_p)

cat("\n\n -> SD \n")
apply(cor_p, 2, sd)

cat("\n\n -- p values, FDR adjusted -- \n\n")
print(cor_p_adjust)

cat("\n\n -> summary \n")
summary(cor_p_adjust)

cat("\n\n -> SD \n")
apply(cor_p_adjust, 2, sd)
   
   

cat("\n\n\n === For info, spearman correlation  === \n")

cat("\n\n -- R scores -- \n\n")
print(cor_r_spear)

cat("\n\n -> summary \n")
summary(cor_r_spear)

cat("\n\n -> SD \n")
apply(cor_r_spear, 2, sd)

cat("\n\n -- p values -- \n\n")
print(cor_p_spear)

cat("\n\n -> summary \n")
summary(cor_p_spear)

cat("\n\n -> SD \n")
apply(cor_p_spear, 2, sd)

cat("\n\n -- p values, FDR adjusted -- \n\n")
print(cor_p_spear_adjust)

cat("\n\n -> summary \n")
summary(cor_p_spear_adjust)

cat("\n\n -> SD \n")
apply(cor_p_spear_adjust, 2, sd)

sink()


