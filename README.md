R Scripts for SWMP QC
================

-   [Script Descriptions](#script-descriptions)
    -   [Water Quality Scripts](#water-quality-scripts)
        -   [WQgraphs\_QCfile\_looping: Loop through files in a folder](#wqgraphs_qcfile_looping-loop-through-files-in-a-folder)
    -   [Weather Station Scripts](#weather-station-scripts)
        -   [METgraphs\_QCfile\_single-file: One file](#metgraphs_qcfile_single-file-one-file)
        -   [METgraphs\_QCfile\_looping: Loop through files in a folder](#metgraphs_qcfile_looping-loop-through-files-in-a-folder)
-   [Instructions for running scripts](#instructions-for-running-scripts)
-   [Some cautions](#some-cautions)

This is a collection of R scripts that can be used to QC SWMP data. Each script has limited interactivity - in the course of running, you will be able to choose a working directory through Windows Explorer. These work on QC files returned from the CDMO after data upload. They could be modified to work on raw files off of instruments; mostly things are named differently, although EXO files need some massaging.

Script Descriptions
===================

Water Quality Scripts
---------------------

### WQgraphs\_QCfile\_looping: Loop through files in a folder

`WQgraphs_QCfile_looping`: runs through every CSV in the selected working directory; generates pdf output for each.

-   Make sure the only CSVs in your folder are water quality QC files emailed from the CDMO after file upload.
-   Parameters plotted are: Temp, SpCond, Sal, Depth, DO\_pct, pH, Turb, and Battery.

#### Example output

![](output/GNDPCWQ041618_QC.png)

Weather Station Scripts
-----------------------

### METgraphs\_QCfile\_single-file: One file

`METgraphs_QCfile_single-file`: allows you to interactively select a single file from which to generate graphs. **This is usually the script I use for MET graphs, because we only download one file at once.**

-   A pdf file with two pages is generated:
    -   The first page has line graphs of ATemp, RH, BP, TotPAR, WSpd, MaxWSpd, CumPrcp, and AvgVolt (which represents battery).
    -   The second page has a wind rose, which shows direction in addition to speed.
-   The `ggplot2` and `clifro` packages are required to run this. If you don't already have them, run these lines:
    -   `install.packages("ggplot2")`
    -   `install.packages("clifro")`

### METgraphs\_QCfile\_looping: Loop through files in a folder

`METgraphs_QCfile_looping`: Just like the above MET script, but it runs through every CSV in the selected working directory. As above, the `ggplot2` and `clifro` packages are required.

#### Example output

Don't be scared; these actually look pretty good in pdf format. I saved them as pngs to insert in this document, so they're a little wonky.

**See some problems? This is why it's important to graph data.**

(If you need a hint, look closely at Atemp - it doesn't get that cold in south Mississippi. There are also some apparent battery problems.)

![See some problems? This is why we graph the data.](output/gndcrmet110717_QC1.png)

**Wind Rose**

This is pretty typical for winter at our site. Most wind is out of the North.

![Wind Rose](output/gndcrmet110717_QC2.png)

Instructions for running scripts
================================

These instructions are also in comments at the top of each script.

1.  Open the script.
2.  Put the cursor somewhere in the script window, and hit 'Ctrl+a' to select all.
3.  Either click the 'Run' button in the upper right corner of the script window, or use the 'Ctrl+Enter' keyboard shortcut to run the script.
4.  Interactively choose your working directory (where multiple files are that you want to work through) or the single file you want (for the MET single-file script). **The file-choice pop-up does NOT show up on top of other programs; you MUST either click on the RStudio icon to minimize RStudio OR just minimize everything else to make the pop-up visible.**
5.  Let the script do its thing.
6.  Look in the working directory for your pdf files!

Some cautions
=============

These scripts have NOT been error-proofed.

-   If you have some CSV in your working directory that does not match the format of CDMO-emailed QC files, the script will stop in its tracks and return an error message. Move the files you want to graph into their own folder and use that instead.
-   If your sites report level instead of depth, you'll need to change the parameter on line 102 of the `WQgraphs_QCfile_looping` script.

Let me know if you run into any other issues! And if you know how to make these more robust to errors, feel free to make a pull request. (If you don't know what that means, just email me the scripts with your updates and I'll make them available here.)
