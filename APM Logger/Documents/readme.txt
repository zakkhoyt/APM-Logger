In APM, log files are read as csv and then converted to an in-memory database. 
See the file: ap2dataplotthread.cc

We can easily do the same on iOS, using coredata or sql. Load the file into an in memory database, then graph the results usind a framework like Google's iOS graph, or raw cordata or openGL

Also, we can create smaller sets of these log files/databases with the CoreLocation, CoreMotion, and a few other tools. 


TODO:

Log Files:
In APM, take a look at what is logged by default and by changing the parameters. 
Once we know what goes into the log files, let's define what we can reasonably log with an iOS device. 

SQL:
Port the code mentioned above to iOS

Google Earth files:
There is no reason we can't also generate KMZ files from an iOS application. Perhaps we can even view them on the iOS google earth application
See the file KMLCreator, specifically the processLine method. The output files (KMZ) appear to be binary files.


Using existing source code:
It looks like it is possible to compile QT code for use on iOS. Perhaps we can leverage some of the existing code.
See this thread: http://stackoverflow.com/questions/17477165/creating-qt-5-1-apps-for-ios
