# script to make graphs (8 per page) of WQ data by
# looping through all csv files in a folder
# by Kim Cressman, Grand Bay NERR
# kimberly.cressman@dmr.ms.gov
# updated 2018-07-12


### IMPORTANT
# Make sure the ONLY csv files in the folder you want to work in are QC files automatically emailed from the CDMO
# This script has NOT been error-proofed so if you have a file that it doesn't recognize, the script will stop in its tracks


### IMPORTANT 2
# The folder-choice pop-up does NOT show up on top of other programs
# You MUST either click on the RStudio icon to minimize RStudio OR just minimize everything else to make the pop-up visible 



### INSTRUCTIONS
# 1 - Put your cursor somewhere in this window
# 2 - Push 'Ctrl' + 'A' to select the whole script
# 3 - Push 'Ctrl' + 'Enter' to run the script
# 4 - Minimize RStudio to get to the pop-up and choose the folder your QC files are in
# 5 - Magic happens
# 6 - Look in the folder you selected and pdf files should be there



# interactively choose which folder you want to work in
library(tcltk) #this package is part of base R and does not need to be installed separately
my.dir <- tk_choose.dir(getwd(), caption = "Choose which folder you want to work in")

# get the list of files in the directory that you want to graph
names.dir <- list.files(path = my.dir, pattern = ".csv")
n <- length(names.dir)

for(i in 1:n)
{
  # find the next file in the loop
  myFile <- names.dir[i] 
  
  # generate the full file path for reading and exporting files
  # without the use of setwd()
  full_file_path <- paste0(my.dir, "/", myFile)
  
  # read in the file and generate names for output
  ysi.data <- read.csv(full_file_path)
  x <- nchar(myFile) # counting the characters in the file name
  Title = substr(myFile,1,x-4) # for top of graphs; this should return the full name of the file (minus '.csv')
  Titlepdf <- paste0(full_file_path, ".pdf") # for export file


  # If there's already a DateTime column, don't do anything. If there's not, paste together Date and Time into DateTime.
  ifelse("DateTime" %in% names(ysi.data), ysi.data$DateTime <- ysi.data$DateTime, ysi.data$DateTime <- paste(ysi.data$Date, ysi.data$Time))

  # Get dates into the same format and turn them into POSIXct
  # Getting dates into the same format is important with the 6600 data files
  ysi.data$DateTimeA <- as.POSIXct(ysi.data$DateTime, format = "%m/%d/%Y %H:%M", tz = 'America/Regina') # Produces NA when format is not "%m/%d/%Y"
  ysi.data$DateTimeB <- as.POSIXct(ysi.data$DateTime, format = "%Y-%m-%d %H:%M", tz = 'America/Regina') # Produces NA when format is not "%Y-%m-%d"
  # replace NAs in A with the NOT-NAs in B
  ysi.data$DateTimeA[is.na(ysi.data$DateTimeA)] <- ysi.data$DateTimeB[!is.na(ysi.data$DateTimeB)]
  # make the whole DateTime column that unified column
  ysi.data$DateTime <- ysi.data$DateTimeA

  
  # return Depth or Level as 'Depth_or_Level'
  # then generate the name for the y-axis based on which it is

  # figure out which is in the file
  label.level <- sum(grepl("^Level", names(ysi.data))) # 0 if no 'level' column; number otherwise
  label.depth <- sum(grepl("^Depth", names(ysi.data))) # 0 if no 'depth' column; number otherwise
  if(label.level == 1) {
      pos.depth_or_level <- grep("Level", names(ysi.data))
      depth_or_level_name <- "Level"
      }
  if(label.depth == 1) {
      pos.depth_or_level <- grep("Depth", names(ysi.data))
      depth_or_level_name <- "Depth"
      }
  names(ysi.data)[pos.depth_or_level] <- "Depth_or_Level"
  
    

  # open up a pdf file to print to
  pdf(file=Titlepdf) 
    
  #make the graph page layout 4 rows and 2 columns so all graphs will fit on a page
  par(mfcol=c(4,2), mar=c(2.1, 4.1, 1.1, 1.1), oma=c(1,1,2,1))
  
  ## make the graphs
  
  # water temp
  plot(Temp~DateTime, data=ysi.data, 
       type="l", 
       xlab = "", xaxt='n', 
       col="darkred")
  axis.POSIXct(1, at=seq(min(ysi.data$DateTime, na.rm=TRUE), 
                         max(ysi.data$DateTime, na.rm=TRUE), length.out=5), 
               format="%m/%d", cex.axis=0.9)
  
  # SpCond
  plot(SpCond~DateTime, data=ysi.data, 
       type="l", 
       xlab = "", xaxt='n', 
       col="darkblue")
  axis.POSIXct(1, at=seq(min(ysi.data$DateTime, na.rm=TRUE), 
                         max(ysi.data$DateTime, na.rm=TRUE), length.out=5),
               format="%m/%d", cex.axis=0.9)

  # salinity  
  plot(Sal~DateTime, data=ysi.data, 
       type="l", 
       xlab = "", xaxt='n', 
       col="darkgreen")
  axis.POSIXct(1, at=seq(min(ysi.data$DateTime, na.rm=TRUE), 
                         max(ysi.data$DateTime, na.rm=TRUE), length.out=5),
               format="%m/%d", cex.axis=0.9)
  
  # depth / level
  plot(Depth_or_Level~DateTime, data=ysi.data, 
       type="l", 
       xlab = "", xaxt='n',
       ylab = depth_or_level_name,
       col="darkslategray")
  axis.POSIXct(1, at=seq(min(ysi.data$DateTime, na.rm=TRUE), 
                         max(ysi.data$DateTime, na.rm=TRUE), length.out=5),
               format="%m/%d", cex.axis=0.9)
 
  # DO% 
  plot(DO_pct~DateTime, data=ysi.data, 
       type="l", 
       xlab = "", xaxt='n', 
       col="darkorange")
  axis.POSIXct(1, at=seq(min(ysi.data$DateTime, na.rm=TRUE), 
                         max(ysi.data$DateTime, na.rm=TRUE), length.out=5),
               format="%m/%d", cex.axis=0.9)
  
  # # DO mg/L
  # commented out so battery voltage can be included instead
  # but if you want it back, just delete the ##s in front
  # plot(DO_mgl~DateTime, data=ysi.data, 
  #      type="l", 
  #      xlab = "", xaxt='n', 
  #      col="darkmagenta")
  # axis.POSIXct(1, at=seq(min(ysi.data$DateTime, na.rm=TRUE), 
  #                        max(ysi.data$DateTime, na.rm=TRUE), length.out=5),
  #              format="%m/%d", cex.axis=0.9)
  
  # pH
  plot(pH~DateTime, data=ysi.data, 
       type="l", 
       xlab = "", xaxt='n', 
       col="darkturquoise")
  axis.POSIXct(1, at=seq(min(ysi.data$DateTime, na.rm=TRUE), 
                         max(ysi.data$DateTime, na.rm=TRUE), length.out=5),
               format="%m/%d", cex.axis=0.9)
  
  # turbidity
  plot(Turb~DateTime, data=ysi.data, 
       type="l", 
       xlab = "", xaxt='n', 
       col="darkkhaki")
  axis.POSIXct(1, at=seq(min(ysi.data$DateTime, na.rm=TRUE), 
                         max(ysi.data$DateTime, na.rm=TRUE), length.out=5),
               format="%m/%d", cex.axis=0.9)
  
  # battery
  plot(Battery~DateTime, data=ysi.data, 
       type="l", 
       xlab = "", xaxt='n', 
       col="orangered3")
  axis.POSIXct(1, at=seq(min(ysi.data$DateTime, na.rm=TRUE), 
                         max(ysi.data$DateTime, na.rm=TRUE), length.out=5),
               format="%m/%d", cex.axis=0.9)
  
  # put the title of the file above all the plots on the page
  mtext(Title, outer=TRUE, side=3, cex=0.9, font=2)
  
  #turn off pdf printer
  dev.off()
}

#reset to one graph per page
par(mfrow=c(1,1))

print('Finished!')
