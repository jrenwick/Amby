--What is the most common first name among actors and actresses?
CREATE OR REPLACE VIEW TOP_FIRST_NAME AS
SELECT TOP 5
    split_part(trim(VALUE::varchar), ' ', 1) AS FIRST_NAME,
    count(*) AS NAME_COUNT
FROM DIM_SHOW, LATERAL flatten(input => split("CAST", ','))
GROUP BY FIRST_NAME;

--Which Movie had the longest timespan from release to appearing on Netflix?
CREATE OR REPLACE VIEW TOP_LONGEST_RUN_FROM_RELEASE AS
SELECT TOP 5
    DATE_ADDED,
    to_date(RELEASE_YEAR::varchar, 'YYYY') AS RELEASE_DATE,
    datediff(DAY, RELEASE_DATE, DATE_ADDED) AS DIFF
FROM DIM_SHOW
WHERE DATE_ADDED IS NOT null AND RELEASE_DATE IS NOT null
ORDER BY DIFF DESC;

--Which Month of the year had the most new releases historically?
CREATE OR REPLACE VIEW TOP_MOST_ADDED_MONTH AS
SELECT TOP 5
    concat(year(DATE_ADDED), '-', month(DATE_ADDED)) AS MTH,
    count(*) AS ADDED_COUNT
FROM DIM_SHOW
GROUP BY MTH
ORDER BY count(*) DESC;

--Which year had the largest increase year on year (percentage wise) for TV Shows?
CREATE OR REPLACE VIEW TOP_YOY_PERCENTAGE_INCREASE AS
WITH DATES AS (
    SELECT
        year(
            dateadd(YEAR, row_number() OVER (ORDER BY TRUE), '2007-01-01')::date
        ) AS YR
    FROM table(generator(ROWCOUNT => 20))
),

ADDED AS (
    SELECT
        year(DATE_ADDED) AS YR,
        count(*) AS ADDED_COUNT
    FROM DIM_SHOW
    WHERE
        TYPE = 'TV Show'
        AND DATE_ADDED IS NOT null
    GROUP BY YR
)

SELECT TOP 5
    DATES.YR,
    coalesce(ADDED_COUNT, 0) AS CY_ADDED_COUNT,
    sum(CY_ADDED_COUNT)
        OVER (
            ORDER BY
                DATES.YR ASC
            ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW
        )
        AS CUM_SUM,
    div0(CY_ADDED_COUNT, CUM_SUM - CY_ADDED_COUNT) * 100 AS YOY_INCREASE_PERCENT
FROM DATES LEFT JOIN ADDED ON DATES.YR = ADDED.YR
WHERE
    DATES.YR >= (SELECT min(YR) FROM ADDED)
    AND DATES.YR <= (SELECT max(YR) FROM ADDED)
ORDER BY YOY_INCREASE_PERCENT DESC;
