# standardsql
# works with Google Analytics demo data on bigquery
# finds steps and eliminates consecutive occurences of the same step 
# possible: step1 > step2 > step1
# NOT possible:  step1 > step1 > step2 - would get reduced to: step1 > step2
WITH funnels AS (
SELECT 
  fullvisitorid,
  visitstarttime,
  ARRAY(SELECT AS STRUCT 
    hitNumber,
    step
  FROM UNNEST(ARRAY(
      SELECT AS STRUCT 
        hitnumber,
        REGEXP_EXTRACT(page.pagePath, r'/(basket|yourinfo|payment|revieworder)\.html') step,
        LAG(REGEXP_EXTRACT(page.pagePath, r'/(basket|yourinfo|payment|revieworder)\.html')) OVER (ORDER BY hitNumber) previousStep
      FROM t.hits 
      WHERE type = 'PAGE' 
        AND REGEXP_CONTAINS(page.pagePath, r'/(basket|yourinfo|payment|revieworder)\.html'))
    )
    WHERE step!=previousStep OR previousStep is NULL) journey    
FROM 
  `bigquery-public-data.google_analytics_sample.ga_sessions_20170801` t 
)

SELECT 
  *
FROM funnels f
WHERE ARRAY_LENGTH(f.journey)>0
LIMIT 1000
