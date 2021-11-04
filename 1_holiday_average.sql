WITH July AS (
  SELECT 
    s.month,
    s.location,
    AVG(s.no) as average
  FROM (
    SELECT 
      CONCAT( EXTRACT('year' FROM e.occurred_at), '-', EXTRACT('month' FROM e.occurred_at) ) as month,
      e.location,
      e.user_id,
      COUNT(*) as no
    FROM tutorial.yammer_events e
    GROUP BY 1, 2, 3
    ORDER BY 2, 1
  ) s
  WHERE month ='2014-7'
  GROUP BY 1, 2
), August AS (
  SELECT
    s.month,
    s.location,
    AVG(s.no) as average
  FROM (
    SELECT 
      CONCAT( EXTRACT('year' FROM e.occurred_at), '-', EXTRACT('month' FROM e.occurred_at) ) as month,
      e.location,
      e.user_id,
      COUNT(*) as no
    FROM tutorial.yammer_events e
    GROUP BY 1, 2, 3
    ORDER BY 2, 1
  ) s
  WHERE month ='2014-8'
  GROUP BY 1, 2
)

SELECT 
  COALESCE(j.location, a.location) AS location,
  100.0 * (a.average - j.average) / j.average AS activity_change
FROM July j
FULL OUTER JOIN August a
ON j.location = a.location
ORDER BY 2 DESC
