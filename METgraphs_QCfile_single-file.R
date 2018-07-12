# script to make line graphs (8 per page) of MET data 
# plus a second page with a wind rose
# from emailed CDMO QC files
# by Kim Cressman, Grand Bay NERR
# kimberly.cressman@dmr.ms.gov
# updated 2018-07-12

### IMPORTANT
# you need to have some packages installed
# only need to uncomment and run these once; you can ignore them in future script runs
# install.packages('clifro')
# install.packages('ggplot2')

### IMPORTANT 2
# The file-choice pop-up might not show up on top of other programs
# Either click on the RStudio icon to minimize RStudio OR just minimize everything else to make the pop-up visible 

### INSTRUCTIONS
# 1 - Put your cursor somewhere in this window
# 2 - Push 'Ctrl' + 'A' to select the whole script
# 3 - Push 'Ctrl' + 'R' to run the script
# 4 - Minimize RStudio to get to the pop-up and choose the folder your QC files are in
# 5 - Magic happens
# 6 - Look in the folder you selected and pdf files should be there



# interactively choose the file to work on
myFile <-  choose.files(getwd(), caption="Choose file")


# read in the file and generate names for output  
met.data <- read.csv(myFile)
x <- nchar(myFile) # counting the characters in the file name
Title = substr(myFile,x-20,x-4) # this returns the CDMO-standard name of the file (minus '.csv')
Titlepdf <- sub(".csv", ".pdf", myFile) # this uses the original file path to generate an output file name


#format DateTime as POSIXct, which will turn it into a number that can be graphed
#we are retaining the format of mm/dd/yyyy hh:mm
met.data$DateTime <- as.POSIXct(met.data$TIMESTAMP, format = "%m/%d/%Y %H:%M", tz = 'America/Regina')

  
# open up a pdf file to print to
pdf(file=Titlepdf) 

  
# make the graph page layout 4 rows and 2 columns so all graphs will fit on a page
par(mfcol=c(4,2), mar=c(2.1, 4.1, 1.1, 1.1), oma=c(1,1,2,1))

  
#make graphs


# air temp
plot(ATemp~DateTime, data=met.data, 
     type="l", 
     xlab = "", xaxt='n', 
     col="darkred")
axis.POSIXct(1, at=seq(min(met.data$DateTime, na.rm=TRUE), 
                       max(met.data$DateTime, na.rm=TRUE), length.out=5), 
             format="%m/%d", cex.axis=0.9)

# relative humidity
plot(RH~DateTime, data=met.data, 
     type="l", 
     xlab = "", xaxt='n', 
     col="darkblue")
axis.POSIXct(1, at=seq(min(met.data$DateTime, na.rm=TRUE), 
                       max(met.data$DateTime, na.rm=TRUE), length.out=5), 
             format="%m/%d", cex.axis=0.9)

# barometric pressure
plot(BP~DateTime, data=met.data, 
     type="l", 
     xlab = "", xaxt='n',
     col="darkgreen")
axis.POSIXct(1, at=seq(min(met.data$DateTime, na.rm=TRUE), 
                       max(met.data$DateTime, na.rm=TRUE), length.out=5), 
             format="%m/%d", cex.axis=0.9)

# PAR
plot(TotPAR~DateTime, data=met.data, 
     type="l", 
     xlab = "", xaxt='n',
     col="darkturquoise")
axis.POSIXct(1, at=seq(min(met.data$DateTime, na.rm=TRUE), 
                       max(met.data$DateTime, na.rm=TRUE), length.out=5), 
             format="%m/%d", cex.axis=0.9)

# wind speed
plot(WSpd~DateTime, data=met.data, 
     type="l", 
     xlab = "", xaxt='n',
     col="darkslategray")
axis.POSIXct(1, at=seq(min(met.data$DateTime, na.rm=TRUE), 
                       max(met.data$DateTime, na.rm=TRUE), length.out=5), 
             format="%m/%d", cex.axis=0.9)

# max wind speed
plot(MaxWSpd~DateTime, data=met.data, 
     type="l", 
     xlab = "", xaxt='n',
     col="darkorange")
axis.POSIXct(1, at=seq(min(met.data$DateTime, na.rm=TRUE), 
                       max(met.data$DateTime, na.rm=TRUE), length.out=5), 
             format="%m/%d", cex.axis=0.9)

# cumulative precip
plot(CumPrcp~DateTime, data=met.data, 
     type="l", 
     xlab = "", xaxt='n',
     col="darkmagenta")
axis.POSIXct(1, at=seq(min(met.data$DateTime, na.rm=TRUE), 
                       max(met.data$DateTime, na.rm=TRUE), length.out=5), 
             format="%m/%d", cex.axis=0.9)

# battery
plot(AvgVolt~DateTime, data=met.data, 
     type="l", 
     xlab = "", xaxt='n',
     col="darkkhaki")
axis.POSIXct(1, at=seq(min(met.data$DateTime, na.rm=TRUE), 
                       max(met.data$DateTime, na.rm=TRUE), length.out=5), 
             format="%m/%d", cex.axis=0.9)

# put the title of the file above all the plots on the page
mtext(Title, outer=TRUE, side=3, cex=0.9, font=2)


# make a wind rose on the next page
#reset to one graph per page
par(mfrow=c(1,1))

library(clifro)
library(ggplot2)

windrose(met.data$WSpd, met.data$Wdir, speed_cuts = c(2,4,6,8,10,15,30), legend_title='Wind Speed (m/s)', ggtheme='minimal') + 
  ggtitle(Title) +
  theme(plot.title = element_text(size = 12, face='bold'),
        legend.title = element_text(size=9),
        legend.text = element_text(size=8),
        legend.key.size = unit(5, 'mm'),
        axis.text.y = element_text(size=8),
        strip.text = element_text(face='bold')) 

#turn off pdf printer
dev.off()

print('Finished!')