-- Create Trigger to Calculate Fantasy Points Score

Create trigger CalculateFantasyPoints
on PlayerStats
after insert
as
begin
	set nocount on;

select 
	p.playerid,
	p.week,
	round(
		(RushingYards * .1) +
		(PassingYards * .05) +
		(ReceivingYards * .1) +
		(Touchdowns * 6) +
		(Interceptions * -4) +
		(Fumbles * -2),
		2
	) as FantasyPoints
	from PlayerStats p;
end; 
GO