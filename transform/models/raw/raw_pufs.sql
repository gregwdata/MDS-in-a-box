{{
    config(materialized='external')
}}

SELECT *
,regexp_extract(FILENAME,'_(\d+)_',1)::integer as YEAR -- get year from filename
FROM read_csv_auto({{ source( 'eeo1_pufs', 'eeo1_pufs_cleaned' ) }},FILENAME=True,header=True)
