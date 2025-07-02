-- Create the new procedure for Weekly Fantasy Points
CREATE PROCEDURE dbo.PlayerWeeklyPoints
AS
BEGIN
    SET NOCOUNT ON;

    SELECT
        p.PlayerFirstName,
        p.PlayerLastName,
        s.Week,
        ROUND(s.PointsScored, 2) AS WeeklyPoints,
        SUM(ROUND(s.PointsScored, 2)) OVER (PARTITION BY p.PlayerID ORDER BY s.Week
        ) AS RunningWeeklyPoints
    FROM PlayerStats s
    JOIN Players p ON s.PlayerID = p.PlayerID
    ORDER BY p.PlayerFirstName, p.PlayerLastName, s.Week;
END;
GO

exec dbo.PlayerWeeklyPoints