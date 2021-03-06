SET NOCOUNT ON
/*~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*\
| Build demo data
\*~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*/
IF OBJECT_ID('tempdb..#Test') IS NOT NULL
    DROP TABLE #Test

CREATE TABLE #Test( TestId INT IDENTITY(1,1) PRIMARY KEY, Value DECIMAL(3,1))

INSERT INTO #Test( Value )
	 SELECT TOP 10
			0.1 * ABS(CHECKSUM(CAST(NEWID() AS VARCHAR(100))) % 1000) AS Value
	   FROM sys.columns

/*~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*\
| Lag & Lead functions examples:
----------- ------ ----------- ------------- ------------- ------------ -------------- --------------
TestId      Value  Lag(TestId) Lag(TestId,2) Lag(TestId,3) Lead(TestId) Lead(TestId,2) Lead(TestId,3)
----------- ------ ----------- ------------- ------------- ------------ -------------- --------------
1           22.3   NULL        NULL          NULL          2            3              4
2           94.1   1           NULL          NULL          3            4              5
3           13.3   2           1             NULL          4            5              6
4           17.6   3           2             1             5            6              7
5           37.1   4           3             2             6            7              8
6           39.2   5           4             3             7            8              9
7           70.6   6           5             4             8            9              10
8           32.4   7           6             5             9            10             NULL
9           34.5   8           7             6             10           NULL           NULL
10          73.2   9           8             7             NULL         NULL           NULL
\*~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*/
	SELECT TestId
		  ,Value
		  ,Lag(TestId)    OVER (ORDER BY TestId) AS [Lag(TestId)]
		  ,Lag(TestId,2)  OVER (ORDER BY TestId) AS [Lag(TestId,2)]
		  ,Lag(TestId,3)  OVER (ORDER BY TestId) AS [Lag(TestId,3)]
		  ,Lead(TestId)   OVER (ORDER BY TestId) AS [Lead(TestId)]
		  ,Lead(TestId,2) OVER (ORDER BY TestId) AS [Lead(TestId,2)]
		  ,Lead(TestId,3) OVER (ORDER BY TestId) AS [Lead(TestId,3)]
	  FROM #Test
  ORDER BY TestId
