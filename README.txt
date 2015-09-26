=================================================================
Averages for Human Activity Recognition Using Smartphones Dataset
=================================================================

Carlos Dottori - cedottori@gmail.com
Coursera JHU Data Science Specialization student
Getting and Cleaning Data Course
==================================================================

The dataset includes the following files:
=========================================

- 'README.txt': explanations about the work

- 'DATA DICTIONARY.pdf': Data dictionary with information about the tidy dataset

- 'run_analysis.R': R script that transforms original experiment data into assigned project course final dataset
=========================================

---------------------
HOW TO RUN THE SCRIPT
---------------------


1. Operational characteristics
------------------------------

The script does all the work by itself, there is no need for extra steps like downloading or moving files

You can set 2 variables specified below, to let the script know the working directory and if you want to dowload the original zipped file or not


2. Parameters
-------------

	There are 2 variables at the beginning of the script

	* download   - when set to TRUE, will download original dataset (default FALSE)
	* workingDir - assign to this variable your local working directory where the original zipped dataset was extracted


3. How it works
---------------

	The script has 3 parts, which are clearly identified in the code, to help the examiner find things in an easier way

        
        ----------------------------------------------------------------------------------------------------------------------------
	PART I - DOWNLOADS DATASET IF NECESSARY, UNZIPS FILE AND PREPARES INDEX FOR SELECTED COLUMNS, BASED ON THE FEATURES.TXT FILE

		This part does the basic job of setting working dir, downloading and extracting dataset and 
		creating an index to extract only the desired measurements (means and standard deviation measurements)

		To create the index and the labels for desired measurements, the algorithm finds features 
                that have the strings "mean()" or "std()" in their names, AND DO NOT have "meanFreq()" in their name

		The labels are also transformed to a more user-friendly form (refer to data dictionary)


        ----------------------------------------------------------------------------------------------------------------------------
	PART II - MERGES DATA, PREPARE INTERMEDIATE DATASET WITH LABELS AND SAVES INTERMEDIATE DATASET TO A FILE
 
		This part does most of the work, as it merges Test and Train datasets, names columns appropriately, 
		inserts the activity descriptions and extract only the desired measuremnt columns (mean and sd) in the resulting dataset.

		This part also generates an output file inthe working dir, "selectedMeasures.txt" with the intermediate dataset for checking.


        ----------------------------------------------------------------------------------------------------------------------------
	PART III - MERGES DATA, PREPARE INTERMEDIATE DATASET WITH LABELS AND SAVES INTERMEDIATE DATASET TO A FILE
 
		This part does the final job of calculating the means for each variable, using the functionality of data.table package

		It also inserts the suffix "avg-" to column names, and saves the final dataset to a file named "finalDataSet.txt"


========================================================================

Thank you and hope I don´t give you too much work to evaluate my script!

Carlos