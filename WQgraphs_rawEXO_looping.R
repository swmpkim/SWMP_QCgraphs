# script to make graphs (8 per page) of WQ data by
# looping through all .xls/.xlsx files in a folder
# by Kim Cressman, Grand Bay NERR
# kimberly.cressman@dmr.ms.gov
# updated 2018-07-12


### IMPORTANT
# Make sure the ONLY .xls/.xlsx files in the folder you want to work in are files downloaded from YSI EXOs
# This script has NOT been error-proofed so if you have a file that it doesn't recognize, the script will stop in its tracks


### IMPORTANT 2
# The folder-choice pop-up does NOT show up on top of other programs
# You MUST either click on the RStudio icon to minimize RStudio OR just minimize everything else to make the pop-up visible 


### INSTRUCTIONS
# 1 - Put your cursor somewhere in this window
# 2 - Push 'Ctrl' + 'A' to select the whole script
# 3 - Push 'Ctrl' + 'Enter' to run the script
# 4 - Minimize RStudio to get to the pop-up and choose the folder your exported EXO files are in
# 5 - Magic happens
# 6 - Look in the folder you selected and pdf files should be there


##########################################################################


library(dplyr)
library(lubridate)
library(readxl)
library(tcltk) #this package is part of base R and does not need to be installed separately

# interactively choose which folder you want to work in
my.dir <- tk_choose.dir(getwd(), caption = "Choose which folder you want to work in")


# get the list of files in the directory that you want to graph
names.dir <- list.files(path = my.dir, pattern = ".xls")
n <- length(names.dir)

for(i in 1:n)
{
    # find the next file in the loop
    myFile <- names.dir[i] 
    
    
    # generate names for output
    x <- nchar(myFile) # counting the characters in the file name
    
    Title = substr(myFile, 1, x-5) # this should return the full name of the file (minus '.xlsx' -- change x-5 to x-4 if you're using .xls files)
    
    # If you want to get rid of all the 13A12345_010118_1200 stuff at the end of the file name, delete the # from the next line so that it runs:
    # Title = ifelse(x > 30, substr(myFile, 1, x-29), substr(myFile, 1, x-5))
    
    # make the full path to the file, first for reading, then for pdf output
    full_file_path <- paste0(my.dir, "/", myFile)
    Titlepdf <- paste0(my.dir, "/", Title, ".pdf")
    
    ### read in the file  ################
    # first let R look at it to find where the real data starts
    test_in <- read_excel(path = full_file_path, sheet = 1)
    # find the cell in column 1 that starts with Date -- 
    # this indicates the header row
    col1vec <- (test_in[,1])
    names(col1vec) <- "col1"
    pos <- grep("Date", col1vec$col1)
    # read in the data, beginning with the header row
    dat <- read_excel(path = full_file_path, sheet = 1, skip = pos)
    
    head(dat)
    
    
    ### select a file  ##################
    # myFile <- choose.files()
    
    
    ### deal with names ###################
    # make them all lower case
    names(dat) <- tolower(names(dat))
    # use make.names() to get rid of spaces and weird characters
    names(dat) <- make.names(names(dat), unique = TRUE)
    
    # make either sal.ppt or sal.psu return 'sal'
    pos <- grep("sal", names(dat))
    names(dat)[pos] <- "sal"
    
    # same thing for turbidity
    pos <- grep("turbidity", names(dat))
    names(dat)[pos] <- "turb"  
    
    
    # return depth or level as 'depth_or_level'
    # then generate a name for the y-axis based on which it is
    
    # figure out which is in the file
    label.level <- sum(grepl("level", names(dat))) # 0 if no 'level' column; number otherwise
    label.depth <- sum(grepl("depth", names(dat))) # 0 if no 'depth' column; number otherwise
    if(label.level == 1) {
        pos.depth_or_level <- grep("level", names(dat))
        depth_or_level_name <- "level"
        }
    if(label.depth == 1) {
        pos.depth_or_level <- grep("depth", names(dat))
        depth_or_level_name <- "depth"
        }
    names(dat)[pos.depth_or_level] <- "depth_or_level"
    
    
    ### format and name more SWMP-ily  ####################
    ## get date and time into DateTime format by first
    # turning them into character strings and separating 'time' from
    # the made-up date that it received on import
    ## then select and rename the parameters we want to graph
    dat2 <- dat %>%
        mutate(date = as.character(date..mm.dd.yyyy.),
               time = as.character(time..hh.mm.ss.),
               time2 = substr(time, nchar(time)-8, nchar(time)),
               datetime = paste(date, time2),
               datetime = lubridate::ymd_hms(datetime)) %>%
        select(datetime, 
               temp = temp..c, 
               spcond = spcond.ms.cm, 
               sal,  
               do_mgl = odo.mg.l, 
               do_pct = odo...sat, 
               ph,
               turb, 
               depth_or_level,
               battery_v = battery.v)
    
    
    head(dat2)
    
    
    # open up a pdf file to print to
    pdf(file=Titlepdf) 
    
    #make the graph page layout 4 rows and 2 columns so all graphs will fit on a page
    par(mfcol=c(4,2), mar=c(2.1, 4.1, 1.1, 1.1), oma=c(1,1,2,1))
    
    ## make the graphs
    
    # water temp
    plot(temp~datetime, data=dat2, 
         type="l", 
         xlab = "", xaxt='n', 
         col="darkred")
    axis.POSIXct(1, at=seq(min(dat2$datetime, na.rm=TRUE), 
                           max(dat2$datetime, na.rm=TRUE), length.out=5), 
                 format="%m/%d", cex.axis=0.9)
    
    # SpCond
    plot(spcond~datetime, data=dat2, 
         type="l", 
         xlab = "", xaxt='n', 
         col="darkblue")
    axis.POSIXct(1, at=seq(min(dat2$datetime, na.rm=TRUE), 
                           max(dat2$datetime, na.rm=TRUE), length.out=5),
                 format="%m/%d", cex.axis=0.9)
    
    # salinity  
    plot(sal~datetime, data=dat2, 
         type="l", 
         xlab = "", xaxt='n', 
         col="darkgreen")
    axis.POSIXct(1, at=seq(min(dat2$datetime, na.rm=TRUE), 
                           max(dat2$datetime, na.rm=TRUE), length.out=5),
                 format="%m/%d", cex.axis=0.9)
    
    # depth/level
    plot(depth_or_level~datetime, data=dat2, 
         type="l", 
         xlab = "", xaxt='n',
         ylab = depth_or_level_name,
         col="darkslategray")
    axis.POSIXct(1, at=seq(min(dat2$datetime, na.rm=TRUE), 
                           max(dat2$datetime, na.rm=TRUE), length.out=5),
                 format="%m/%d", cex.axis=0.9)
    
    # DO% 
    plot(do_pct~datetime, data=dat2, 
         type="l", 
         xlab = "", xaxt='n', 
         col="darkorange")
    axis.POSIXct(1, at=seq(min(dat2$datetime, na.rm=TRUE), 
                           max(dat2$datetime, na.rm=TRUE), length.out=5),
                 format="%m/%d", cex.axis=0.9)
    
    # # DO mg/L
    # commented out so battery voltage can be included instead
    # but if you want it back, just delete the ##s in front
    # plot(do_mgl~datetime, data=dat2, 
    #      type="l", 
    #      xlab = "", xaxt='n', 
    #      col="darkmagenta")
    # axis.POSIXct(1, at=seq(min(dat2$datetime, na.rm=TRUE), 
    #                        max(dat2$datetime, na.rm=TRUE), length.out=5),
    #              format="%m/%d", cex.axis=0.9)
    
    # pH
    plot(ph~datetime, data=dat2, 
         type="l", 
         xlab = "", xaxt='n', 
         col="darkturquoise")
    axis.POSIXct(1, at=seq(min(dat2$datetime, na.rm=TRUE), 
                           max(dat2$datetime, na.rm=TRUE), length.out=5),
                 format="%m/%d", cex.axis=0.9)
    
    # turbidity
    plot(turb~datetime, data=dat2, 
         type="l", 
         xlab = "", xaxt='n', 
         col="darkkhaki")
    axis.POSIXct(1, at=seq(min(dat2$datetime, na.rm=TRUE), 
                           max(dat2$datetime, na.rm=TRUE), length.out=5),
                 format="%m/%d", cex.axis=0.9)
    
    # battery
    plot(battery_v~datetime, data=dat2, 
         type="l", 
         xlab = "", xaxt='n', 
         col="orangered3")
    axis.POSIXct(1, at=seq(min(dat2$datetime, na.rm=TRUE), 
                           max(dat2$datetime, na.rm=TRUE), length.out=5),
                 format="%m/%d", cex.axis=0.9)
    
    # put the title of the file above all the plots on the page
    mtext(Title, outer=TRUE, side=3, cex=0.9, font=2)
    
    #turn off pdf printer
    dev.off()
    
}

print("Finished!")

