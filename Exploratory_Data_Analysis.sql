-- Exploratory Data Analysis

SELECT *
FROM layoffs_staging2;

SELECT MAX(total_laid_off), MAX(percentage_laid_off)
FROM layoffs_staging2;

SELECT *
FROM layoffs_staging2
WHERE percentage_laid_off = 1
ORDER BY funds_raised_millions DESC;

SELECT company , SUM(total_laid_off)
FROM layoffs_staging2
GROUP BY company
ORDER BY 2 DESC
LIMIT 5;

SELECT MIN(`date`), MAX(`date`)
FROM layoffs_staging2;

SELECT company , SUM(total_laid_off)
FROM layoffs_staging2
GROUP BY company
ORDER BY 2 DESC;

SELECT industry , SUM(total_laid_off)
FROM layoffs_staging2
GROUP BY industry
ORDER BY 2 DESC;

SELECT country , SUM(total_laid_off)
FROM layoffs_staging2
GROUP BY country
ORDER BY 2 DESC;

SELECT YEAR(`date`) as yr, SUM(total_laid_off)
FROM layoffs_staging2
GROUP BY yr
ORDER BY 2 DESC;

SELECT SUBSTRING(`date`, 1,7) as dates, SUM(total_laid_off) as total_laid_offs
FROM layoffs_staging2
GROUP BY dates
ORDER BY dates;

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
