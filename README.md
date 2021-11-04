# SQL Case Study: An investigation of a drop in user engagement
This case study is an opportunity to showcase the effect of my self-learning of SQL and using [the Mode platform](https://mode.com/sql-tutorial/a-drop-in-user-engagement/).<br>
It is based on a fictional company Yammer - a social network for communicating with coworkers.<br>
[Full description](https://mode.com/sql-tutorial/a-drop-in-user-engagement/)<br>
[Solution provided](https://mode.com/sql-tutorial/a-drop-in-user-engagement-answers)<br>
While the problem has a provided suggested solution, most of my analysis is different to those and hence has a level of originality. 

## The problem
<i>You show up to work Tuesday morning, September 2, 2014. The head of the Product team walks over to your desk and asks you what you think about the latest activity on the user engagement dashboards. You fire them up, and something immediately jumps out:<br>
<p align="center">
<img src="https://github.com/maciejtarsa/sql-user-engagement-drop/blob/main/data/fig1.png" width="700">
</p><br>
The above chart shows the number of engaged users each week. Yammer defines engagement as having made some type of server call by interacting with the product (shown in the data as events of type "engagement"). Any point in this chart can be interpreted as "the number of users who logged at least one engagement event during the week starting on that date."<br><br>

You are responsible for determining what caused the dip at the end of the chart shown above and, if appropriate, recommending solutions for the problem.</i>

## My list of possible causes to investigate
The first task is to think of possible causes, order them to structure the investigation and think of ways to test these hypotheses.
1. People are on holiday - the drop occured at the begining of August, in the middle of the summer, a lot of people may have taken holiday - for example a lot of people in France take most of August off - check if there are any differences country wise
2. There may be a reason activity was temporarily higher at the end of July - perhaps a one off event or marketing campaign - check if the higher activity was due to new sign-ups
3. A bug may have been introduced or something is not working - check for any particular features and if something is receiving no activity (for example new sign-ups) - this may pinpoint the problem
4. A bug related to specific devices - check for activity on specific devices

## Relevant tables
For this problem, 4 tables are of relevance:
* Table 1: Users - `tutorial.yammer_users`
* Table 2: Events - `tutorial.yammer_events`
* Table 3: Email events - `tutorial.yammer_emails`
* Table 4: Rollup periods - `benn.dimensions_rollup_periods`

## Investigations
I will now investigate my list of possible causes.

### 1. Holidays
I decided to compare the number of users that were active in each country in July with August. To do so, I set up two CTEs, one for counting users in July, and another in August.
```SQL
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
```
And then combined them on location, to check the locations with the biggest activity changes, both positive and negative.
```SQL
SELECT 
  COALESCE(j.location, a.location) AS location,
  100.0 * (a.no - j.no) / j.no AS activity_change
FROM July j
FULL OUTER JOIN August a
ON j.location = a.location
ORDER BY 2
```
Top 10 results were as follows:
Biggest negative change | % change | Biggest positive change | % change
------------ | ------------- | ------------- | -------------
Thailand | -51.0397 | Argentina | 94.5783
Switzerland | -48.0263 | Ireland | 54.5852
Belgium | -47.7457 | Denmark | 39.6947
Singapore | -45.8599 | Iraq | 30.3571
Norway | -43.0451 | Egypt | 23.1982
Venezuela | -42.6061 | Netherlands | 19.0630
Canada | -37.9100 | United Arab Emirates | 18.4685
Chile | -36.9072 | Pakistan | 13.2867
Austria | -34.4121 | Poland | 10.8935
France | -34.4117 | Portugal | 10.1408
<br>
These results do not indicate anything specific. Countries with the biggest negative changes are both in North hemisphere (where it was summer) and Southern hemisphere (where it was winter).
<br><br>
Instead of counts per country, I can check the average number of activities per user in each country and check how they changed between July and August. This will require changes to by CTE as follows:<br>

```SQL
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
)
```
And produces the following results:
Biggest negative change | % change | Biggest positive change | % change
------------ | ------------- | ------------- | -------------
Greece | -58.0882 | Argentina | 54.0412
Thailand | -43.5073 | Denmark | 45.0675
Belgium | -41.2139 | Netherlands | 42.5404
Singapore | -39.4904 | Chile | 32.4948
Switzerland | -38.6977 | Egypt | 30.0425
India | -33.1180 | Hong Kong | 24.7863
Malaysia | -31.4257 | United Arab Emirates | 23.2072
Norway | -29.4844 | Turkey | 17.6203
Brazil | -24.9071 | Israel | 11.4321
Venezuela | -24.3445 | Finland | 10.5263
<br>
Both lists feature a lot of the same countries but overall, neither is conclusive in any way about being being away on holiday being a cause for the drop in acvitity.

### 2. Sing-ons
TODO
### 3. Acitivities
TODO
### 4. Devices
