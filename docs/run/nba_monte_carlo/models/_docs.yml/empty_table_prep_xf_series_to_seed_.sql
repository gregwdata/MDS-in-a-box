select
      count(*) as failures,
      count(*) != 0 as should_warn,
      count(*) != 0 as should_error
    from (
      

    with __dbt__cte__prep_xf_series_to_seed as (
SELECT *
FROM '/tmp/data_catalog/psa/xf_series_to_seed/*.parquet'
GROUP BY ALL
)SELECT COALESCE(COUNT(*),0) AS records
    FROM __dbt__cte__prep_xf_series_to_seed
    HAVING COUNT(*) = 0


      
    ) dbt_internal_test