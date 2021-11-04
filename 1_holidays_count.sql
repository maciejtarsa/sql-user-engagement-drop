WITH July AS (
  SELECT *
  FROM (
    SELECT 
      CONCAT( EXTRACT('year' FROM e.occurred_at), '-', EXTRACT('month' FROM e.occurred_at) ) as month,
      e.location,
      COUNT(*) as no
    FROM tutorial.yammer_events e
    GROUP BY 1, 2
    ORDER BY 2, 1
  ) s
  WHERE month ='2014-7'
), August AS (
  SELECT *
  FROM (
    SELECT 
      CONCAT( EXTRACT('year' FROM e.occurred_at), '-', EXTRACT('month' FROM e.occurred_at) ) as month,
      e.location,
      COUNT(*) as no
    FROM tutorial.yammer_events e
    GROUP BY 1, 2
    ORDER BY 2, 1
  ) s
  WHERE month ='2014-8'
)

SELECT 
  COALESCE(j.location, a.location) AS location,
  100.0 * (a.no - j.no) / j.no AS activity_change
FROM July j
FULL OUTER JOIN August a
ON j.location = a.location
ORDER BY 2
