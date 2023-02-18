# EEOC MDS-in-a-Box
This branch of https://github.com/gregwdata/MDS-in-a-box is a fork of Jacob Matson's MDS-in-a-box project ([github repo](https://github.com/matsonj/nba-monte-carlo), [website](http://www.mdsinabox.com)). It is a work-in-progress to adapt the MDS-in-a-box stack to a new dataset.

This project will start with data published by the US Equal Employment Opportunity Commisson [eeoc.gov](https://www.eeoc.gov/data/job-patterns-minorities-and-women-private-industry-eeo-1-0) data for job patterns for minorities and women in private industry (EEO-1). 

## Project plan

- [x] Extract and Load EEO-1 data form eeoc.gov-hosted Excel files using Meltano
- [ ] Transform, using dbt, into tidy datasets of interest
	- The datasets provided by EEOC are pre-aggregated, with different grains mixed in the same file
- [ ] Perform (and preserve using configuration files) EDA and initial visualizations in Rill Developer
- [ ] Where results warrant a more narrative presentation, develop reports using Evidence.dev

## Purpose
This is mainly undertaken as a learning exercise to (1) gain familiarity with the components of the MDS-in-a-box (chiefly Meltano and dbt for now) and (2) to exercise the in-a-box idea of the using the MDS-in-a-box project as a template for initiating a new data project with all the capabilities of the "Modern Data Stack" ready to go.

The choice of EEOC data as a data set is motiviated by an interest in understanding and sharing what it can tell us about representation in employment (and a big thanks to my wife, who has made DEI in engineering cereers a big focus in her own work, for suggesting this data). That said, I am not undertaking this with the initial expectation that the results of analyzing the data set will be particularly revalatory or surprising, or with a particular starting question in mind. And the EEOC website itself offers what appears to be a comprehensive [Tableau visualization](https://www.eeoc.gov/data/job-patterns-minorities-and-women-private-industry-eeo-1-0) already. The aim here is to make use of the MDS tools to enable recreation of, and perhaps extension beyond, some of that reporting.

## Development log
### Data Source

Well, it looks as though the files available for download [at the bottom of the page here](https://www.eeoc.gov/data/job-patterns-minorities-and-women-private-industry-eeo-1-0) are corrupt in some way. They download successfully, and have file sizes on the order of 40 MB, but Excel throws errors when trying to open any of them. Given that, it is no surprise that I was unable to load them with the `tap-spreadsheets-anywhere` tap in Meltano. I did dive into the Excel files using 7zip, the first layer of compression was able to be opened, but trying to load the data from the actual spreadsheet resulted in 7zip likewise complaining it couldn't be opened.

I checked [data.gov](data.gov), and luckily found that the same data are available there. Using the search feature, I found that the EEO1 data were available as "csv" files. But when you click the download link, you get directed straight to a `.txt` file instead. On quick inspection, those files have `;` delimiters. Fine, I bet tap-spreadsheets-anywhere can handle that. 

**TIL** The default ets `tap-spreadhseets-anywhere` tap did not like loading anything from the data.gov URL I was testing with. By swtiching to the RFAinc variant of the tap, I was able to get it to recognize and attempt to load a file, like so:

```
	plugins:
		extractors:
			- name: tap-spreadsheets-anywhere
			variant: rfainc
			pip_url: git+https://github.com/rfainc/tap-spreadsheets-anywhere.git
			config:
				tables:
				- path: https://www.eeoc.gov/sites/default/files/migrated_files/eeoc/statistics/employment/jobpat-eeo1/2015/datasets/year15_cbsa_nac3.txt
				  name: EEO1_cbsa_nac3_2015
				  search_prefix: year15_cbsa_nac3.txt
				  pattern: "year15_cbsa_nac3.txt"
				  start_date: '2010-01-01T00:00:00Z'
				  key_properties: []
				  format: csv
				  delimiter: ;
				  sample_rate: 1
```

But... kept getting errors - and interestingly the errors were often different each time I ran the tap. After downloading the file with `wget` and trying to directly load from the filesystem, I still got errors, though now consistent each time and related to UTF-8 unparsable characters. 

After identifying the location where the error occurred within the `.txt` file, and checking the same location in the browser, it appears the data from the file is itself being corrupted by timeouts while trying to download it. (In the coures of debugging this, I went as far as [forking tap-spreadsheets-anywhere](https://github.com/gregwdata/tap-spreadsheets-anywhere), modifying it with optional parameters to override the default file encoding, hoping that I could get away with ignoring the mess of bytes caused by the connection dropping. Alas, it didn't work, but it did at least help with the original goal of learning the ins and outs of Meltano!)

One observation I have is the accumulated layers of extraction in using meltano plus a tap made it hard to debug this situation.

Data.gov lists contact information for these data sets, so I'm trying my luck there. The full write-up documenting the issues sent to EEOC via email is reproduced here:

> * Downloading Excel files from https://www.eeoc.gov/data/job-patterns-minorities-and-women-private-industry-eeo-1-0
>    * All of the Excel file downloads linked at the bottom of this page result in .xlsx files of around 36-50 MB in size, but I am unable to open them in excel. 
>	
>    * They all result in an error message from Excel like: 
>	![image](https://user-images.githubusercontent.com/79663385/214203188-461eda65-c251-4281-8b1c-0a031695c9bb.png)
>	
>    * There appears to be a problem in the compression of the main data xml files (sheet1.xml) inside of the .xlsx files. Using 7zip, I am able to open and navigate the rest of the structure of the Excel files, but it is not able to successfully uncompress this part, containing the data.
> * Incomplete download of .txt files of the data from data.gov due to connection closures
>	 * Having found that the EEO-1 data is listed on data.gov, I attempted to download from there. 
>	 * Each data.gov page contains a link to the data file, which refers to .txt files accessible via an eeoc.gov url.
> 	 * The issue I've run into here is that the larger files do not download completely.
> 	 * For example, the 2009 state and NAIC-3-aggregated data are linked on this data.gov page https://catalog.data.gov/dataset/job-patterns-for-minorities-and-women-in-private-industry-2009-eeo-1-state-aggregate-by-na-942fc to this eeoc.gov URL: https://www.eeoc.gov/sites/default/files/migrated_files/eeoc/statistics/employment/jobpat-eeo1/2009/datasets/year09_state_nac3.txt
>	 * When opening the .txt file link in browser, it does not completely download. The amount of data transmitted before stopping is somewhat variable. For that particular file, it tends to stop somewhere in the "M" state names. 
> 	 * The Chrome browser console shows an error message "net::ERR_INCOMPLETE_CHUNKED_ENCODING"
>	![image](https://user-images.githubusercontent.com/79663385/214203174-c3633cb6-0323-4715-b1d1-c688cc5178cb.png)
> 	 * The same error message is encountered when accessing the 2015 data at https://www.eeoc.gov/sites/default/files/migrated_files/eeoc/statistics/employment/jobpat-eeo1/2015/datasets/year15_state_nac3.txt , with the addition of non-ASCII or UTF-8 characters and a tmp filename being inserted into the downloaded data in the middle of the file
>	![image](https://user-images.githubusercontent.com/79663385/214203207-47568af9-4d33-4df4-b36b-6dd678f90252.png)
> 	 * Using Python scripting tools to directly load data from these URLs, for most of the .txt files listed on data.gov, I encountered errors consistent with the partial download of the files and/or presence of non-decodable characters, as in the above example.
>	 * However, I was successful in fully downloading these files using the Linux utility "wget", which would partially download the file, report "connection closed" then automatically resume download at the point it left off. After multiple restarts, it is able to download the complete contents of the files.
> * Missing years of data on data.gov
>	 * Searching for EEO-1 data on data.gov, I am able to find search results for years up to 2017, but not later. This is in contrast to the data on the eeoc.gov site, which has Excel files through 2020.
>	 * I did note, that following the URL structure of the 2017 files, I was able to change 17 to 18, and download the 2018 data from https://www.eeoc.gov/sites/default/files/migrated_files/eeoc/statistics/employment/jobpat-eeo1/2018/datasets/year18_state_nac3.txt
> 	 * However, that did not work for 2019 or 2020
>	 * Also, the 2010 dataset referenced on this page of data.gov https://catalog.data.gov/dataset/job-patterns-for-minorities-and-women-in-private-industry-2010-eeo-1-state-aggregate-by-na-13a2f goes to a 404, "the requested page could not be found" message on the eeoc.gov URL https://www.eeoc.gov/eeoc/statistics/employment/jobpat-eeo1/2010/upload/2010_EEO-1_Job_Patterns_Data.zip that the download button from data.gov links to.

**Temporary solution** as noted in the write-up of the issues, running wget from the command line automatically resumed the `.txt` file download from the files linked (as "`.csv`s") from data.gov, served via an eeoc.gov URL. I've written a bash script at `./extract/download_data.sh` to follow the naming pattern established from the data.gov links, iterating over year numbers. With that, I was able to download files for years 2009-2018, excluding 2010. That gives enough to work with to proceed defining a dat pipeline around this data while optimistically awaitng a response from the EEOC. 

### Data source update
Received word back from the EEOC that they had fixed the issues. I've verified that the Excel downloads work from eeoc.gov, and that the data files from data.gov can be downloaded without frequent timeouts.

I decided to switch back to using the Excel files from eeoc.gov as the primary source, since the 2019 and 2020 datasets are available there, but not on data.gov. I may come back later and supplement with the data.gov data for the earlier years that are not covered by complete Excel files on eeoc.gov.

Next issue encountered: Tried using the `tap-spreadsheets-anywhere` tap to load the Excel files directly. For these large Excel files, this is very slow. And encounter the next major issue: in the numeric columns of the Excel files, `NULL` values are indicated with a `*` in the cell. 

This is problematic to work with using `tap-spreadsheets-anywhere`. I don't have hooks to specify an alternate `NULL` character. Plus, some of the columns in some of the files have `*`'s that don't show up until many rows from the top of the file. In those cases, the type checking in the Meltano tap throws an error when it hits the `*`, since it had characterized the column as integer. I can work around that by increasing the sampling coverage, but that just extends the already-slow time, and more annoyingly, all the otherwise-numeric columns end up stored as strings in the resulting schema to accomodate the `*`s.  

So, time for another pivot in how to extract data from source. After a few iterations, ended up with the following solution:

* Bash script uses wget to iterate over the file URLS and download each file
* Using [xlsx2csv](https://github.com/dilshod/xlsx2csv), the Bash script extracts the data from each Excel file to `.csv`
* The final step of each iteration in the script: use `sed` to remove all asterisks from the `.csv`s
* Meltano `tap-spreadsheets-anywhere` loads the data from the folder containing the cleaned-up `csv` files.

The `xlsx2csv` and Meltano steps above are both slow. In future development, I'm considering skipping use of this tap for the initial pull of this data, and directly loading the folder of `.csv`s using `duckDB` instead. May consider a custom Meltano extractor that wraps all of this, to help manage the dependencies. 

### Start of Transformations
The last comment above seemed to be effective. It was much faster to load the cleaned `.csv` files directly with duckDB to parquet. 

Now the project ingests the full contents of the available Public Use File (PUF) excel files and materializes it to `.parquet`.

To generate the materialization, then explore the data in Rill Developer:

	make build
	make pipeline
	make rill-visuals