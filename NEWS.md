# covidrtestimates 0.3.0 - 09-10-2020
* Restructured the output file locations. Data is now commited within the /data folder:
  * Source data files are in /data/reference
  * Results are in /data/results
  * Runtime status files are in /data/runtime (e.g. last update, runtime.csv)
 
  running the program with -d flag outputs the data into the data dir. Only the results in data dir will be commited, the old locations are git ignored but will still be generated as a default location for those who use this as part of a wider suite. A soft deprecation warning will be issued under these circumstances.

# covidrtestimates 0.2.0 - 09-09-2020
* Runtime management
* Improved logging
* Consolidated script for running different data sets
* CLI interface
* lots of small fixes

# covidrtestimates 0.1.0 - 29-07-2020

* Rebased estimates to be based on [EpiNow2](https://epiforecasts.io/EpiNow2/)
* Restricted estimates to be based on the last 8 weeks of data.
* Added all subnational estimates
* Restricted published results to summaries only to deal with storage issues.
