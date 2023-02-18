SELECT *
FROM {{ source( 'eeo1_pufs', 'eeo1_pufs_cleaned' ) }}
