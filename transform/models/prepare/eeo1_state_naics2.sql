{{
    config(materialized='external')
}}

SELECT *
FROM {{ ref( 'raw_pufs' ) }}
WHERE STATE NOT NULL
AND NAICS2 NOT NULL
AND NAICS3 IS NULL
AND County IS NULL
AND CBSA IS NULL