/** Somehow SQL didn't read the decimal points in the float variables correctly**/
--Update C02EmissionData
--SET Per_Capita = Per_Capita / 1000000,  Total = Total/ 1000000, Coal = Coal / 1000000, Oil = Oil/ 1000000,
--	Gas = Gas / 1000000, Cement = Cement / 1000000, Flaring = Flaring /1000000, Other = Other /1000000,
--	OECD = OECD/ 1000000, OPEC = OPEC/ 1000000, G7 = G7/ 1000000

/**Top 5 Countries with highest Emissions in the 21st Century**/
--SELECT TOP (5) Country, Continent, AVG(Total) AS AverageTotal 
--FROM [C02EmissionData ]
--WHERE YEAR >= 2000 AND Country <> 'Global'
--GROUP BY Country, Continent
--ORDER BY AverageTotal DESC

/**Continents by Emission per Capita in 20th Century**/
--SELECT Continent, AVG(Per_Capita) AS AvgPerCapita
--FROM [C02EmissionData ] 
--WHERE Year >= 1900 AND Year < 2000
--GROUP BY Continent
--ORDER BY AvgPerCapita DESC

/** Finding most recent Year and then finding out the Country with the highest C02 Permissions per Capita**/
--SELECT MAX(Year)
--FROM [C02EmissionData ]

--SELECT TOP(1) Country, MAX(Per_Capita) AS MaxPercapita
--FROM [C02EmissionData ]
--WHERE YEAR = 2021
--GROUP BY Country
--ORDER BY MaxPerCapita DESC


/**Total Emissions of Coal in the 1990s by Country**/
--SELECT Country, SUM(Coal) AS TotalAmountofCoal
--FROM [C02EmissionData ]
--WHERE Decade = 1990 AND Country <> 'Global'
--GROUP BY Country
--HAVING SUM(Coal) IS NOT NULL
--ORDER BY TotalAmountofCoal DESC

/**Total Emissions in 2021 by Country and then by Continent**/
--SELECT Country, Total
--FROM [C02EmissionData ]
--WHERE Year = 2021 AND Country <> 'Global'
--ORDER BY Total DESC

--SELECT Continent, SUM(Total) AS TotalEmissions
--FROM [C02EmissionData ]
--WHERE Year = 2021 AND Country <> 'Global'
--GROUP BY Continent
--ORDER BY TotalEmissions DESC

--/**Using Case Statement to Order Countries by Per Capita Emissions**/
--WITH AG AS (SELECT Country, AVG(Per_Capita) AS AvgPerCapita
--	  FROM C02EmissionData
--	  WHERE Year >= 2000
--	  GROUP BY Country)
--SELECT Country, AvgPerCapita, 
--	  CASE
--		WHEN AvgPerCapita > 20000000 THEN 'Very High'
--		WHEN AvgPerCapita BETWEEN 10000000 AND 20000000 THEN 'High'
--		WHEN AvgPerCapita BETWEEN 5000000 AND 10000000 THEN 'Medium'
--		ELSE 'Low'
--	  END AS PerCapitaClass
--FROM AG
--ORDER BY AvgPerCapita DESC

/**Percentage of Total Emission that are from Coal for Continents by Decades since 1900**/
--WITH CoalData AS
--	(SELECT Continent, Decade, SUM(Total) AS Total, SUM(Coal) AS Coal
--	 FROM C02EmissionData
--	 WHERE Year >= 1900 AND Continent <> 'Antarctica'
--	 GROUP BY Continent, Decade)
--SELECT Continent, Decade, ROUND((Coal/Total)*100,2) AS PercentOfTotal
--FROM CoalData
--ORDER BY DECADE DESC

/**Finding the Decades after 1900 in which the European C02 Emissions were above its average since 1900**/
/*First get the Average*/
--WITH AN AS 
--	(SELECT Decade, SUM(Total) AS ST
--	 FROM C02EmissionData
--	 WHERE Continent = 'Europe' AND Year >= 1900
--	 GROUP BY Decade)
--SELECT AVG(ST)
--FROM AN

/*Then compare the different Decades to the Average*/
--SELECT Decade, SUM(Total) AS SumOfTotal
--FROM C02EmissionData
--WHERE Continent = 'Europe' AND Year >= 1900
--GROUP BY Decade
--HAVING SUM(Total) > 34885433850
--ORDER BY SUM(Total) DESC

/*Years in which Coal made up over 50% of the Different Countries Emissions*/
--SELECT Year, Coal/ Total AS ShareofCoal, Country, COUNT(Country) OVER (PARTITION BY Country) NumberofYears 
--FROM C02EmissionData
--WHERE Total <> 0 AND Total IS NOT NULL AND Coal/Total > 0.5
--ORDER BY NumberofYears DESC


/*_______________________________________________________________________________________*/
/*** Analyzing the different Organizations (OECD, OPEC, G7) ***/
/** Creating Stored-Procedures for Per Capita of the different Organizations since 200
	and Share of the different Organizations on total Emissions **/

/**Stored Procedure for Per_Capita: **/
--CREATE PROCEDURE Per_Capita_Orga (@Organization AS Nvarchar(50))
--AS
--DECLARE @DynVar1 AS NVARCHAR(MAX)
--SET @DynVar1 = 'SELECT ' + @Organization + ', AVG(Per_Capita) AS AvgPerCapita, Year
--FROM C02EmissionData
--WHERE Year >= 2000 AND Country <> ''Global'' AND ' + @Organization + ' IS NOT NULL 
--GROUP BY ' + @Organization + ', Year
--ORDER BY Year, ' + @Organization

--EXEC (@DynVar1)

/**Stored Procedure for Share of Total**/
--CREATE PROCEDURE Orga_of_Total (@Organization as Nvarchar(50))
--AS
--DECLARE @DynVar2 AS NVARCHAR(MAX)
--SET @DynVar2 =
--'WITH YearlyEmissions AS
--	(SELECT Year, Total AS Globale
--	 FROM C02EmissionData
--	 WHERE Country = ''Global'')
--SELECT C02EmissionData.Year, SUM(Total) / AVG(Globale) AS ShareOfOECD
--FROM C02EmissionData 
--	 JOIN YearlyEmissions ON C02EmissionData.Year = YearlyEmissions.Year
--WHERE C02EmissionData.Year > 2000 AND ' + @Organization +  ' = 1
--GROUP BY C02EmissionData.Year'

--EXEC (@DynVar2)


--EXEC Per_Capita_Orga @Organization = OECD
--EXEC Orga_of_Total @Organization = OECD

/** PerCapita of OECD Countries since 2000 */
--EXEC Per_Capita_Orga @Organization = OECD
/* While OECD Countries seem to have a higher PerCapita C02Emission rate, this trend seems to become smaller */


/**Share of OECD Countries on Total Emissions**/
--EXEC Orga_of_Total @Organization = OECD
/* In the early 2000s it was more then 50% of Total Emissions, by now it's only a bit more then 30% */

/** PerCapita of OPEC Countries since 2000 */
--EXEC Per_Capita_Orga @Organization = OPEC
/* Also way higher then the world average With a smaller trend to reduction */

/**Share of OPEC Countries on Total Emissions**/
--EXEC Orga_of_Total @Organization = OPEC
/*Only about 5-7% of Total, which makes sense regarding the fact that the countries dont make up a substantial part of the world population */

/** PerCapita of G7 Countries since 2000 */
--EXEC Per_Capita_Orga @Organization = G7
/* Pretty similiar to OPEC however stronger tendency of approximation*/ 

/**Share of G7 Countries on Total Emissions**/
--EXEC Orga_of_Total @Organization = G7
/*Indeed a very high share of the Global C02 Emissions regarding the fact that the only make up about 10% of the population
  However, the share the Global Emissions has almost decreased by 50% (40 % in 2000 and 22% in 2021)*/
