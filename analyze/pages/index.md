# EEOC Data Compilation

Welcome to the [NBA monte carlo simulator](https://github.com/matsonj/nba-monte-carlo) project. Evidence is used as the as data visualization & analysis part of [MDS in a box](https://www.dataduel.co/modern-data-stack-in-a-box-with-duckdb/).

This project leverages duckdb, meltano, dbt, and evidence and builds and runs about once per day in a github action. You can learn more about this on [this page](/about).

```count_eeo1_state_naics2
select
  count(*) as num_rows_num0
from eeo1_state_naics2
```

```reg_season
select
  conf,
  team,
  elo_rating,
  avg_wins,
  COALESCE(made_playoffs / 10000.0,0) as make_playoffs_pct1,
  COALESCE(won_finals / 10000.0,0) as win_finals_pct1
from season_summary
order by conf, avg_wins desc
```

```east_conf
select
  '[' || team || '](/teams/' || team || ')' as team_link,
  team,
  elo_rating,
  avg_wins,
  make_playoffs_pct1,
  win_finals_pct1
from ${reg_season}
WHERE conf = 'East'
```

```west_conf
select
  '[' || team || '](/teams/' || team || ')' as team_link,
  team,
  elo_rating,
  avg_wins,
  make_playoffs_pct1,
  win_finals_pct1
from ${reg_season}
WHERE conf = 'West'
```

```seed_details
SELECT
    winning_team as team,
    season_rank as seed,
    conf,
    count(*) / 10000.0 as occurances_pct1
FROM reg_season_end
GROUP BY ALL
ORDER BY seed
```

```wins_seed_scatter
SELECT
    winning_team as team,
    conf,
    count(*) / 10000.0 as odds_pct1,
    case when season_rank <= 6 then 'top six seed'
        when season_rank between 7 and 10 then 'play in'
        else 'missed playoffs'
    end as season_result,
    Count(*) FILTER (WHERE season_rank <=6)*-1 AS sort_key
FROM reg_season_end
GROUP BY ALL
ORDER BY sort_key
```

```thru_date
SELECT max(date) as end_date FROM latest_results
```

```show_tables
PRAGMA show_tables
```

```unpivot_county_n2
SELECT * EXCLUDE(filename)
FROM unpivot_county_n2
WHERE YEAR = 2019
limit 1000
```

## The database contains the following tables
<DataTable data={show_tables} search=true>
    <column id=name/>
</DataTable>

## Count of rows in some tables
_<sub>There are <Value data={count_eeo1_state_naics2} column=num_rows_num0/> rows in `count_eeo1_state_naics2`.</sub>_

## Sample of a table
The first 1,000 rows of long-formatted 2019 county-level NAICS 2 data are shown here:
<DataTable data={unpivot_county_n2} search=true/>

## Conference Summaries
_<sub>This data was last updated as of <Value data={thru_date} column=end_date/>.</sub>_

### End of Season Seeding
<AreaChart
    data={seed_details.filter(d => d.conf === "East")} 
    x=seed
    y=occurances_pct1
    series=team
    xAxisTitle=seed
    title='Eastern Conference'
    yMax=1
/>

<AreaChart
    data={seed_details.filter(d => d.conf === "West")} 
    x=seed
    y=occurances_pct1
    series=team
    xAxisTitle=seed
    title='Western Conference'
    yMax=1
/>

### End of Season Playoff Odds
<BarChart
    data={wins_seed_scatter.filter(d => d.conf === "East")} 
    x=team
    y=odds_pct1
    series=season_result
    xAxisTitle=seed
    title='Eastern Conference'
    swapXY=true
    sort=sort_key
/>

<BarChart
    data={wins_seed_scatter.filter(d => d.conf === "West")} 
    x=team
    y=odds_pct1
    series=season_result
    xAxisTitle=seed
    title='Western Conference'
    swapXY=true
    sort=sort_key
/>
