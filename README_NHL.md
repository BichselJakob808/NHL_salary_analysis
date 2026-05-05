# NHL 2024-25 Player Salary & Performance Analysis

An end-to-end SQL analytics project exploring whether NHL teams are getting value from their player contracts.

---

## Overview

Using a dataset of **920 NHL players** from the 2024-25 season, this project investigates the relationship between player salaries and on-ice performance. The goal was to identify which players deliver the most value relative to their cap hit, which players are underperforming their contracts, and how production scales across salary tiers.

---

## Tools & Skills

- **Excel / Google Sheets** — data collection and cleaning
- **SQLite** — database creation and querying
- **SQL** — aggregations, CASE statements, filtering, derived metrics

---

## Dataset

- 920 players across all 32 NHL teams
- 34 columns including salary, goals, assists, points, TOI, xG, Corsi (iCF), and penalty data
- Cleaned and prepared manually, including handling mid-season trades and formatting inconsistencies
- Derived columns added: `Points_Per_Million`, `Goals_Per_Million`, `TOI_Per_Game`

---

## Key Questions Explored

1. Which players deliver the most points per dollar?
2. Which high-salary players are underperforming their contracts?
3. How does production scale across salary tiers?
4. Which cheap players are generating elite shot quality (xG)?
5. Which teams get the most offensive production per dollar spent?

---

## Sample Queries & Findings

### Best Value Players (Points per $1M)
```sql
SELECT "Clean Name", TeamID, PositionID, "Total Points", 
       printf('$%,.0f', Salary) AS Salary,
       round(Points_Per_Million, 2) AS Points_Per_Million
FROM nhl_players
WHERE "Games Played" >= 20
ORDER BY Points_Per_Million DESC
LIMIT 15;
```
**Finding:** Entry-level players dominate the value list. Mitch Marner leads at 93.5 pts/$1M — still on a bridge deal in 2024-25 — followed by JJ Peterka, Wyatt Johnston, and Connor Bedard, all producing elite numbers on rookie contracts.

---

### Salary Tier Analysis
```sql
SELECT 
    CASE 
        WHEN Salary >= 8000000 THEN 'Elite ($8M+)'
        WHEN Salary >= 5000000 THEN 'Top-6 ($5M-$8M)'
        WHEN Salary >= 2000000 THEN 'Mid ($2M-$5M)'
        ELSE 'Entry/Cheap (<$2M)'
    END AS Salary_Tier,
    COUNT(*) AS Players,
    round(AVG("Total Points"), 1) AS Avg_Points,
    round(AVG(Points_Per_Million), 2) AS Avg_Points_Per_Million
FROM nhl_players
WHERE "Games Played" >= 20
GROUP BY Salary_Tier
ORDER BY Salary_Tier;
```
**Finding:** Entry-level contracts produce **~20.5 points per $1M** — nearly 3x the return of elite contracts at **~6.7 points per $1M**. Teams that develop young talent on ELCs gain a massive cap advantage.

---

### Most Overpaid Players
**Finding:** Defensemen dominate the overpaid list by points — but this reveals a limitation of points-only analysis. Players like Charlie McAvoy and Miro Heiskanen provide value through shot suppression and defensive zone play that doesn't appear in the points column, highlighting the importance of multi-metric evaluation.

---

## How to Run

1. Clone this repository
2. Open `nhl_salaries.db` in any SQLite viewer (DB Browser for SQLite is free and recommended)
3. Run any of the queries from `queries.sql` against the `nhl_players` table
4. Or import `NHL_Point_Project.xlsx` into your own database to start fresh

---

## What I'd Add Next

- Integrate goalie and team defensive metrics to build a two-way value model
- Add year-over-year salary data to track contract aging curves
- Build a Tableau dashboard to visualize salary vs. production interactively
- Create a player comparison tool: input any two players and compare salary-adjusted stats

---

## Data Sources

- Salary data: public NHL cap tracking
- Performance stats: Natural Stat Trick / MoneyPuck
- Season: 2024-25 NHL Regular Season
