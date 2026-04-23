--Q1 Identify matches played between two specific teams (e.g., India and South Africa) in 2024 and their results.

select *
 from T20I
 where(Team1 = 'South Africa' And Team2 = 'India') Or (Team2 = 'South Africa' and Team1 = 'India')
 And Year(MatchDate) = 2024;

--Q2 Find the team with the highest number of wins in 2024 and the total matches it won.
Select winner,count(*) As 'Numberofwins'
from T20I
where year(matchdate) = 2024
Group By winner
order by Numberofwins Desc 
limit 1;

--Q3 Rank the teams based on the total number of wins in 2024.
Select winner, count(*) As 'Number of wins',
Dense_Rank() Over(order by count(*)Desc) As Rank_Assigned
from T20I
where year(matchdate) = 2024 And Winner Not In('tied', 'no result')
group by winner

--Q4 Which team had the highest average winning margin (in runs), and what was the average margin?


SELECT Winner,
       AVG(CAST(Trim(SUBSTRING_INDEX(Margin, ' ', 1)) AS UNSIGNED)) AS Avg_Margin
FROM T20I
WHERE Margin LIKE '%runs'
GROUP BY Winner
ORDER BY Avg_Margin Desc
LIMIT 1;

--Q4.1 Which team had the highest average winning margin (in wickets), and what was the average margin?


SELECT Winner,
       AVG(CAST(Trim(SUBSTRING_INDEX(Margin, ' ', 1)) AS UNSIGNED)) AS Avg_Margin
FROM T20I
WHERE Margin LIKE '%wickets'
GROUP BY Winner
ORDER BY Avg_Margin Desc
LIMIT 1;

--Q5 List all matches where the winning margin was greater than the average margin across all matches.

WITH CTE_AvgMargin AS (
    SELECT AVG(CAST(TRIM(SUBSTRING_INDEX(Margin, ' ', 1)) AS UNSIGNED)) AS Avg_OverAllMargin
    FROM T20I
    WHERE Margin LIKE '%runs'
)
SELECT T.team1,T.Team2,T.winner, T.Margin
FROM T20I T
CROSS JOIN CTE_AvgMargin A
WHERE T.Margin LIKE '%runs'
  AND CAST(TRIM(SUBSTRING_INDEX(T.Margin, ' ', 1)) AS UNSIGNED) > A.Avg_OverAllMargin;
  
  --Q6 Find the team with the most wins when chasing a target (wins by wickets)
SELECT winner,WinWhileChasing
from(
SELECT winner,count(*) As WinWhileChasing,
Rank() Over(order by Count(*) Desc) As rk
FROM T20I 
where Margin Like '%wickets'
And Winner Not in ('tied', 'no result')
Group By winner 
) t
where rk = 1

--Q7 Head-to-head record between two selected teams (e.g., England vs Australia).

Select winner, count(*) As Matches
from T20I 
where (Team1 = 'England' And Team2 = 'South Africa') or (Team1 = 'South Africa' And Team2 = 'England')
Group By winner;

--Q8 Identify the month in 2024 with the highest number of T20I matches played.

WITH CTE_MatchesPlayed AS (
    SELECT Team, COUNT(*) AS MatchesPlayed
    FROM (
        SELECT Team1 AS Team
        FROM T20I
        WHERE YEAR(MatchDate) = 2024

        UNION ALL

        SELECT Team2 AS Team
        FROM T20I
        WHERE YEAR(MatchDate) = 2024
    ) t
    GROUP BY Team
),

CTE_Wins AS (
    SELECT winner AS Team, COUNT(*) AS Wins
    FROM T20I
    WHERE YEAR(MatchDate) = 2024 
      AND winner NOT IN ('tied', 'no result')
    GROUP BY winner
)

SELECT 
    m.Team, 
    m.MatchesPlayed,
    IFNULL(w.Wins, 0) AS Wins,
    Cast(IFNULL(w.Wins, 0) * 100.0 / m.MatchesPlayed As Decimal(5,2)) AS winPercentage
FROM CTE_MatchesPlayed m
LEFT JOIN CTE_Wins w
    ON m.Team = w.Team
ORDER BY winPercentage DESC;

--Q10 Identify the most successful team at each ground (team with most wins per groud)
With CTE_WinsPerGround As(
Select Ground, winner, wins, Rank() Over (Partition by Ground Order By wins Desc) As rn
from
(
Select Ground, winner,count(*) As wins
from T20I
where winner Not In ('tied','no result')
group by ground,winner
)t
)
Select Ground, Winner as MostSuccessful, wins
from CTE_WinsPerGround
where rn = 1
order by ground;
 
