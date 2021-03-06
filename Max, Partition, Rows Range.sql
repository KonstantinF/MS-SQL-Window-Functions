SET NOCOUNT ON
/*~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*\
| Build demo data
\*~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*/
IF OBJECT_ID('tempdb..#Test') IS NOT NULL
    DROP TABLE #Test 

CREATE TABLE #Test( TestId INT, Value DECIMAL(3,1))

INSERT INTO #Test( TestId, Value )
	 SELECT TOP 10
	 		TestId = 1 + ROW_NUMBER() OVER ( ORDER BY (SELECT NULL) ) % 2
		  , Value = 0.1 * ABS(CHECKSUM(CAST(NEWID() AS VARCHAR(100))) % 1000) 
	   FROM sys.columns

/*~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*\
| Max() Over( Partition, Order By, Rows Between unbounded/current preceding and unbounded/current following)
| ------ ----- ------------- ---------------------------
| TestId Value  {MAX(Value)}  [MAX(Value)} {MAX(Value)] 
| ------ ----- ------------- ---------------------------
| 1      5.7   75.2          75.2         5.7
| 1      34.6  75.2          75.2         34.6
| 1      52.3  75.2          75.2         52.3
| 1      55.7  75.2          75.2         55.7
| 1      75.2  75.2          75.2         75.2
| 2      8.9   84.3          84.3         8.9
| 2      45.2  84.3          84.3         45.2
| 2      59.8  84.3          84.3         59.8
| 2      64.0  84.3          84.3         64.0
| 2      84.3  84.3          84.3         84.3
\*~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*/
	SELECT TestId
		  ,Value
		  ,MAX(Value) OVER (PARTITION BY TestId ORDER BY Value ROWS BETWEEN UNBOUNDED PRECEDING AND UNBOUNDED FOLLOWING) AS [ {MAX(Value)} ]
		  ,MAX(Value) OVER (PARTITION BY TestId ORDER BY Value ROWS BETWEEN CURRENT ROW AND UNBOUNDED FOLLOWING)		 AS [ [MAX(Value)} ]
		  ,MAX(Value) OVER (PARTITION BY TestId ORDER BY Value ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW)		 AS [ {MAX(Value)]] ]
	  FROM #Test
  ORDER BY TestId
		 , Value

/*~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*\
| Select DISTINCT - using by Row_Number()
| ----------- ---------------------------------------
| TestId Value {MAX(Value)}  [MAX(Value)} {MAX(Value)] 
| ----------- ---------------------------------------
| 1      5.7   75.2           75.2        5.7
| 2      8.9   84.3           84.3        8.9
\*~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*/
;WITH AllResults AS (
		SELECT TOP 100 PERCENT	
			   TestId
			  ,Value
			  ,MAX(Value) OVER (PARTITION BY TestId ORDER BY Value ROWS BETWEEN UNBOUNDED PRECEDING AND UNBOUNDED FOLLOWING) AS [ {MAX(Value)} ]
			  ,MAX(Value) OVER (PARTITION BY TestId ORDER BY Value ROWS BETWEEN CURRENT ROW AND UNBOUNDED FOLLOWING)		 AS [ [MAX(Value)} ]
			  ,MAX(Value) OVER (PARTITION BY TestId ORDER BY Value ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW)		 AS [ {MAX(Value)]] ]
			  ,Id = ROW_NUMBER() OVER (PARTITION BY TestId ORDER BY Value )
		  FROM #Test
	  ORDER BY TestId
			 , Value
		)
	SELECT TestId
		  ,Value
		  ,[ {MAX(Value)} ]
		  ,[ [MAX(Value)} ]
		  ,[ {MAX(Value)]] ]
	 FROM AllResults
	 WHERE Id = 1
