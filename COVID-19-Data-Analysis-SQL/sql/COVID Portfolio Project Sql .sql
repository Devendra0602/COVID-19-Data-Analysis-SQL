/*
Project: COVID-19 Data Analysis using SQL
Database: PortfolioProject
Author: Devendra Patil
*/

-- =====================================================
-- 1. DATA EXPLORATION
-- =====================================================

SELECT
    location,
    date,
    total_cases,
    new_cases,
    total_deaths,
    population
FROM PortfolioProject..CovidDeaths
WHERE continent IS NOT NULL
ORDER BY location, date;

-- =====================================================
-- 2. TOTAL CASES VS TOTAL DEATHS (India)
-- Likelihood of dying after contracting COVID
-- =====================================================

SELECT
    location,
    date,
    total_cases,
    total_deaths,
    ROUND((total_deaths / NULLIF(total_cases, 0)) * 100, 2) AS DeathPercentage
FROM PortfolioProject..CovidDeaths
WHERE location = 'India'
ORDER BY date;

-- =====================================================
-- 3. TOTAL CASES VS POPULATION
-- Percentage of population infected
-- =====================================================

SELECT
    location,
    date,
    population,
    total_cases,
    ROUND((total_cases / NULLIF(population, 0)) * 100, 2) AS PercentPopulationInfected
FROM PortfolioProject..CovidDeaths
WHERE continent IS NOT NULL
ORDER BY location, date;

-- =====================================================
-- 4. COUNTRIES WITH HIGHEST INFECTION RATE
-- =====================================================

SELECT
    location,
    population,
    MAX(total_cases) AS HighestInfectionCount,
    ROUND(MAX((total_cases / NULLIF(population, 0))) * 100, 2) AS PercentPopulationInfected
FROM PortfolioProject..CovidDeaths
WHERE continent IS NOT NULL
GROUP BY location, population
ORDER BY PercentPopulationInfected DESC;

-- =====================================================
-- 5. COUNTRIES WITH HIGHEST DEATH COUNT
-- =====================================================

SELECT
    location,
    MAX(CAST(total_deaths AS INT)) AS TotalDeathCount
FROM PortfolioProject..CovidDeaths
WHERE continent IS NOT NULL
GROUP BY location
ORDER BY TotalDeathCount DESC;

-- =====================================================
-- 6. DEATH COUNT BY CONTINENT
-- =====================================================

SELECT
    continent,
    MAX(CAST(total_deaths AS INT)) AS TotalDeathCount
FROM PortfolioProject..CovidDeaths
WHERE continent IS NOT NULL
GROUP BY continent
ORDER BY TotalDeathCount DESC;

-- =====================================================
-- 7. GLOBAL COVID NUMBERS
-- =====================================================

SELECT
    SUM(new_cases) AS TotalCases,
    SUM(CAST(new_deaths AS INT)) AS TotalDeaths,
    ROUND(SUM(CAST(new_deaths AS INT)) / NULLIF(SUM(new_cases), 0) * 100, 2) AS DeathPercentage
FROM PortfolioProject..CovidDeaths
WHERE continent IS NOT NULL;

-- =====================================================
-- 8. POPULATION VS VACCINATIONS (Window Function)
-- =====================================================

SELECT
    dea.continent,
    dea.location,
    dea.date,
    dea.population,
    vac.new_vaccinations,
    SUM(CAST(vac.new_vaccinations AS INT))
        OVER (PARTITION BY dea.location ORDER BY dea.date) AS RollingPeopleVaccinated
FROM PortfolioProject..CovidDeaths dea
JOIN PortfolioProject..CovidVaccinations vac
    ON dea.location = vac.location
   AND dea.date = vac.date
WHERE dea.continent IS NOT NULL
ORDER BY dea.location, dea.date;

-- =====================================================
-- 9. USING CTE FOR VACCINATION ANALYSIS
-- =====================================================

WITH PopulationVsVaccination AS (
    SELECT
        dea.continent,
        dea.location,
        dea.date,
        dea.population,
        vac.new_vaccinations,
        SUM(CAST(vac.new_vaccinations AS INT))
            OVER (PARTITION BY dea.location ORDER BY dea.date) AS RollingPeopleVaccinated
    FROM PortfolioProject..CovidDeaths dea
    JOIN PortfolioProject..CovidVaccinations vac
        ON dea.location = vac.location
       AND dea.date = vac.date
    WHERE dea.continent IS NOT NULL
)
SELECT
    *,
    ROUND((RollingPeopleVaccinated / NULLIF(population, 0)) * 100, 2) AS PercentVaccinated
FROM PopulationVsVaccination;

-- =====================================================
-- 10. CREATING VIEWS FOR REUSABILITY
-- =====================================================

CREATE VIEW PercentPopulationVaccinated AS
SELECT
    dea.continent,
    dea.location,
    dea.date,
    dea.population,
    vac.new_vaccinations,
    SUM(CAST(vac.new_vaccinations AS INT))
        OVER (PARTITION BY dea.location ORDER BY dea.date) AS RollingPeopleVaccinated
FROM PortfolioProject..CovidDeaths dea
JOIN PortfolioProject..CovidVaccinations vac
    ON dea.location = vac.location
   AND dea.date = vac.date
WHERE dea.continent IS NOT NULL;

CREATE VIEW ContinentDeathData AS
SELECT
    continent,
    MAX(CAST(total_deaths AS INT)) AS TotalDeathCount
FROM PortfolioProject..CovidDeaths
WHERE continent IS NOT NULL
GROUP BY continent;

CREATE VIEW GlobalCovidData AS
SELECT
    SUM(new_cases) AS TotalCases,
    SUM(CAST(new_deaths AS INT)) AS TotalDeaths,
    ROUND(SUM(CAST(new_deaths AS INT)) / NULLIF(SUM(new_cases), 0) * 100, 2) AS DeathPercentage
FROM PortfolioProject..CovidDeaths
WHERE continent IS NOT NULL;
