-- 1. Create Player Reports for each Position (QB, RB, TE, WR)
--Running Backs (Created View)
select 
concat(playerfirstname, ' ', PlayerLastName) as PlayerName,
position,
sum(rushingyards) as total_rushing_yards,
sum(receptions) as total_receptions,
sum(receivingyards) as total_receiving_yards,
sum(touchdowns) as total_touchdowns,
sum(fumbles) as total_fumbles,
round(sum(pointsscored),2) as total_fantasy_points,
count(distinct week) as total_games_played,
sum(rushingyards) / count(distinct week) as Avg_Yds_Per_Game
from players, playerstats
where players.PlayerID = playerstats.PlayerID
group by PlayerFirstName, PlayerLastName, position
having position like 'RB';

-- Wide Receivers(Created View)
select 
concat(playerfirstname, ' ', PlayerLastName) as PlayerName,
position,
sum(receptions) as total_receptions,
sum(receivingyards) as total_receiving_yards,
sum(touchdowns) as total_touchdowns,
sum(fumbles) as total_fumbles,
round(sum(pointsscored),2) as total_fantasy_points,
count(distinct week) as total_games_played,
sum(receivingyards) / count(distinct week) as Avg_Yds_Per_Game
from players, playerstats
where players.PlayerID = playerstats.PlayerID
group by PlayerFirstName, PlayerLastName, position
having position like 'WR';


-- Tight Ends (Created View)
select 
concat(playerfirstname, ' ', PlayerLastName) as PlayerName,
position,
sum(receptions) as total_receptions,
sum(receivingyards) as total_receiving_yards,
sum(touchdowns) as total_touchdowns,
round(sum(pointsscored),2) as total_fantasy_points,
count(distinct week) as total_games_played,
sum(receivingyards) / count(distinct week) as Avg_Yds_Per_Game
from players, playerstats
where players.PlayerID = playerstats.PlayerID
group by PlayerFirstName, PlayerLastName, position
having position like 'TE';

-- Quarter Backs (Created View)
select 
concat(playerfirstname, ' ', PlayerLastName) as PlayerName,
position,
sum(passingyards) as total_passing_Yards,
sum(touchdowns) as total_touchdowns,
sum(interceptions) as total_interceptions,
round(sum(pointsscored),2) as total_fantasy_points,
count(distinct week) as total_games_played,
sum(passingyards) / count(distinct week) as Avg_Yds_Per_Game
from players, playerstats
where players.PlayerID = playerstats.PlayerID
group by PlayerFirstName, PlayerLastName, position
having position like 'QB';

-- 2. Create a cummulative analysis for fantasy points each week
select
playerfirstname,
playerlastname,
week,
position,
TeamName,
FantasyPoints,
sum(weekly_points) over(partition by playerfirstname, playerlastname order by week) as Running_FantasyPoints
from (
select
playerfirstname,
playerlastname,
position,
players.TeamName,
round(pointsscored,2) as FantasyPoints,
round(pointsscored,2) as weekly_points,
week
from playerstats, players
where playerstats.PlayerID = players.PlayerID
) t;

-- 3. Create a table to show all the leading NFL Players in all stats (Receiving, Passing, and Rushing Yards)
with Rushing_Leader as (
    select top 1
        concat(playerfirstname, ' ', playerlastname) as PlayerName,
        sum(RushingYards) as Total_Rushing_Yards
    from players
    join PlayerStats on players.PlayerID = PlayerStats.PlayerID
    group by playerfirstname, playerlastname
    order by Total_Rushing_Yards desc
),
Passing_Leader as (
    select top 1
        concat(playerfirstname, ' ', playerlastname) as PlayerName,
        sum(PassingYards) as Total_Passing_Yards
    from players
    join PlayerStats on players.PlayerID = PlayerStats.PlayerID
    group by playerfirstname, playerlastname
    order by Total_Passing_Yards desc
),
Receiving_Leader as (
    select top 1
        concat(playerfirstname, ' ', playerlastname) as PlayerName,
        sum(ReceivingYards) as Total_Receiving_Yards
    from players
    join PlayerStats on players.PlayerID = PlayerStats.PlayerID
    group by playerfirstname, playerlastname
    order by Total_Receiving_Yards desc
)

select 
    r.PlayerName as Rushing_Leader,
    r.Total_Rushing_Yards,
    p.PlayerName as Passing_Leader,
    p.Total_Passing_Yards,
    rec.PlayerName as Receiving_Leader,
    rec.Total_Receiving_Yards
from Rushing_Leader r
cross join Passing_Leader p
cross join Receiving_Leader rec;


-- 4. Show all the team names that are in the fantasy league and the nfl players they drafted
select
f.teamname,
d.teamid,
d.leagueid,
concat(playerfirstname, ' ', playerlastname) as PlayerName,
d.picknumber
from drafts d, FantasyTeams f, players p
where d.TeamID = f.TeamID
and p.PlayerID = d.PlayerID;

-- 5. Show the total fantasy points for all teams each week for League 1
select
f.teamname,
f.teamid,
f.leagueid,
round(sum(pointsscored),2) as FantasyTeamPoints,
week
from FantasyTeams f, playerstats p, drafts d
where d.TeamID = f.TeamID
and d.PlayerID = p.PlayerID
group by f.teamname, f.teamid, week, f.leagueid
having f.leagueid like '1'
order by week asc, FantasyTeamPoints desc;

-- 6. Show the total fantasy points for all teams each week for League 2
select
f.teamname,
f.teamid,
f.leagueid,
round(sum(pointsscored),2) as FantasyTeamPoints,
week
from FantasyTeams f, playerstats p, drafts d
where d.TeamID = f.TeamID
and d.PlayerID = p.PlayerID
group by f.teamname, f.teamid, week, f.leagueid
having f.leagueid like '2'
order by week asc, FantasyTeamPoints desc;

-- 7. Top consistent players from week-to-week 
select
p.PlayerFirstName,
p.PlayerLastName,
count(*) as GamesPlayed,
round(avg(ps.PointsScored),2) as AvgPoints,
round(stdev(ps.PointsScored),2) as StdDev
from PlayerStats ps
JOIN Players p on ps.PlayerID = p.PlayerID
group by p.PlayerFirstName, p.PlayerLastName
order by StdDev asc;

--8. Team scored the most points each week
select week, teamname, FantasyTeamPoints
from (
select
p.week,
f.TeamName,
round(sum(p.PointsScored),2) AS FantasyTeamPoints,
rank() over (partition by p.week order by sum(p.PointsScored) desc) as rnk
from FantasyTeams f
JOIN Drafts d on d.TeamID = f.TeamID
JOIN PlayerStats p on d.PlayerID = p.PlayerID
group by p.week, f.TeamName
) t
where rnk = 1;