
# Analyse mean BPM 

# data location
data_path = "~/bluff_game/data_validation/results/";

# will spam this folder with data
output_folder = data_path
output_plot_folder = paste(data_path, 'figs/', sep="");

tag <- "PPG_BPM_average"

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

## mean HR

cat("# mean HR\n\n")

for (dev in levels(data$device)) {
  dataDev <- data[data$device == dev,]
  cat("\n == device: ", dev, " == \n\n")  
  print(summary(dataDev$HR))
  for (s in levels(data$session)) {
    cat("\n - level: ", s, " -\n\n")  
    dataSelect <- data[data$device == dev & data$session == s,]
    print(summary(dataSelect$HR))
  }
}


sink()


