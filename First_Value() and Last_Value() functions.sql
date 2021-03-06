SET NOCOUNT ON
/*~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*\
| Build demo data
\*~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*/
IF OBJECT_ID('tempdb..#Test') IS NOT NULL
    DROP TABLE #Test

CREATE TABLE #Test( TestId INT, Value DECIMAL(3,1))

INSERT INTO #Test( TestId, Value )
	 SELECT TOP 9
	 		TestId = 1 + ROW_NUMBER() OVER ( ORDER BY (SELECT NULL) ) % 2
		  , Value = 0.1 * ABS(CHECKSUM(CAST(NEWID() AS VARCHAR(100))) % 1000) 
	   FROM sys.columns

/*~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*\
| Example of First_Value() and Last_Value() functions
| ------ ----- ---------------------- -------------------- --------------------
| TestId Value  {FIRST_VALUE(Value)}   {LAST_VALUE(Value)]  {LAST_VALUE(Value)} 
| ------ ----- ---------------------- -------------------- --------------------
| 1      4.4   4.4                    4.4                  78.7
| 1      36.3  4.4                    36.3                 78.7
| 1      56.8  4.4                    56.8                 78.7
| 1      78.7  4.4                    78.7                 78.7
| 2      5.7   5.7                    5.7                  95.9
| 2      32.1  5.7                    32.1                 95.9
| 2      56.6  5.7                    56.6                 95.9
| 2      90.5  5.7                    90.5                 95.9
| 2      95.9  5.7                    95.9                 95.9
\*~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*/ 
	SELECT TestId
		  ,Value
		  ,FIRST_VALUE(Value) OVER (PARTITION BY TestId ORDER BY Value ROWS UNBOUNDED PRECEDING ) AS [ {FIRST_VALUE(Value)} ]
		  ,LAST_VALUE(Value) OVER (PARTITION BY TestId ORDER BY Value ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW) AS [ {LAST_VALUE(Value)]] ]
		  ,LAST_VALUE(Value) OVER (PARTITION BY TestId ORDER BY Value ROWS BETWEEN UNBOUNDED PRECEDING AND UNBOUNDED FOLLOWING ) AS [ {LAST_VALUE(Value)} ]
	  FROM #Test
  ORDER BY TestId
		 , Value
		  

 

 
