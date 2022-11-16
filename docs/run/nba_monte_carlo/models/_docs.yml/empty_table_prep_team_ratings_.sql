select
      count(*) as failures,
      count(*) != 0 as should_warn,
      count(*) != 0 as should_error
    from (
      

    with __dbt__cte__prep_team_ratings as (
SELECT *
FROM '/tmp/data_catalog/psa/team_ratings/*.parquet'
)SELECT COALESCE(COUNT(*),0) AS records
    FROM __dbt__cte__prep_team_ratings
    HAVING COUNT(*) = 0


      
    ) dbt_internal_test