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
