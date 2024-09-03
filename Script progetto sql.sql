CREATE TABLE world_data_2023 (
    country VARCHAR(255),
    density_pkm2 DECIMAL(10,2),
    abbreviation VARCHAR(10),
    agricultural_land_percent DECIMAL(10,2),
    land_area_km2 DECIMAL(15,2),
    armed_forces_size DECIMAL(15,2),
    birth_rate DECIMAL(10,2),
    calling_code VARCHAR(20),
    capital_major_city VARCHAR(255),
    co2_emissions DECIMAL(15,2),
    cpi DECIMAL(10,2),
    cpi_change_percent DECIMAL(10,2),
    currency_code VARCHAR(10),
    fertility_rate DECIMAL(10,2),
    forested_area_percent DECIMAL(10,2),
    gasoline_price DECIMAL(10,2),
    gdp DECIMAL(20,2),
    gross_primary_education_enrollment_percent DECIMAL(10,2),
    gross_tertiary_education_enrollment_percent DECIMAL(10,2),
    infant_mortality DECIMAL(10,2),
    largest_city VARCHAR(255),
    life_expectancy DECIMAL(10,2),
    maternal_mortality_ratio DECIMAL(10,2),
    minimum_wage DECIMAL(15,2),
    official_language VARCHAR(255),
    out_of_pocket_health_expenditure DECIMAL(15,2),
    physicians_per_thousand DECIMAL(10,2),
    population DECIMAL(20,2),
    population_labor_force_participation_percent DECIMAL(10,2),
    tax_revenue_percent DECIMAL(10,2),
    total_tax_rate DECIMAL(10,2),
    unemployment_rate DECIMAL(10,2),
    urban_population DECIMAL(20,2),
    latitude DECIMAL(10,6),
    longitude DECIMAL(10,6)
);


CREATE TABLE global_data_on_sustainable_energy_2023 (
    entity VARCHAR(255),
    year VARCHAR(10),
    access_to_electricity_percent_of_population DECIMAL(10,2),
    access_to_clean_fuels_for_cooking DECIMAL(10,2),
    renewable_electricity_generating_capacity_per_capita DECIMAL(15,2),
    financial_flows_to_developing_countries_usd DECIMAL(20,2),
    renewable_energy_share_in_the_total_final_energy_consumption_percent DECIMAL(10,2),
    electricity_from_fossil_fuels_twh DECIMAL(20,2),
    electricity_from_nuclear_twh DECIMAL(20,2),
    electricity_from_renewables_twh DECIMAL(20,2),
    low_carbon_electricity_percent DECIMAL(10,2),
    primary_energy_consumption_per_capita_kwh_person DECIMAL(20,2),
    energy_intensity_level_of_primary_energy_mj_usd_ppp_gdp DECIMAL(20,2),
    co2_emissions_kt_by_country DECIMAL(20,2),
    renewables_percent_equivalent_primary_energy DECIMAL(10,2),
    gdp_growth DECIMAL(10,2),
    gdp_per_capita DECIMAL(20,2),
    density_p_km2 DECIMAL(10,2),
    land_area_km2 DECIMAL(20,2),
    latitude DECIMAL(10,6),
    longitude DECIMAL(10,6)
);

CREATE TABLE world_happiness_report (
country VARCHAR(255),
year VARCHAR(10),
life_ladder DECIMAL(6,3),
log_GDP_per_capita DECIMAL(6,3),
social_support DECIMAL(6,3),
healthy_life_expectancy_at_birth DECIMAL(6,3),
freedom_to_make_lifechoices DECIMAL(6,3),
generosity DECIMAL(6,3),
perceptions_of_corruption DECIMAL(6,3),
positive_affect DECIMAL(6,3),
negative_affect DECIMAL(6,3)
);


--nel 2020 quali sono i paesi che hanno meno accesso all'eletricità 
--e al gas per la cottura?
SELECT entity, access_to_electricity_percent, access_to_clean_fuels_for_cooking
FROM global_data_on_sustainable_energy_2000_2020
WHERE year = 2020
ORDER BY access_to_electricity_percent ASC
limit 10;

--che tipo di energia usano questi paesi?
SELECT entity, access_to_electricity_percent, electricity_from_fossil_fuels_twh, 
electricity_from_nuclear_twh, electricity_from_renewables_twh
FROM global_data_on_sustainable_energy_2000_2020
WHERE YEAR = 2020
ORDER BY access_to_electricity_percent ASC
LIMIT 10;

--quali sono i paesi che usano più energia rinnovabile?
SELECT entity, year, access_to_electricity_percent, renewables_percent_equivalent_primary_energy, electricity_from_renewables_twh
FROM global_data_on_sustainable_energy_2000_2020
WHERE year = 2020 AND access_to_electricity_percent = 100 AND renewables_percent_equivalent_primary_energy > 30
ORDER BY renewables_percent_equivalent_primary_energy DESC;

-- Top 5 paesi con più emissioni dal 2019 al 2016
WITH emissions AS (
    SELECT entity, year, co2_emissions_kt_by_country,
           ROW_NUMBER() OVER (PARTITION BY year ORDER BY co2_emissions_kt_by_country DESC) as rn
    FROM global_data_on_sustainable_energy_2000_2020
    WHERE co2_emissions_kt_by_country IS NOT NULL
    AND year IN (2019, 2018, 2017, 2016)
)
SELECT entity, year, co2_emissions_kt_by_country
FROM emissions
WHERE rn <= 5
ORDER BY year DESC, co2_emissions_kt_by_country DESC;

--e i paesi con più emissioni di co2?
SELECT entity, year, co2_emissions_kt_by_country
FROM global_data_on_sustainable_energy_2000_2020
WHERE co2_emissions_kt_by_country IS NOT NULL
ORDER BY co2_emissions_kt_by_country DESC;
--possiamo affermare che la Cina e gli USA sono i maggior produttori di co2
--ma in che anno è stato registrato il valore più alto?
SELECT entity, year, co2_emissions_kt_by_country
FROM global_data_on_sustainable_energy_2000_2020
WHERE co2_emissions_kt_by_country = (
    SELECT MAX(co2_emissions_kt_by_country)
    FROM global_data_on_sustainable_energy_2000_2020);

--Nel 2019 la Cina, c'è una correlazione con la densità della popolazione?
SELECT entity, year, density_p_per_km2, co2_emissions_kt_by_country,
       (density_p_per_km2 + co2_emissions_kt_by_country) / 2 AS media_density_co2
FROM global_data_on_sustainable_energy_2000_2020
WHERE  density_p_per_km2 IS NOT NULL AND co2_emissions_kt_by_country IS NOT NULL
ORDER BY media_density_co2 DESC;

--co2 negli ultimi 10 anni
SELECT year,
    SUM(co2_emissions_kt_by_country) AS total_co2
FROM global_data_on_sustainable_energy_2000_2020
WHERE year BETWEEN 2009 AND 2019 AND co2_emissions_kt_by_country IS NOT NULL
GROUP BY year
ORDER BY year;

SELECT year,
    SUM(electricity_from_renewables_twh) AS total_renewable_energy
FROM global_data_on_sustainable_energy_2000_2020
WHERE year BETWEEN 2009 AND 2019 AND electricity_from_renewables_twh IS NOT NULL
GROUP BY year
ORDER BY year;

---CO2 e qualità della vita
SELECT 
    wh.country,
	SUM(wh.log_gdp_per_capita) AS total_gdp,
    SUM(wh.social_support) AS total_social_support, 
    SUM(wh.freedom_to_make_lifechoices) AS total_freedom_to_make_lifechoices, 
    SUM(wh.generosity) AS total_generosity, 
    SUM(wh.perceptions_of_corruption) AS total_perceptions_of_corruption,
    SUM(ge.co2_emissions_kt_by_country) AS total_co2_emissions
FROM 
    world_happiness_report wh
JOIN 
    global_data_on_sustainable_energy_2000_2020 ge ON wh.country = ge.entity
WHERE 
    wh.freedom_to_make_lifechoices IS NOT NULL AND 
    wh.social_support IS NOT NULL AND 
    wh.generosity IS NOT NULL AND 
    wh.positive_affect IS NOT NULL AND 
    ge.co2_emissions_kt_by_country IS NOT NULL AND
	wh.perceptions_of_corruption IS NOT NULL AND
	wh.log_gdp_per_capita IS NOT NULL 
GROUP BY 
    wh.country
ORDER BY 
    total_co2_emissions DESC;

--PIL e CO2
SELECT 
    wh.country,
	SUM(wh.log_gdp_per_capita) AS total_gdp,
    SUM(ge.co2_emissions_kt_by_country) AS total_co2_emissions
FROM 
    world_happiness_report wh
JOIN 
    global_data_on_sustainable_energy_2000_2020 ge ON wh.country = ge.entity
WHERE 
    wh.log_gdp_per_capita IS NOT NULL AND 
    ge.co2_emissions_kt_by_country IS NOT NULL 
GROUP BY 
    wh.country
ORDER BY 
    total_gdp DESC;


--TOP 5 PAESI PER USO DI ENERGIA RINNOVABILE NEL 2019 E ASPETTATIVA DI VITA > 75 ANNI
SELECT DISTINCT g.entity, g.year, g.renewables_percent_equivalent_primary_energy, w.life_expectancy
FROM global_data_on_sustainable_energy_2000_2020 g
JOIN world_data_2023 w ON g.entity = w.country
WHERE g.renewables_percent_equivalent_primary_energy IS NOT NULL
AND year = 2019
AND w.life_expectancy > 75
ORDER BY g.renewables_percent_equivalent_primary_energy DESC
LIMIT 5;

--primi 10 paesi per uso di energia rinnovabile nel 2020 con aspettativa di vita > 80 anni
SELECT DISTINCT g.entity, g.year, g.renewables_percent_equivalent_primary_energy, w.life_expectancy
FROM global_data_on_sustainable_energy_2000_2020 g
JOIN world_data_2023 w ON g.entity = w.country
WHERE g.renewables_percent_equivalent_primary_energy IS NOT NULL
AND w.life_expectancy > 80
AND g.year =2020
ORDER BY g.renewables_percent_equivalent_primary_energy DESC;


--CONCLUSIONI
WITH happiness AS (
    SELECT
        country,
        social_support,
        freedom_to_make_lifechoices
    FROM
        world_happiness_report
    WHERE
        year = '2019'
),
sustainable_energy AS (
    SELECT
        entity AS country,
        renewable_energy_share_in_total_final_energy_consumption,
        access_to_electricity_percent
    FROM
        global_data_on_sustainable_energy_2000_2020
    WHERE
        year = '2019'
),
unique_happiness AS (
    SELECT
        country,
        MAX(social_support) AS social_support,
        MAX(freedom_to_make_lifechoices) AS freedom_to_make_lifechoices
    FROM
        happiness
    GROUP BY
        country
),
unique_sustainable_energy AS (
    SELECT
        country,
        MAX(renewable_energy_share_in_total_final_energy_consumption) AS renewable_energy_share_in_total_final_energy_consumption,
        MAX(access_to_electricity_percent) AS access_to_electricity_percent
    FROM
        sustainable_energy
    GROUP BY
        country
)

SELECT DISTINCT
    uh.country,
    uh.social_support,
    uh.freedom_to_make_lifechoices,
    use.renewable_energy_share_in_total_final_energy_consumption,
    use.access_to_electricity_percent,
    d.life_expectancy,
    d.gdp,
    d.minimum_wage,
    d.unemployment_rate
FROM 
    unique_happiness uh
JOIN 
    unique_sustainable_energy use
ON 
    uh.country = use.country
JOIN 
    world_data_2023 d
ON 
    uh.country = d.country
WHERE 
    d.minimum_wage IS NOT NULL 
    AND use.renewable_energy_share_in_total_final_energy_consumption IS NOT NULL
ORDER BY 
    d.life_expectancy DESC;


---medie paesi con + uso energia rinnovabile
WITH combined_data AS (
    SELECT 
        whr.country,
        whr.healthy_life_expectancy_at_birth,
        whr.social_support,
        whr.freedom_to_make_lifechoices,
        gse.renewable_energy_share_in_total_final_energy_consumption
    FROM 
        world_happiness_report whr
    JOIN 
        global_data_on_sustainable_energy_2000_2020 gse
    ON 
        whr.country = gse.entity
    WHERE 
        whr.year = '2019'
        AND gse.year = '2019'
)

SELECT 
    AVG(healthy_life_expectancy_at_birth) AS media_vita_sana,
    AVG(social_support) AS media_supporto_sociale,
    AVG(freedom_to_make_lifechoices) AS media_liberta_scelta
FROM 
    combined_data
WHERE 
    renewable_energy_share_in_total_final_energy_consumption > (
        SELECT AVG(renewable_energy_share_in_total_final_energy_consumption) 
        FROM combined_data
    );

    ---media paesi con - uso energia rinnovabile
    WITH combined_data AS (
    SELECT 
        whr.country,
        whr.healthy_life_expectancy_at_birth,
        whr.social_support,
        whr.freedom_to_make_lifechoices,
        gse.renewable_energy_share_in_total_final_energy_consumption
    FROM 
        world_happiness_report whr
    JOIN 
        global_data_on_sustainable_energy_2000_2020 gse
    ON 
        whr.country = gse.entity
    WHERE 
        whr.year = '2019'
        AND gse.year = '2019'
)

SELECT 
    AVG(healthy_life_expectancy_at_birth) AS media_vita_sana,
    AVG(social_support) AS media_supporto_sociale,
    AVG(freedom_to_make_lifechoices) AS media_liberta_scelta
FROM 
    combined_data
WHERE 
    renewable_energy_share_in_total_final_energy_consumption <= (
        SELECT AVG(renewable_energy_share_in_total_final_energy_consumption) 
        FROM combined_data
    );

--elettricità vs pil
SELECT 
    year,
    CORR(gdp_growth, access_to_electricity_percent) AS correlazione_gdp_elettricità
FROM 
    global_data_on_sustainable_energy_2000_2020
GROUP BY 
    year
ORDER BY 
    year;


--che piega sta prendendo il mondo?
    SELECT 
    year,
    AVG(generosity) AS media_generosity, 
    AVG(positive_affect) AS media_positive_affect,
    AVG(perceptions_of_corruption) AS media_perceptions_of_corruption,
    AVG(negative_affect) AS media_negative_affect
FROM 
    world_happiness_report
WHERE 
    generosity IS NOT NULL
GROUP BY 
    year
ORDER BY 
    year;

    ---Italia
        SELECT country,
    year,
    generosity, 
    positive_affect,
    perceptions_of_corruption,
    negative_affect,
	freedom_to_make_lifechoices
FROM 
    world_happiness_report
	WHERE country='Italy'
;