-- Exploratory Data Analysis

SELECT *
FROM layoffs_staging2;

-- Looking at total_laid_off to see how big these layoffs were
SELECT MAX(total_laid_off), MAX(percentage_laid_off)
FROM layoffs_staging2;

-- The Time Period Of Data 
SELECT MIN(`date`), MAX(`date`)
FROM layoffs_staging2;

--  Which companies had 100% percentage_laid_off?
SELECT *
FROM layoffs_staging2
WHERE percentage_laid_off = 1
ORDER BY funds_raised_millions DESC;

-- Companies with multiple layoff events
SELECT company , COUNT(*) as layoff_event
FROM layoffs_staging2
GROUP BY company
HAVING COUNT(*) >1
ORDER BY COUNT(*) DESC;

-- Company with there total laid offs in past 4-5 years or in the dataset
SELECT company , SUM(total_laid_off)
FROM layoffs_staging2
GROUP BY company
ORDER BY 2 DESC
LIMIT 5;

-- Indusrty with there total laid offs in past 4-5 years or in the dataset
SELECT industry , SUM(total_laid_off)
FROM layoffs_staging2
GROUP BY industry
ORDER BY 2 DESC;

-- Country with there total laid off in the dataset
SELECT country , SUM(total_laid_off)
FROM layoffs_staging2
GROUP BY country
ORDER BY 2 DESC;

-- Which industries have raised the most total funding?
SELECT industry , SUM(funds_raised_millions)
FROM layoffs_staging2
GROUP BY industry
ORDER BY 2 DESC;

-- stage with total laid off in the data set 
SELECT stage , SUM(total_laid_off)
FROM layoffs_staging2
GROUP BY stage
ORDER BY 2 DESC;

-- total laid off as Per Year 
SELECT YEAR(`date`) as yr, SUM(total_laid_off)
FROM layoffs_staging2
GROUP BY yr
ORDER BY 2 DESC;

-- total laid offs in the data set as per the month
SELECT SUBSTRING(`date`, 1,7) as dates, SUM(total_laid_off) as total_laid_offs
FROM layoffs_staging2
GROUP BY dates
ORDER BY dates;

-- Which stage has the most 100% layoffs?
SELECT stage, COUNT(*) 
FROM layoffs_staging2
WHERE percentage_laid_off = 1
GROUP BY stage
ORDER BY 2 DESC;

SELECT SUBSTRING(`date`, 1,7) as dates, SUM(total_laid_off) as total_laid_offs
FROM layoffs_staging2
GROUP BY dates
ORDER BY 2 DESC;

-- Rolling Total of layoffs per month 
WITH DATE_CTE AS
(
 SELECT SUBSTRING(`date`, 1,7) as dates, SUM(total_laid_off) as total_laid_offs
 FROM layoffs_staging2
 GROUP BY dates
 ORDER BY dates
 )
 SELECT dates ,SUM(total_laid_offs) OVER(ORDER BY dates ASC) as rolling_total_layoffs
 FROM DATE_CTE
 ORDER BY dates;
 
 -- Industry trend over months
 SELECT industry , SUBSTRING(`date`, 1,7) as `month`, SUM(total_laid_off) as total_laid_offs
 FROM layoffs_staging2
 GROUP BY industry , `month`
 HAVING `month` IS NOT NULL AND industry IS NOT NULL
 ORDER BY industry,`month`;

-- Averag percentage laid off by industry
SELECT industry, AVG(percentage_laid_off)
FROM layoffs_staging2
GROUP BY industry
ORDER BY 2 DESC;

-- Top 3 location from each country with highes total laid off
WITH loc AS(
SELECT country , location , SUM(total_laid_off) as total_laid_off
FROM layoffs_staging2
GROUP BY country , location
)
, loc_rank AS(
SELECT country , location , total_laid_off, DENSE_RANK() OVER(PARTITION BY country ORDER BY total_laid_off DESC) as ranking
FROM loc
)
SELECT *
FROM loc_rank
WHERE ranking <=3 AND total_laid_off IS NOT NULL;

-- Which company have raised the most total funding?
SELECT company , SUM(funds_raised_millions)
FROM layoffs_staging2
GROUP BY company
ORDER BY 2 DESC;

-- Companies with highest fundings but high layoffs
SELECT company , SUM(total_laid_off) as total_laid_off , SUM(funds_raised_millions) as funds_raised_millions
FROM layoffs_staging2
GROUP BY company 
ORDER BY 3 DESC, 1 DESC;
WITH layoff_ratio AS
(
SELECT company , (total_laid_off / funds_raised_millions) as ratio
FROM layoffs_staging2
)
SELECT company , AVG(ratio) as avg_ratio
FROM layoff_ratio
GROUP BY company 
ORDER BY 2 DESC;

SELECT *
FROM layoffs_staging2
WHERE company='Microsoft';

-- stage-wise 100% layoff
SELECT  stage , COUNT(*)
FROM layoffs_staging2
WHERE percentage_laid_off=1
GROUP BY stage
ORDER BY 2 DESC;

 -- Top 3 Most laid off Companies within a year
 WITH Company_Year AS
 (
  SELECT company , YEAR(`date`) as years , SUM(total_laid_off) as total_laid_off
  FROM layoffs_staging2
  GROUP BY company , years
  )
  , Company_Year_Rank AS
  (
   SELECT company , years , total_laid_off , DENSE_RANK() OVER (PARTITION BY years ORDER BY total_laid_off DESC) AS ranking
   FROM Company_Year
   GROUP BY company, years
   )
   SELECT company, years, total_laid_off , ranking
   FROM Company_Year_Rank
   WHERE ranking <= 3
   AND years IS NOT NULL
   ORDER BY years, total_laid_off DESC;
