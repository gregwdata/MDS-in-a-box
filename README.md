# EEOC MDS-in-a-Box
This branch of https://github.com/gregwdata/MDS-in-a-box is a fork of Jacob Matson's MDS-in-a-box project ([github repo](https://github.com/matsonj/nba-monte-carlo), [website](http://www.mdsinabox.com)). It is a work-in-progress to adapt the MDS-in-a-box stack to a new dataset.

This project will start with data published by the US Equal Employment Opportunity Commisson [eeoc.gov](https://www.eeoc.gov/data/job-patterns-minorities-and-women-private-industry-eeo-1-0) data for job patterns for minorities and women in private industry (EEO-1). 

## Project plan

- [ ] Extract and Load EEO-1 data form eeoc.gov-hosted Excel files using Meltano
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

After identifying the location where the error occurred within the `.txt` file, and checking the same location in the browser, it appears the data from the file is itself being served by data.gov in some unstable way that causes extra characters to be injected around 470 lines into the dataset!

One observation I have is the accumulated layers of extraction in using meltano plus a tap made it hard to debug this situation.

Now it's back to the drawing board for a new datasource, or I'll have to write some custom scripts to ingest this data (kind of defeating the purpose of MDS-in-a-box)