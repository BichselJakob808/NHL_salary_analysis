-- ============================================================
-- NHL 2024-25 Player Salary & Performance Analysis
-- Author: Jakob Bichsel
-- Tools: SQLite
-- ============================================================
-- This file contains queries used to analyze NHL player
-- salaries against on-ice performance for the 2024-25 season.
-- The dataset covers 920 players across all 32 NHL teams.
-- ============================================================


-- Step 1: Preview the data
-- Get a quick look at the first 10 rows to understand the dataset
SELECT *
FROM nhl_players
LIMIT 10;


-- Step 2: Count how many players are in the dataset
SELECT COUNT(*) AS total_players
FROM nhl_players;


-- Step 3: Top 15 Best Value Players (Points per $1M salary)
-- Filters to players with at least 20 games played
-- to remove small sample sizes
SELECT 
    "Clean Name",
    TeamID,
    PositionID,
    "Total Points",
    printf('$%,.0f', Salary) AS Salary,
    round(Points_Per_Million, 2) AS Points_Per_Million
FROM nhl_players
WHERE "Games Played" >= 20
ORDER BY Points_Per_Million DESC
LIMIT 15;


-- Step 4: Most Overpaid Players (High salary, low value)
-- Filters to players earning $3M or more with at least 40 games played
-- comparing full season players on real contracts
SELECT 
    "Clean Name",
    TeamID,
    PositionID,
    "Total Points",
    printf('$%,.0f', Salary) AS Salary,
    round(Points_Per_Million, 2) AS Points_Per_Million
FROM nhl_players
WHERE "Games Played" >= 40 AND Salary >= 3000000
ORDER BY Points_Per_Million ASC
LIMIT 15;


-- Step 5: Average salary and points by position
-- Groups players by position to compare how each position
-- is paid versus how much they produce
SELECT 
    PositionID AS Position,
    COUNT(*) AS Players,
    printf('$%,.0f', AVG(Salary)) AS Avg_Salary,
    round(AVG("Total Points"), 1) AS Avg_Points,
    round(AVG(Points_Per_Million), 2) AS Avg_Points_Per_Million
FROM nhl_players
WHERE "Games Played" >= 20
GROUP BY PositionID
ORDER BY AVG(Salary) DESC;


-- Step 6: Salary Tier Analysis
-- Breaks players into four salary tiers and compares
-- how much production each tier delivers per dollar
SELECT 
    CASE 
        WHEN Salary >= 8000000 THEN '1. Elite ($8M+)'
        WHEN Salary >= 5000000 THEN '2. Top ($5M-$8M)'
        WHEN Salary >= 2000000 THEN '3. Mid ($2M-$5M)'
        ELSE '4. Entry/Cheap (Under $2M)'
    END AS Salary_Tier,
    COUNT(*) AS Players,
    printf('$%,.0f', AVG(Salary)) AS Avg_Salary,
    round(AVG("Total Points"), 1) AS Avg_Points,
    round(AVG(Points_Per_Million), 2) AS Avg_Points_Per_Million
FROM nhl_players
WHERE "Games Played" >= 20
GROUP BY Salary_Tier
ORDER BY Salary_Tier;


-- Step 7: Hidden Gems (High shot quality, low salary)
-- Uses expected goals (ixG) to find cheap players
-- who are generating elite scoring chances
SELECT 
    "Clean Name",
    TeamID,
    PositionID,
    printf('$%,.0f', Salary) AS Salary,
    ixG,
    "Total Points",
    round(Points_Per_Million, 2) AS Points_Per_Million
FROM nhl_players
WHERE "Games Played" >= 20 AND Salary < 2000000
ORDER BY ixG DESC
LIMIT 15;


-- Step 8: Team Payroll Efficiency
-- Compares how many points each team generates
-- per $1M of total salary spent
SELECT 
    TeamID,
    COUNT(*) AS Roster_Size,
    printf('$%,.0f', SUM(Salary)) AS Total_Payroll,
    SUM("Total Points") AS Total_Points,
    round(SUM("Total Points") * 1.0 / (SUM(Salary) / 1000000), 2) AS Points_Per_Million_Spent
FROM nhl_players
WHERE "Games Played" >= 20
GROUP BY TeamID
ORDER BY Points_Per_Million_Spent DESC;
