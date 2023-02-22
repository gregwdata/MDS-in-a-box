{{
    config(materialized='external')
}}

{{ dbt_utils.unpivot(relation=ref('eeo1_county_naics2'), 
cast_to='integer', 
exclude=['Nation', 'Region', 'Division', 
'State', 'CBSA', 'County', 'NAICS2', 'NAICS2_Name', 
'NAICS3', 'NAICS3_Name','filename', 'YEAR'],
field_name='count_group',value_name='eeoc_1_count') }}
