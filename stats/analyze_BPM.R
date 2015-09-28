
# Analyse BPM between PPG and ECG

library(ggplot2)
library(Hmisc)
library(reshape)
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

# set a time across sessions
data$n_across <- NA
for (dev in unique(data$device)) {
  data[data$device == dev,]$n_across <- 1:nrow(data[data$device == dev,])
}
data$time_across <- data$n_across/srate


sink()


