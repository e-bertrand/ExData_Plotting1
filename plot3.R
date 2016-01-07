###############################################################################
# Course Project 1:
#
# This script download (if necessary) the "Individual household electric power 
# consumption Data Set" from the UC Irvine Machine Learning Repository and plot
# the graph n. 3 in a png device
###############################################################################
#
#####################################################################
# Checking if 'readr' package is installed and loading it if this is 
# the case. If it is not installed, the script stops and calls for it
#####################################################################
#
resp <- require("readr", quietly = TRUE)

if (!resp) {
  cat("\nPlease, install 'readr' package in your environment",
      "before running this script\n")
  blankMsg <- sprintf("\r%s\r", paste(rep(" ", getOption("width")-1L), 
                                      collapse=" "));
  stop(simpleError(blankMsg))
}

#
######################################################################
# Downloading and unzipping the file if it has not already 
# beeen downloaded in a previous execution
######################################################################
#
# Setting as the working directory the dir where this script is  
# currently saved and executed. ¡ATTENTION! This works only if you run this  
# script from R environtment (and not from other script via source())
#
setwd(dirname(sys.frame(1)$ofile))
#
file_dir <- file.path(".", "data")
file_fullname <- file.path(file_dir, "household_power_consumption.txt")
#
# If uncompressed file already exists continue with the process. If not,
# download it and uncompress it.
#
if (!file.exists(file_fullname)) {

  cat("\nDownloading and unzipping the file...")
  
  ## dowloading and saving the file in a temporary file
  fileUrl <- 
    "https://d396qusza40orc.cloudfront.net/exdata/data/household_power_consumption.zip"
  temp <- tempfile()
  download.file(fileUrl, destfile = temp, method = "libcurl", mode = "wb")
  
  ## unzipping the temporary file and deleting it after the extraction
  unzip(temp, exdir = file_dir)
  unlink(temp)

} else {
  cat("\nSkipping to process: file", file_fullname, "has already been dowloaded")
}
#######################################################################
# As the file is ordered by Date and Time, we can read only the part of 
# the file that includes measurements from 2007-02-01 to 2007-02-02   
# in order to reduce memory consumption. Reading it with the fast 
# readr::read_delim() function for increasing speed
#######################################################################
#
cat("\nReading the file...")
#
# Number of minutes (= number of measurements) from the initial one until 
# the beginning of analyzed data + 1 (headers row)
#
init_skip <- strftime("2006-12-16 17:24:00")
final_skip <-  strftime("2007-02-01 00:00:00")
skipped_rows <- as.integer(difftime(final_skip, init_skip, units = "mins") + 1)
#
# Number of minutes (= number of measurements) in the period under analysis
#
init_row <- strftime("2007-02-01 00:00:00")
final_row <-  strftime("2007-02-03 00:00:00")
analyzed_rows <- as.integer(difftime(final_row, init_row, units = "mins"))
#
# Reading the file and its subset under analysis
#
hpc <- read_delim("./data/household_power_consumption.txt", 
                  delim =";", na = "?",
                  col_names = c("Date", "Time", "Global_active_power",
                                "Global_reactive_power", "Voltage",
                                "Global_intensity", "Sub_metering_1",
                                "Sub_metering_2", "Sub_metering_3"),
                  col_types = "ccnnnnnnn",
                  skip = skipped_rows, n_max = analyzed_rows)

#
# Converting Date and Time columns in a full POSIX compliant Date+Time variable.
# Deleting original Date and Time columns and rebuilding the final dataset hpc
#
DateTime <- strptime(paste(hpc$Date, hpc$Time), "%d/%m/%Y %H:%M:%S")
hpc$Time <- NULL
hpc$Date <- NULL
hpc <- cbind(as.data.frame(DateTime), hpc)
#
cat("\nPlotting the graph...\n")
#
#############################################################
# Plotting graph n. 3: Submetering vs DateTime, as a png file
#############################################################
#
png("./plot3.png", height = 480, width = 480, units = "px")
#
with(hpc, plot(DateTime, Sub_metering_1, 
               type = "l", xlab = "", ylab = "Energy sub metering")
)
with (hpc, lines(DateTime, Sub_metering_2,
                 col = "red")
)
with (hpc, lines(DateTime, Sub_metering_3,
                 col = "blue")
)
legend("topright", lty = 1, lwd = 2, col = c("black", "red", "blue"),
       legend = c("Sub_metering_1", "Sub_metering_2", "Sub_metering_3"))
#
dev.off()
