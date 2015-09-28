
# Analyse BPM between PPG and ECG

library(ggplot2)
library(Hmisc)
library(reshape)
library(zoo)
# gives "unit" command for margins
library("grid")

# data location
data_path = "~/bluff_game/data_validation/results/";

# will spam this folder with data
output_folder = data_path
output_plot_folder = paste(data_path, 'figs/', sep="");

tag <- "BPM"

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
levels(data$device)[levels(data$device)=="Logitech"] <- "LogitechC270"

# discard data after cutofftime
data <- data[data$time<=600,]

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
  for (s in unique(data$session)) {
    dataSelect <- data[data$device == dev & data$session == s,]
   
    #Make zoo object of data
    temp.zoo<-zoo(dataSelect$HR,dataSelect$n)
    m.av<-rollmean(temp.zoo, ceil(averageWindow*srate))
    #Ugly, redo that only to get proper values for first and lasts :D
    m.av<-rollmean(temp.zoo, ceil(averageWindow*srate),fill = list(m.av[1], NULL, tail(m.av, 1)))
    data[data$device == dev & data$session == s,]$av <- m.av
  }
}


## plot across time, one for each PPG device

# color solarized version, red, violet, blue, cyan, green
solConstruct <- c("#dc322f","#6c71c4", "#268bd2", "#2aa198", "#859900")
# base2, base3, ...and something darker
solSession <- c("#eee8d5", "#fdf6e3", "#ded8c7")

ppg_devices <- unique(data[data$construct == "ppg",]$device)

for (dev in ppg_devices) {
  # retrieve PPG device + ECG reference
  dataSelect <- data[data$device == dev | data$construct == "ecg",]
  
  splot <- ggplot(data=dataSelect, aes(x = time, y = av, color=device))  + 
    geom_line(alpha=0.75) +
    # let's free the Y axis! (in case one channel goes bersek)... but less meaningful in regular scenarios
    facet_wrap(~ session, scales = "free_y", ncol = 1)
    #scale_colour_manual(values=solConstruct)  + 
  ggsave(path=output_plot_folder , filename=paste(tag, "_", dev, "_BPM.pdf",sep=""), plot=splot, width=10, height=7)
    
}


      


sink()


