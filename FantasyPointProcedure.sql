-- Create the new procedure for Weekly Fantasy Points
create procedure dbo.playerweeklypoints
as
begin
    set nocount on;

    select
        p.playerfirstname,
        p.playerlastname,
        s.week,
        round(s.pointsscored, 2) AS weeklypoints,
        sum(round(s.pointsscored, 2)) over (partition by p.playerid order by s.week
        ) as runningweeklypoints
    from playerstats s
    join players p on s.playerid = p.playerid
    order by p.playerfirstname, p.playerlastname, s.week;
end;
go

exec dbo.playerweeklypoints
